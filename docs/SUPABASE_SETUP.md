# Supabase Setup (Next Step)

## 1. Create a Supabase project
1. Go to https://supabase.com and create a new project.
2. Copy the **Project URL** and **anon public key**.

## 2. Add to the app
Create a `.env` file (already in `.gitignore`):

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Then initialize in `main.dart`:

```dart
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
```

## 3. Auth
- Enable Email auth (and optionally Google OAuth).
- Use `supabase.auth.signInWithPassword` / `signUp`.

## 4. Database (later)
Tables we will need:
- `profiles`
- `tasks`
- `meetings`
- `goals`
- etc.

Row Level Security must be enabled from day one.

## Current status
Login screen is a placeholder. "Continue as guest" skips auth so we can keep building the product.
