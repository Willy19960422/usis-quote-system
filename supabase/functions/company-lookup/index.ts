import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Content-Type": "application/json; charset=utf-8",
};
serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return new Response(JSON.stringify({ error: "Method not allowed" }), { status: 405, headers: cors });
  try {
    const auth = req.headers.get("Authorization");
    if (!auth?.startsWith("Bearer ")) return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: cors });
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const userRes = await fetch(supabaseUrl + "/auth/v1/user", { headers: { Authorization: auth, apikey: anonKey } });
    if (!userRes.ok) return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: cors });
    const { tax_id } = await req.json();
    if (typeof tax_id !== "string" || !/^\d{8}$/.test(tax_id)) return new Response(JSON.stringify({ error: "統編格式錯誤" }), { status: 400, headers: cors });
    const url = "https://data.gcis.nat.gov.tw/od/data/api/5F64D864-61CB-4D0D-8AD9-492047CC1EA6?$format=json&$filter=" + encodeURIComponent("Business_Accounting_NO eq " + tax_id) + "&$skip=0&$top=1";
    const upstream = await fetch(url, { headers: { Accept: "application/json" }, signal: AbortSignal.timeout(12000) });
    if (!upstream.ok) throw new Error("政府 API HTTP " + upstream.status);
    const payload = await upstream.json();
    const rows = Array.isArray(payload) ? payload : Array.isArray(payload?.data) ? payload.data : Array.isArray(payload?.value) ? payload.value : [];
    const found = rows.find((r: Record<string, unknown>) => String(r.Business_Accounting_NO ?? "").padStart(8, "0") === tax_id);
    return new Response(JSON.stringify({ company: found ? { tax_id, name: found.Company_Name ?? "", address: found.Company_Location ?? "" } : null }), { headers: cors });
  } catch (err) {
    console.error("Company lookup failed", err);
    return new Response(JSON.stringify({ error: "政府資料查詢失敗，請稍後再試" }), { status: 502, headers: cors });
  }
});