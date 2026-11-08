# IRON — Fitness and workout tracker

IRON is a responsive React/Vite fitness tracking interface. It includes a dashboard, workout library and session timer, weekly planner, nutrition log, progress view, profile, settings, and BMI/BMR/TDEE estimates.

## Run locally

1. Install Node.js 20 or newer.
2. Run `npm install`.
3. Copy `.env.example` to `.env.local` and add your Supabase project URL and public anon/publishable key (optional for the local-only demo mode).
4. Run `npm run dev` and open the local URL Vite prints.
5. Run `npm run build` for a production bundle.

The interface currently stores demo-mode entries in the browser's local storage. It does not submit account data to a server unless Supabase is configured and the application services are connected. Browser storage is device-local and is not suitable for confidential or multi-device production use.

## Supabase setup

1. Create a Supabase project.
2. Run [`supabase/schema.sql`](supabase/schema.sql) in the SQL Editor. It creates the profile, exercise library, workout, session, set, weight, measurement, nutrition, and goal tables with indexes and row-level policies.
3. Copy the project URL and anon/publishable key into `.env.local` as `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`.
4. Configure email confirmation, redirect URLs, and password reset URLs in Supabase Auth.
5. Never put a service-role key in browser code.

The SQL establishes a secure data model, but the current UI is not yet wired to Supabase CRUD or Supabase Auth screens. Do not deploy it as an account-backed production service until that integration and end-to-end authorization testing are completed.

## Deploy to Vercel

Import the repository into Vercel. Vercel detects Vite; use `npm run build` and `dist` as the output directory. Add the two `VITE_SUPABASE_*` environment variables if connecting Supabase, then configure the matching production URL in Supabase Auth. For client-side routes, Vercel's Vite defaults serve the SPA fallback.

## Notes

- Food entry is manual. Nutrition values and calculator results are estimates, not medical advice.
- The exercise templates are starter content; they are not an externally maintained library and do not include instructional photography.
- The workout timer is an interactive session UI, but detailed exercise/set history persistence and multi-user account workflows remain to be integrated.
