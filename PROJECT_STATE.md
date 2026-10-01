# SHAVALLEYA — Project State

## MVP
QR → guest mobile web menu → modifiers → cart → order → Supabase → staff notification/status → customer status.
No customer registration. Payment at pickup initially.

## Pilot
Шаваллея, Калининград, ул. Каштановая Аллея, 73а.

## Stack
Next.js 16 / TypeScript / Tailwind / Supabase.
Imported OrderKing (MIT) as prototype baseline; MIT license retained.

## Current state — 2026-10-01
- OrderKing source baseline imported into private Yumis84/shavalleya.
- Dedicated Supabase project connected: bspktoshbiyhfpmulfek.
- Secure Shavalleya schema applied; original OrderKing schema was NOT applied.
- Pilot location seeded.
- Guest direct table writes are blocked by RLS.
- place_order RPC validates product availability and recalculates canonical prices.
- Public order status is token-scoped.
- Menu/categories/products/modifiers are ready for data import.
- Next: adapt frontend to new schema/Russian UX, import real menu, then Telegram staff workflow and deployment.
