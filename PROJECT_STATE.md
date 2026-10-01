# SHAVALLEYA — Project State

## MVP
QR → guest mobile web menu → cart → order → Supabase → staff notification/status → customer status. No customer registration. Payment at pickup initially.

## Pilot
Шаваллея, Калининград, ул. Каштановая Аллея, 73а.

## Stack
Next.js 16 / TypeScript / Tailwind / Supabase. OrderKing MIT used only as prototype baseline; license retained.

## Current state — 2026-10-01
- Private repo populated from OrderKing baseline.
- Dedicated Supabase project: bspktoshbiyhfpmulfek.
- Secure Shavalleya schema + hardening migrations applied.
- RLS enabled on all application tables; direct anonymous order-table writes blocked.
- Guest place_order RPC recalculates prices from canonical products/modifiers.
- Token-scoped get_order_status supports customer polling.
- Pilot location seeded.
- Real menu categories seeded (13 categories); products/prices not invented and remain pending source extraction.
- Root route now opens /menu/kashtanovaya-73a.
- New Russian guest mobile ordering page created against the Shavalleya schema.
- Supabase client migrated to publishable-key env naming.
- 37 confirmed products/prices imported; ambiguous drinks intentionally excluded.\n- Server now enforces modifier min/max rules and exposes service-role-only staff_set_order_status for Telegram/KDS.\n- Next: exact compositions/modifier mapping, Telegram webhook UI, deployment/QR acceptance test.
