# ExecuteOS — Architecture Overview

## Frontend (Flutter)

- **State Management:** Riverpod (with code generation)
- **Architecture Style:** Feature-first + Clean-ish layers (presentation / domain / data)
- **Routing:** go_router
- **Local Storage:** Hive CE (or Isar later) + Drift if needed for complex offline queries
- **Offline Strategy:** Optimistic UI + eventual consistency for tasks & Today view

### Folder Structure
```
lib/
├── main.dart
├── app/                 # App widget, router, bootstrap
├── core/                # theme, constants, utils, errors, network
├── features/
│   ├── auth/
│   ├── today/
│   ├── tasks/
│   ├── calendar/
│   ├── meetings/
│   ├── goals/
│   ├── ai_coach/
│   ├── scores/
│   └── settings/
├── shared/              # common widgets, models, services
└── l10n/
```

Each feature typically has:
- `presentation/` (screens, widgets, controllers)
- `domain/` (entities, repositories interfaces, use cases)
- `data/` (repository implementations, data sources, DTOs)

## Backend (MVP)

**Recommended for speed:** Supabase
- Auth
- Postgres + Row Level Security
- Realtime
- Edge Functions (for reminders, AI orchestration)

Later migration path to NestJS + Postgres + Redis for complex queues and AI cost control if needed.

## AI Layer

Logical agents:
- Coach (conversational)
- Planner (daily schedule)
- Analyst (insights & overload)
- Automation (proposes only)

Guardrails: Never perform sensitive external actions without explicit user confirmation.

## Notification Engine
Centralized service supporting Push + Email + In-app with multi-stage and contextual content.
