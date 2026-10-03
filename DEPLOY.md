# Deploy Waxtix: GitHub + Render + Supabase

## Supabase
- Create a project.
- Run `supabase/schema.sql` in SQL Editor.
- Copy Project URL and publishable key.
- Auth > Providers: enable Email. For email OTP, configure the email template to include the OTP token. Phone sign-in requires an SMS provider. Google requires Google OAuth credentials and Supabase redirect settings.

## GitHub
- Create a repository named `waxtix`.
- Upload all files from this project.
- Add `.env.local` to your local machine only; never commit it.

## Render
- New > Static Site > connect the GitHub repository.
- Build command: `npm ci && npm run build`
- Publish directory: `dist`
- Environment variables: `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY`.
- Deploy.

## OAuth URLs
After Render gives you the site URL, set it as the Supabase Auth Site URL / allowed redirect URL as appropriate. For Google, the OAuth redirect URI is the Supabase project's Auth callback URL shown in the Supabase provider settings.
