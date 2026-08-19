# ExecuteOS Setup Guide

## Quick start (local / guest mode)

```bash
git clone https://github.com/Ahad-Khan9076/executeos.git
cd executeos
flutter pub get
flutter run
```

Works fully offline with local persistence + rule-based AI Coach.

---

## Optional: Supabase Auth + Cloud

1. Create a project at https://supabase.com
2. Run `docs/SUPABASE_SCHEMA.sql` in the SQL editor
3. Enable Email auth in Authentication → Providers
4. Run the app with keys:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Sign in / Sign up on the Login screen will then use real Supabase Auth.

---

## Optional: LLM AI Coach

```bash
flutter run \
  --dart-define=OPENAI_API_KEY=sk-your-key \
  --dart-define=OPENAI_BASE_URL=https://api.openai.com/v1
```

Compatible with any OpenAI-compatible endpoint (OpenAI, Groq, Together, local LiteLLM, etc.).

Without a key, the rule-based coach is used automatically.

---

## Optional: Google Calendar

Scaffold lives in `lib/features/calendar/application/google_calendar_service.dart`.

To finish integration:
1. Google Cloud Console → enable Calendar API
2. Create OAuth client IDs (Android + iOS)
3. Add packages: `google_sign_in`, `googleapis`
4. Implement `connect()`, `pullEvents()`, `pushMeeting()`

---

## Notifications

On first launch, accept notification permissions.
Multi-stage reminders fire at 1 day, 1 hour, and 15 minutes before a task due time.
