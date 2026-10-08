# Rapid Quiz — iOS

**English** · [Türkçe](README.tr.md)

Rapid Quiz is a fast, sign-up-free trivia game: pick a category, answer **20 questions** with **5 seconds** each, and the faster you answer correctly the more points you earn. At the end you only enter a **name** to join the category's **Top 10** leaderboard.

This repository is the native iOS client (Swift + SwiftUI). It talks to the same API as the web client (`RapidQuizBackend`, API v1). Scoring, timing and answer validation all happen on the server; the app only displays results.

## Screens

1. **Categories**: home screen with the category cards
2. **Game**: 3-2-1 countdown, 20 questions, countdown ring, instant feedback
3. **Result**: score, correct answers, total time, save with a name
4. **Leaderboard**: category picker, podium and Top 10

## Tech stack

| | |
| --- | --- |
| Language | Swift 6 (strict concurrency) |
| UI | SwiftUI, Observation (`@Observable`) |
| Minimum iOS | 17.0 (iPhone, portrait) |
| Networking | `URLSession` + `async/await` + `Codable` |
| Tests | Swift Testing, XCUITest |
| Dependencies | None |

## Getting started

Requirements: a Mac with Xcode 26 or later.

```bash
git clone https://github.com/busracankit/RapidQuiziOS.git
open RapidQuiziOS/RapidQuiz.xcodeproj
```

Pick an iPhone simulator and run (`⌘R`).

### API base URL

The base URL is set per build configuration and is not hard-coded:

| Configuration | File | Base URL |
| --- | --- | --- |
| Debug | `Config/Debug.xcconfig` | `http://localhost:8000` |
| Release | `Config/Release.xcconfig` | `https://rapidap.co` |

The value reaches the app through `Config/Info.plist` (`APIBaseURL`) and is read by `AppConfig.apiBaseURL`. In xcconfig files `//` starts a comment, so URLs are written as `http:/$()/host`.

### Running the backend locally

```bash
# in the RapidQuizBackend repository
uv run manage.py runserver 0.0.0.0:8000
```

- **Simulator:** `http://localhost:8000` works out of the box.
- **Physical iPhone (same Wi-Fi):** set `API_BASE_URL = http:/$()/<mac-name>.local:8000` in `Debug.xcconfig` and add `<mac-name>.local` to `DJANGO_ALLOWED_HOSTS` in the backend. iOS will ask for local network permission on first launch.

Only `localhost` and `.local` hosts are allowed over plain HTTP (`NSAllowsLocalNetworking`). All other traffic must use HTTPS.

## Project structure

```
Config/                 xcconfig files and Info.plist
RapidQuiz/
├── Config/             AppConfig (reads the base URL)
├── Design/             Color tokens, fonts
├── Resources/          Localizable.xcstrings, embedded fonts
├── Networking/         API client and models
├── Home/ Game/ Result/ Leaderboard/
└── Components/         Shared views
RapidQuizTests/         Unit tests (Swift Testing)
RapidQuizUITests/       UI tests
docs/                   Project specification (Turkish), font licenses
```

## Documentation

The full specification (API contract, timing rules, design tokens, UI copy and roadmap) is in [`docs/RapidQuiz-iOS-Proje-Dokumani.md`](docs/RapidQuiz-iOS-Proje-Dokumani.md) (Turkish).

The app UI is Turkish only. Code identifiers are in English; code comments are in Turkish.

## Fonts

[Space Grotesk](https://github.com/floriankarsten/space-grotesk) and [Plus Jakarta Sans](https://github.com/tokotype/PlusJakartaSans) are embedded under the SIL Open Font License 1.1. See [`docs/licenses/`](docs/licenses/).
