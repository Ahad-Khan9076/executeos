# ExecuteOS — Current Status

## What works right now

### Today Dashboard
- Time-based greeting
- Live Discipline Score
- Meetings (tap → post-meeting follow-up)
- Overdue / Focus Now / Completed sections
- Quick Add Task

### Tasks
- Create / Edit / Complete / Postpone / Delete
- Multi-stage **local notifications** (1 day, 1 hour, 15 min before due)
- Local persistence (survives restart)
- Detail screen

### Meetings
- Domain model + seed data
- Post-meeting follow-up prompt → creates high-priority task

### Calendar
- Week strip + day view with meetings & tasks

### AI Execution Coach (working)
- Real chat interface
- Answers from your actual data:
  - "What should I focus on?"
  - "Plan my day"
  - "Why am I behind?"
  - "What meetings do I have?"
  - "How is my score?"
  - "Schedule unfinished tasks"
- Suggestion chips for one-tap questions

### Notifications
- Initialized on app start
- Multi-stage reminders scheduled automatically on task create/update
- Cancelled on complete/delete

### Auth
- Auth state provider (guest / authenticated)
- Login screen + guest path
- Ready for Supabase wiring

### Navigation
- Bottom nav: Today / Tasks / Calendar / AI

## How to run

```bash
git pull
flutter pub get
flutter run
```

> On first run, accept notification permissions so reminders work.

## Next high-value items
1. Real Supabase Auth + cloud sync
2. Google Calendar bi-directional sync
3. Upgrade AI Coach to LLM (keep rule-based as fallback)
4. Goals module
5. Custom reminder offsets per task
