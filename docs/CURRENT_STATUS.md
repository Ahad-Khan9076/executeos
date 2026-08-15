# ExecuteOS — Current Status

## What works right now

### Today Dashboard
- Time-based greeting
- Live Discipline Score (transparent)
- Meetings for today (tap to open post-meeting follow-up)
- Overdue tasks
- Focus Now list
- Completed Today list
- Quick Add Task

### Tasks
- Create (title, notes, priority, due date, estimate)
- Edit
- Complete (with professional motivational message)
- Postpone 1 day
- Delete
- Local persistence (survives app restart)
- Detail screen

### Meetings
- Domain model
- Seeded sample meeting
- **Post-meeting follow-up prompt** (key differentiator)
  - Creates a high-priority follow-up task for tomorrow

### Calendar
- Week strip navigation
- Selected day view showing meetings + tasks due that day

### Navigation
- Bottom nav: Today / Tasks / Calendar / AI
- Task detail opens above the shell

### Auth
- Login screen placeholder
- Guest path available for development
- Supabase setup guide in `docs/SUPABASE_SETUP.md`

### AI Coach
- Placeholder UI with suggested prompts

## How to run

```bash
git pull
flutter pub get
flutter run
```

## Next high-value items
1. Wire real Supabase Auth + cloud sync for tasks
2. Google Calendar bi-directional sync
3. Real AI Coach (LLM + tool calling)
4. Multi-stage reminders (local notifications)
5. Goals module
