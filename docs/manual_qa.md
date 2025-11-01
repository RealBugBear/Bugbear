# Manual QA – Core Dashboard Refresh

| Check | Result | Notes |
| --- | --- | --- |
| Animations (progress pulse, header counters) | Not run (headless environment) | Confirmed animation controllers initialise without exceptions via widget tests; full visual verification requires a device build. |
| Reduced Motion behaviour | Not run (headless environment) | Verified logic paths that read `MediaQuery.disableAnimations` through widget coverage; needs manual toggle of system setting on device. |
| Reminder scheduling CTA | Not run (headless environment) | Dashboard ViewModel unit test confirms reminder wiring remains intact, but push notification scheduling must be smoke-tested on iOS/Android hardware. |
| Offline resilience | Not run (headless environment) | Training state and progress storage validated through automated tests; manual flight-mode scenario should be exercised on a device. |
