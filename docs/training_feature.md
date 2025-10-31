# Training Mode 1 Overview and User Guide

## Overview
Mode 1 now centres on the Moro training experience: athletes step through rich multimedia exercises, optionally resume where they left off, and earn XP as they progress. A notifier-driven architecture persists every change, keeping the dashboard and profile areas in sync even when the device is offline.

## Architecture Summary
- **State management** – `SessionNotifier` owns the persisted `SessionState`, exposes planning helpers, manages Moro resume points, and applies XP or streak updates whenever training activity is recorded.【F:lib/features/training/notifier/session_notifier.dart†L16-L157】
- **Session model** – `SessionState` stores phase metadata, counts, scheduling details, and the Moro resume map. Each `ExerciseItem` describes timing defaults and assets for a single exercise step.【F:lib/features/training/models/session_state.dart†L1-L22】【F:lib/features/training/models/exercise_item.dart†L1-L19】
- **Moro experience** – `MoroTrainingScreen` loads the exercise catalog, pulls persisted progress, reacts to deep-link intents, and launches exercises with autoplay/resume support.【F:lib/features/training/moro/moro_training_screen.dart†L18-L196】
- **Progress stores** – `MoroProgressStore` records completed Moro exercises, while `MoroSpeedStore` persists user-specific autoplay offsets per exercise.【F:lib/features/training/moro/moro_progress_store.dart†L17-L74】【F:lib/features/training/moro/moro_speed_store.dart†L7-L27】
- **Persistence and sync** – `SessionRepository` writes the latest session snapshot to Hive, `ExerciseRepository` supplies the phase plan, and `SyncService` queues updates for backend synchronisation.【F:lib/features/training/services/session_repository.dart†L1-L23】【F:lib/features/training/services/exercise_repository.dart†L1-L32】【F:lib/features/training/services/sync_service.dart†L1-L74】

## Feature Walkthrough (Mode 1)
1. **Bootstrapping** – `SessionNotifier` is injected with repositories and the initial `SessionState`, immediately saving subsequent mutations for resilience.【F:lib/features/training/notifier/session_notifier.dart†L34-L61】
2. **Preparing a Moro session** – `MoroTrainingScreen` fetches the Moro exercise list, loads stored progress, resolves autoplay defaults, and handles start/resume intents before presenting the launch card.【F:lib/features/training/moro/moro_training_screen.dart†L24-L136】
3. **Running exercises** – After the pre-check, `_openExercise` drives each exercise screen, applies XP rewards via `SessionNotifier.applyXpReward`, chains autoplay navigation, and routes to the completion screen when finished.【F:lib/features/training/moro/moro_training_screen.dart†L260-L401】
4. **Scheduling the next session** – From the completion screen users can plan the following session through `SessionNotifier.scheduleNextSession`, resetting counters and marking the session as planned.【F:lib/features/training/training_completed_screen.dart†L91-L137】【F:lib/features/training/notifier/session_notifier.dart†L92-L115】

## User Guide (Mode 1)
### Launching a Session
1. Navigate to Training. The Moro start card shows the upcoming exercise, indicates saved resume points, and exposes autoplay controls.【F:lib/features/training/moro/moro_training_screen.dart†L64-L118】
2. Select “Training starten” to pass through the Moro pre-check, adjust autoplay timing, and begin the session.【F:lib/features/training/moro/moro_training_screen.dart†L96-L172】
3. Work through each exercise. Completed items award XP immediately, update stored progress, and automatically advance when autoplay is enabled.【F:lib/features/training/moro/moro_training_screen.dart†L360-L401】【F:lib/features/training/notifier/session_notifier.dart†L143-L157】
4. When the final exercise is done, the app navigates to the completion screen where you can celebrate, return to the dashboard, or plan the next session.【F:lib/features/training/moro/moro_training_screen.dart†L360-L401】【F:lib/features/training/training_completed_screen.dart†L25-L139】

### Managing Progress and Planning
- Use resume points to jump back into partially completed Moro content; they’re stored and retrieved via `SessionNotifier` helpers.【F:lib/features/training/notifier/session_notifier.dart†L117-L141】
- Tap “Nächste Session planen” on the completion screen to schedule tomorrow’s workout; the notifier resets the session to a planned state with fresh counters.【F:lib/features/training/training_completed_screen.dart†L118-L137】【F:lib/features/training/notifier/session_notifier.dart†L92-L115】

### Offline Usage Notes
- Session state is saved locally so progress survives app restarts or network outages.【F:lib/features/training/notifier/session_notifier.dart†L34-L61】【F:lib/features/training/services/session_repository.dart†L1-L23】
- Once connectivity returns, queued changes propagate automatically via `SyncService`—no manual action required.【F:lib/features/training/services/sync_service.dart†L1-L74】

### Tips for Practitioners
- Extend the Moro catalog or adjust defaults by editing `MoroRepository` data and exercise definitions.【F:lib/features/training/moro/moro_repository.dart†L9-L96】
- Tune autoplay defaults per exercise through `MoroSpeedStore` if different pacing is desired.【F:lib/features/training/moro/moro_speed_store.dart†L7-L27】
- Customise XP rewards by tweaking `SessionNotifier.computeXp` or calling `applyXpReward` with scenario-specific values.【F:lib/features/training/notifier/session_notifier.dart†L123-L157】
