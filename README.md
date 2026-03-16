# LifeOS

LifeOS is a production-grade Flutter mobile app that combines productivity, health tracking, knowledge management, and AI assistance in one system.

## Core Stack

- Flutter (latest stable)
- Riverpod for state management
- Clean Architecture style with feature-based modules
- Firebase Auth, Cloud Firestore, Firebase Storage, Firebase Cloud Messaging
- Speech-to-text voice command support
- AI chat integration via API

## Architecture

```text
lib/
  core/
    constants/
    theme/
    utils/
    widgets/
  features/
    auth/
    onboarding/
    dashboard/
    tasks/
    habits/
    notes/
    diet/
    fitness/
    analytics/
    ai_assistant/
    notifications/
    settings/
  models/
  providers/
  services/
    firebase_service/
    ai_service/
  app.dart
  main.dart
```

## Implemented Modules

- Authentication: Email/password, Google Sign-In, password reset, logout
- Onboarding: Multi-step profile + health + productivity intake
- Dashboard: Animated cards, reorderable layout, progress stats
- Task Manager: CRUD, status, deadlines, priorities, tags, subtasks, recurring tasks, drag-and-drop ordering
- Habit Tracker: CRUD, daily completion, streak logic, completion percentage ring
- Smart Notes: CRUD, tags, markdown preview, AI summarize/flashcards/quiz actions
- Diet + Water Tracker: Food logs, macros, daily calorie and hydration totals
- BMR + Calorie Target: Mifflin-St Jeor logic with goal-based targets
- Weight + Fitness Logs: Activity tracking, calories burned, weight trend chart
- AI Assistant: Chat UI for planning, note summary, diet/productivity prompts
- Voice Commands: Speech capture + command parsing for task/diet/AI actions
- Analytics: Task completion, habit consistency, nutrition and progress metrics
- Notification Preferences: User-level switches and FCM integration scaffold

## Firebase Setup

1. Install FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
```

2. Configure Firebase project:

```bash
flutterfire configure
```

3. Enable services in Firebase console:
- Authentication: Email/Password + Google
- Firestore Database
- Storage
- Cloud Messaging

4. Deploy Firestore rules from [firestore.rules](firestore.rules):

```bash
firebase deploy --only firestore:rules
```

## AI Setup

AI integration is configured with dart defines:

```bash
flutter run \
  --dart-define=AI_API_KEY=YOUR_KEY \
  --dart-define=AI_MODEL=gpt-4o-mini \
  --dart-define=AI_API_BASE_URL=https://api.openai.com/v1/chat/completions
```

If no key is provided, the app still runs and shows a helpful configuration message in AI features.

## Firestore Collections

- users/{userId}
- tasks/{taskId}
- habits/{habitId}
- notes/{noteId}
- diet_logs/{logId}
- water_logs/{logId}
- weight_logs/{logId}
- fitness_logs/{logId}

All feature data is scoped by userId and protected by security rules.

## Run

```bash
flutter pub get
flutter run
```

## Notes

- Android is the primary target; iOS support is included.
- For Google Sign-In on Android/iOS, ensure SHA keys and URL schemes are configured in Firebase.
- Some Firestore queries (where + orderBy) may require creating composite indexes when prompted by Firestore errors.
