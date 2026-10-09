# Koh Samui Immigration FIDS Queue Display Kiosk

Interactive, high-density Flight Information Display System (FIDS) queue kiosk prototype engineered for **Koh Samui Provincial Immigration Office** (Maenam checkpoint). Deployed as a zero-latency digital signage web client on Netlify.

---

## 1. System Architecture & Design System

The terminal layout strictly adheres to the airport FIDS design standards, optimized for viewing distances of 2.5 to 7.0 meters on 55"–65" commercial display panels.

### Key Tokens & Aesthetics
- **Display Canvas**: `#05080E` (Deep space obsidian, preventing LCD back-bleed in semi-outdoor tropical waiting rooms)
- **Signal Action (Amber)**: `#FFB800` (Airport amber, APCA Lc 84 on dark background, active ticket calls)
- **Signal Success (Emerald)**: `#10B981` (Passport collection readiness, APCA Lc 78, Counter 4)
- **Signal Warning (Solar)**: `#F59E0B` (Lunch break pause indicators)
- **Signal Info (Cyan)**: `#00D2FF` (Next queue stream indicators)
- **Virtual Grid**: Fixed 1920x1080 Full HD (16:9) viewport wrapped in `FittedBox.contain` for responsive scaling across any physical display resolution.
- **Typography**: IBM Plex Sans + IBM Plex Sans Thai (bilingual English / Thai layout with zero parenthetical echoes).

---

## 2. Realistic 4-Phase Operational Lifecycle

Koh Samui Immigration operates on strict government service windows. The kiosk state machine reflects this operational reality:

```
[Booting (POST)]  -->  [Morning Intake]  -->  [Lunch Break]  -->  [Afternoon Pickup]
   (08:00-08:30)          (08:30-11:30)         (12:00-13:00)         (13:00-16:30)
```

1. **Booting (`OperationalPhase.booting`)**:
   Hardware power-on self-test (POST), PIBICS immigration network handshake, and QueQ dispatch engine synchronization.
2. **Morning Intake (`OperationalPhase.morningIntake`)**:
   Active ticket intake for 30-day tourist visa extensions (Counter 1), re-entry permits (Counter 2), and long-term Non-Immigrant extensions (Counter 3), with a real-time FIFO Next Queue buffer and Counter 4 batch deliveries.
3. **Lunch Break (`OperationalPhase.lunchBreak`)**:
   Counters paused from 12:00 to 13:00. Shows countdown and status notices in Thai and English. Active desks remain frozen in place with subtle "ON HOLD" badges.
4. **Afternoon Pickup (`OperationalPhase.afternoonPickup`)**:
   New visa extension submissions close. Active calls transition to "MORNING INTAKE CLOSED" informational advisory while Counter 4 (Passport Delivery) enters peak collection mode.

---

## 3. Kinetic & Acoustic Engineering

- **Web Audio Singleton (`web/index.html` & `SoundService`)**:
  - Eliminates the browser limit of 6 active `AudioContext` instances by maintaining a lazy singleton.
  - Generates a high-clarity 3-tone harmonic chime (F Major arpeggio: F5 698.46 Hz, A5 880.00 Hz, C6 1046.50 Hz) using Web Audio API synthesis.
  - Automatically unlocks audio on the first user interaction (pointerdown, keydown, touchstart) in compliance with modern browser autoplay policies.
- **Micro-Interactions (`lib/widgets/motion_primitives.dart`)**:
  - `FidsPanelTransition`: Seamless crossfade with gentle vertical entry offset.
  - `PulsingGlowCard`: Multi-layered ambient breathing aura (0.0 to 1.0 sine curve) highlighting newly called tickets.
  - `AnimatedDigitText`: Rolling vertical slide transitions on digit updates.
  - `BlinkingDot`: Rhythmic optical beacon for live synchronization and status feeds.

---

## 4. Operator Simulator & Keyboard Shortcuts

The bottom floating toolbar acts as an operator dispatch simulator, allowing desk officers and demonstration leads to manipulate queue states instantly.

| Shortcut | Action | Description |
|:---:|:---|:---|
| `[Space]` | **CALL NEXT** | Calls next ticket in queue (round-robin across Desks 1–3) with harmonic chime |
| `[1]` / `Num 1` | **CALL DESK 1** | Calls next tourist visa extension (`A`) directly to Counter 1 |
| `[2]` / `Num 2` | **CALL DESK 2** | Calls next re-entry permit (`C`) directly to Counter 2 |
| `[3]` / `Num 3` | **CALL DESK 3** | Calls next long-term visa extension (`D`) directly to Counter 3 |
| `[B]` | **BATCH READY** | Releases a new ready passport batch to Counter 4 (FIFO capped at 3) |
| `[A]` | **AUTO DEMO** | Toggles autonomous realistic immigration queue simulation (7.5s intervals) |
| `[T]` | **CYCLE PHASE** | Steps through the 4 operational phases (Morning -> Lunch -> Afternoon -> Morning) |
| `[C]` | **CLEAR QUEUE** | Flushes active queue to idle standby ("Counter Available") |
| `[R]` | **RESET QUEUE** | Restores realistic morning peak benchmark data |
| `[M]` | **MUTE AUDIO** | Toggles audible chime alerts |

---

## 5. Development & Verification Protocol

### Static Analysis
```bash
dart analyze
```
*Expected: 0 issues found.*

### Automated Test Suite
```bash
flutter test
```
*Executes unit and widget tests across state transitions, desk calling, batch capping, hotkey dispatches, and 1920x1080 viewport rendering without RenderFlex overflows.*

### Web Release Build
```bash
flutter build web --release
```
*Output directory: `build/web/`*

---

## 6. Netlify Deployment

The project is pre-configured for continuous deployment on Netlify:
- **Build command**: `flutter build web --release`
- **Publish directory**: `build/web`
- **Single Page App Routing**: `web/_redirects` contains `/* /index.html 200` to ensure deep links and reloads resolve cleanly.
