# Waxtix

Waxtix is a mobile-first short-video and news community app based on the supplied Waxtix specification.

## Included
- Home with 60-second video feed, search, like/share/comment/download UI.
- News with photos and Add action.
- Upload page for video-only uploads and news photos.
- Chat UI for followed users/status.
- Profile with Edit profile, Followers, Following and Views.
- Menu: Change language, Help Center, My account, password/email/phone/theme placeholders.
- Sign in with email OTP, phone OTP, and Google OAuth.
- Supabase Postgres, Auth, Storage and RLS schema.
- Render static-site configuration and GitHub-ready repository files.

## Setup
1. Create a Supabase project.
2. In Supabase SQL Editor, run `supabase/schema.sql`.
3. In Supabase Auth, configure Email OTP. For phone OTP, configure an SMS provider. Google sign-in requires a Google OAuth client and the Supabase callback URL.
4. Copy `.env.example` to `.env.local` and add the Supabase project URL and publishable key.
5. Run `npm install` then `npm run dev`.
6. For Render, connect this GitHub repository as a Static Site. Build command: `npm ci && npm run build`. Publish directory: `dist`. Add `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY` environment variables.

## Important
The app is ready as a deployable project, but Supabase/Google/SMS provider credentials are external configuration and cannot be embedded in a ZIP. Never put a Supabase secret/service-role key in frontend code.
