# DEWS — Disaster Early Warning System (iOS)

A conceptual disaster-preparedness app built with SwiftUI, designed "for all
humanity" with a focus on underserved, low-resource regions.

## Design principle: survival-first, offline-first

The app is built in layers that degrade gracefully. **Layer 1 — the only layer
here so far — runs fully offline on any phone, with no AI and no connectivity.**
It never fails to the network.

## Features (Layer 1)

- **Stay ready** — drip-fed survival tips and a personal readiness checklist
  (saved locally on the device).
- **Emergency** — large-button "what's happening" mode with step-by-step guidance
  for earthquake, flood, and wildfire.
- **Nearby help** — offline list of shelters, hospitals, water and power points.
  (Map view planned for a later version.)
- **Bilingual** — English / 中文, switchable in settings.

## Build

1. Open `DEWS.xcodeproj` in Xcode (15 or later).
2. Select an iOS simulator.
3. Press Run (Cmd+R).

All UI lives in `ContentView.swift`.

## Status

Conceptual student project, exploratory phase. Wording is framed as
"preparedness," not "emergency response" — this app is a guide, not a
replacement for official emergency services.

## Roadmap

- Real offline map with GPS distance + compass (MVP 2, tier-by-tier)
- Layer 2: public hazard data feeds
- Layer 3: Bluetooth / Wi-Fi Direct mesh
- Layer 4: optional on-device AI where device memory permits
