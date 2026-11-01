# Observability and performance

You can't fix what you can't see, and you can't judge performance from a fast laptop on a fast network.

## Budgets

1. **Set budgets per product in an ADR** and check them before each release. Starting points:
   - Web: LCP under 2.5 s, INP under 200 ms, CLS under 0.1 on a mid-range phone over 4G.
   - API: p95 latency per endpoint, and an error-rate ceiling.
2. **Measure on real hardware, in real browsers.** Use a mid-range phone and an older laptop, through a device lab or a remote real-device service when you don't own them, plus field data (RUM, CrUX) once live. DevTools CPU and network throttling is a first check, not the measurement. Tools: Lighthouse, the browser's Performance panel, and a load-test tool for APIs.

## Rules for efficient software

3. **Nothing runs continuously when it doesn't have to.** Animations, timers, polling and location run only while they're visible and meaningful, and stop when the page or app is hidden or under reduce motion.
4. **Compute art once.** Procedural shapes and layout maths are memoised or precomputed, not recalculated per frame.
5. **Animate off the main thread** (compositor-only CSS: `transform` and `opacity`) and never trigger layout per frame.
6. **Lists are virtualised**, images are resized before upload and cached on disk, and requests are batched.
7. **Cache with intent**: persisted query caches for offline use, and server-side caches for third-party APIs (weather per 0.1° for 30 min).

## Observability

8. **Crash and error reporting from day one** (Sentry or equivalent), with content scrubbing on: no message bodies, notes, emails or tokens.
9. **Structured logs on the server** with request ids, never personal content. Log the decision ("skipped: quiet hours"), not the data.
10. **Product analytics count events, not content** (`invoice_sent`, `report_exported`), insert-only from clients, and purged on a schedule.
11. **Every scheduled job records its outcome** (sent, retried, skipped with a reason) somewhere queryable, so "why didn't I get the push?" has an answer.
12. **Alert on symptoms customers feel**: crash-free sessions, failed deliveries, job backlog, error rate. Not on every log line.

## Mobile (iOS and Android)

- **Budgets**: cold start under 2 s on a mid-range phone, 60 fps while scrolling and animating, and under 100 ms from tap to response.
- **Measure on real devices**, a mid-range Android phone first. An emulator's CPU isn't the device's: one always-on animation can cost an emulator several cores and still look smooth. Profilers: `adb shell dumpsys gfxinfo <package>` (frame times), Android Studio's profiler, and Xcode Instruments.
- **Animate on the UI thread** (Reanimated worklets). Animate views rather than redrawing SVG every frame, and stop continuous animation in the background and under Reduce Motion.
- **Crash reports** come from release builds with source maps and debug symbols uploaded, and content scrubbing on.
