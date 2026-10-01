# SHAVALLEYA — Project State

## Product role
Шаваллея is both the live pilot and the reference implementation/template for future restaurant and cafe QR-ordering deployments. Keep tenant/location-specific data separate from reusable ordering infrastructure.

## MVP
QR → guest mobile web menu → cart → order → Supabase → Telegram staff workflow → customer status. No customer registration. Payment at pickup initially.

## Pilot
Шаваллея, Калининград, ул. Каштановая Аллея, 73а.

## Stack
Next.js 16 / TypeScript / Tailwind / Supabase / Telegram Bot Edge Functions.

## Current state — 2026-10-01
- Dedicated Supabase project `bspktoshbiyhfpmulfek`.
- RLS enabled on all application tables; direct anonymous order-table writes blocked.
- Guest ordering is server-authoritative: database prices/modifiers are validated by `place_order`.
- Customer status is token-scoped through `get_order_status`.
- Staff status changes are service-role-only and lifecycle constrained.
- Telegram bot/group callback flow has been verified; real DB-backed order cards are implemented server-side.
- Frontend checkout routes through the `place-order` Edge Function, which creates the order and triggers Telegram notification.
- 13 menu categories and 37 confirmed products/prices are loaded. Ambiguous drinks are intentionally excluded.
- Legacy OrderKing routes/schema/runtime dependencies have been removed.
- Production migration ledger and a replayable schema baseline are recorded under `supabase/` and `docs/`.

## Template invariants
- Never expose service-role or Telegram bot secrets to browser code.
- Browser reads only active public menu data and uses controlled ordering/status interfaces.
- Prices are canonical in the database; client totals are display-only.
- Restaurant identity, locations, menu data, Telegram destination and secrets are deployment configuration, not reusable core logic.
- Telegram is the MVP staff UI; a future KDS can use the same order lifecycle.
- Advance-order scheduling/pinning is an extension; ordinary current orders are never pinned.

## Next acceptance gate
1. Build/deploy the cleaned frontend.
2. Place one real order through the public UI.
3. Verify DB order + status history + Telegram card.
4. Run Telegram lifecycle through accepted → preparing → ready → completed and verify customer polling.
5. Harden Telegram webhook/internal notification endpoints before production launch.
