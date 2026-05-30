# HustleXP — Poster Web

Next.js 16 (App Router) + React 19 + Tailwind v4. Poster-side web liquidity surface for [Roadmap C](../HUSTLEXP_HANDOFF_ROADMAP_C2.md).

## Setup

1. **Install:** `npm install`
2. **Env:** copy `.env.example` to `.env.local` and fill in:
   - `NEXT_PUBLIC_API_URL` — backend tRPC base, no trailing slash (e.g. `http://localhost:3000` for local backend, or the staging URL).
   - `NEXT_PUBLIC_FIREBASE_*` — Firebase Web SDK config for the **same** Firebase project the iOS app uses.
   - `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY` — Stripe publishable key (used from C7 onward).
   - `NEXT_PUBLIC_POSTHOG_*` — analytics (used from C10 onward).
3. **Dev:** `npm run dev` → open <http://localhost:3000>.

## Verify C2 wiring

`/dev/me` is a dev-only smoke page (returns 404 in production builds) that exercises:

- **`health.ping`** — proves the tRPC URL + CORS without auth.
- **`user.me`** — proves the Bearer header + token-refresh link once you sign in via the in-page Firebase email/password form.

If the network tab shows the request going to `/trpc/health.ping?…` and returning `{ status: 'ok' }`, the wiring is correct.

## CORS

The backend reads `ALLOWED_ORIGINS` from env. `http://localhost:3000` is already in the dev allow-list. For Vercel previews/prod, add the deployed URL(s) to the backend's `ALLOWED_ORIGINS` env on Fly/Railway (the backend's `config.app.allowedOrigins` is the source — see `Sebdysart/hustlexp-ai-backend` `backend/src/config.ts` and `backend/src/server.ts`).

## tRPC type sync

The `AppRouter` type is vendored at `types/trpc/AppRouter.d.ts` (bundled from the backend repo via `dts-bundle-generator`). Re-sync after any backend API change:

```bash
./scripts/sync-trpc-types.sh
```

Requires `gh` authenticated against `Sebdysart/hustlexp-ai-backend`. Override the source branch via `HUSTLEXP_BACKEND_REF=<branch>` env if needed.

The backend re-bundles its side with `npm run emit:trpc-types` and commits `dist-types/AppRouter.d.ts`.

## Scripts

- `npm run dev` — Next.js dev server (HMR).
- `npm run build` — production build.
- `npm run start` — serve the build.
- `npm run lint` — ESLint.
- `./scripts/sync-trpc-types.sh` — pull a fresh `AppRouter.d.ts` from the backend repo.
