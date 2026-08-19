# ExecuteOS — Current Status

## Working features

### Core execution loop
- Today dashboard (greeting, score, goals, meetings, tasks)
- Tasks: create / edit / complete / postpone / delete
- Multi-stage local notifications (1d / 1h / 15m)
- Local persistence for tasks & goals
- Post-meeting follow-up → creates task
- Discipline score (transparent)
- Motivational completion messages

### Goals
- Create goals with optional target date
- Show on Today
- Mark complete
- Local persistence

### AI Execution Coach
- Chat UI with suggestion chips
- **Rule-based** coach (always available, uses real task/meeting data)
- **LLM coach** when `OPENAI_API_KEY` is provided (falls back automatically)

### Auth
- Login / Sign up / Guest
- Supabase Auth when `SUPABASE_URL` + `SUPABASE_ANON_KEY` are set
- Local fallback when not configured

### Calendar
- Week strip + day agenda (tasks + meetings)
- Google Calendar service **scaffolded** (OAuth implementation next)

### Architecture
- Flutter + Riverpod + go_router
- Feature-first structure
- Env via `--dart-define`
- Supabase schema ready (`docs/SUPABASE_SCHEMA.sql`)

## How to run

```bash
git pull
flutter pub get
flutter run
```

With cloud + LLM:

```bash
flutter run \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=OPENAI_API_KEY=...
```

See `docs/SETUP.md` for full instructions.

## Remaining polish (optional)
1. Finish Google Calendar OAuth + bi-directional sync
2. Push local tasks to Supabase when authenticated
3. Custom reminder offsets per task
4. Web / desktop targets
