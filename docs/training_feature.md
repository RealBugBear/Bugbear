# Training Mode 1 Overview and User Guide

## Overview
Mode 1 delivers the core, phase-based training loop: it steers athletes through their programmed exercises with timed active and rest intervals, persists their place between app launches, and updates the training calendar once a session is complete. The flow is powered by a notifier-driven architecture, lightweight repositories for persistence and sync, and a widget set that keeps the UI focused on the current exercise state.

## Architecture Summary
- **State management** – `SessionNotifier` owns the live `SessionState`, drives the timer, and advances through repetitions and exercises for the active phase.【F:lib/features/training/notifier/session_notifier.dart†L1-L145】
- **Session model** – `SessionState` captures phase metadata, the active exercise index, repetition counts, timing, and completion status. Each `ExerciseItem` provides the duration presets and assets for a single step.【F:lib/features/training/models/session_state.dart†L1-L20】【F:lib/features/training/models/exercise_item.dart†L1-L19】
- **Repositories and services** – `SessionRepository` persists the latest session snapshot, `ExerciseRepository` loads the exercise list for a phase, `SyncService` forwards finished sessions, and calendar-related services log completions and golden-day projections.【F:lib/features/training/services/session_repository.dart†L1-L23】【F:lib/features/training/services/exercise_repository.dart†L1-L32】【F:lib/features/training/services/sync_service.dart†L1-L74】【F:lib/features/calendar/services/golden_day_service.dart†L1-L60】
- **User interface** – `TrainingScreen` composes the header, connectivity banner, progress indicators, exercise canvas, and control buttons so users can monitor progress, view cues, and control playback.【F:lib/features/training/training_screen.dart†L1-L70】【F:lib/features/training/widgets/training_header.dart†L1-L58】【F:lib/features/training/widgets/progress_row.dart†L1-L58】【F:lib/features/training/widgets/exercise_canvas.dart†L1-L37】【F:lib/features/training/widgets/control_button_row.dart†L1-L46】
- **Phase management** – Athletes can switch to another phase via the header, which resets state and loads the correct exercises while keeping persistence and sync intact.【F:lib/features/training/widgets/training_header.dart†L17-L52】【F:lib/features/training/notifier/session_notifier.dart†L65-L118】

## Feature Walkthrough (Mode 1)
1. **Bootstrapping** – `SessionNotifier` is provided to the widget tree with injected repositories and initial exercises, immediately exposing the exercise list and saving each state change for resilience.【F:lib/features/training/notifier/session_notifier.dart†L19-L57】
2. **Starting a session** – Pressing Play on `TrainingScreen` triggers `SessionNotifier.start()`, which flips the pause flag, starts a one-second timer, and handles the 8s/4s active-rest rotation automatically.【F:lib/features/training/training_screen.dart†L36-L60】【F:lib/features/training/notifier/session_notifier.dart†L59-L97】
3. **Exercise transitions** – Completed repetitions lead into rest windows and, once finished, advance to the next exercise or mark the session complete. Manual navigation resets counters and durations appropriately.【F:lib/features/training/training_screen.dart†L22-L64】【F:lib/features/training/notifier/session_notifier.dart†L97-L144】
4. **Persistence and sync** – Every mutation is written to Hive and queued for upload; when a session completes, calendar events and golden-day calculations are updated to reflect the workout.【F:lib/features/training/notifier/session_notifier.dart†L37-L144】【F:lib/features/training/services/session_repository.dart†L1-L23】【F:lib/features/training/services/sync_service.dart†L1-L74】【F:lib/features/calendar/services/golden_day_service.dart†L1-L60】

## User Guide (Mode 1)
### Launching a Session
1. Open the Training screen. The header reveals the active phase and quick actions for switching plans or reaching help.【F:lib/features/training/training_screen.dart†L14-L68】【F:lib/features/training/widgets/training_header.dart†L17-L58】
2. Check the progress row to monitor exercise index, repetition counts, and the live timer, while the canvas shows the current cue image.【F:lib/features/training/widgets/progress_row.dart†L1-L58】【F:lib/features/training/widgets/exercise_canvas.dart†L1-L37】
3. Use the control buttons to manage playback and navigation:
   - **Play/Pause** toggles the timer.【F:lib/features/training/training_screen.dart†L36-L54】
   - **Back/Next** rewinds or advances to neighbouring exercises, resetting repetitions and timers as needed.【F:lib/features/training/training_screen.dart†L22-L64】
4. Let the session auto-progress through repetitions (default 8s active, 4s rest). When the last exercise completes, the workout is marked finished and logged to the calendar.【F:lib/features/training/notifier/session_notifier.dart†L69-L144】

### Switching Phases or Getting Help
1. Tap the phase name in the header to open the selector. Choosing a new phase reloads its exercise plan and restarts the session state.【F:lib/features/training/widgets/training_header.dart†L23-L41】【F:lib/features/training/notifier/session_notifier.dart†L65-L118】
2. Use the help icon to jump into the Training Help screen for contextual instructions or media clips per exercise.【F:lib/features/training/widgets/training_header.dart†L42-L52】【F:lib/features/training/screens/training_help_screen.dart†L1-L63】

### Offline Usage Notes
- Progress is saved locally so leaving the app or losing connectivity preserves your spot.【F:lib/features/training/notifier/session_notifier.dart†L37-L57】【F:lib/features/training/services/session_repository.dart†L1-L23】
- When connectivity returns, queued updates sync automatically—no manual intervention required.【F:lib/features/training/services/sync_service.dart†L1-L74】

### Tips for Practitioners
- Adjust pacing defaults or populate real assets by editing `ExerciseRepository` entries for each phase.【F:lib/features/training/services/exercise_repository.dart†L1-L32】
- Expand Training Help coverage by mapping additional exercises to asset IDs in `_videoPaths`.【F:lib/features/training/screens/training_help_screen.dart†L16-L60】
- Tailor calendar behaviour or golden-day thresholds via `GoldenDayService` if your programme needs different cadence targets.【F:lib/features/calendar/services/golden_day_service.dart†L1-L60】
