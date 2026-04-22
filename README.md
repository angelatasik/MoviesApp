# 🎬 Movies App

A native iOS movie discovery app built with SwiftUI and UIKit, powered by [The Movie Database (TMDB)](https://www.themoviedb.org/) API.

Browse trending movies, search across movies and TV shows, explore detailed information including cast and genres, and save your favorites — all with offline support. The core business logic is extracted into a standalone Swift Package (`MoviesCore`) supporting iOS, iPadOS, tvOS, and macOS.

---

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Architecture](#architecture)
- [MoviesCore Package](#moviescore-package)
- [Project Structure](#project-structure)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Testing](#testing)
- [Author](#author)

---

## Features

### Core
- **Trending Movies** — Paginated list of trending movies with infinite scroll
- **Movie Details** — Backdrop, overview, cast, genres, rating, and runtime
- **Search** — Debounced search across movies and TV shows with type toggle
- **Custom Navigation** — Router pattern with programmatic navigation

### Bonus
- **Multi-Platform Core** — Business logic extracted into `MoviesCore` Swift Package supporting iOS, iPadOS, tvOS, and macOS
- **Favorites** — Mark movies as favorite, persisted with SwiftData
- **Offline Mode** — Cached trending and detail data available without internet
- **No-Connection Banner** — Global network status indicator
- **Adaptive Layouts** — Responsive design for iPhone, iPad, portrait, and landscape
- **Progressive Image Loading** — Low-res placeholders transition to high-res
- **Image Prefetching** — Content pre-cached concurrently for smooth experience
- **Dev/Prod Environments** — Separate schemes with `.xcconfig` configuration
- **Dark Theme** — Custom design system with gradients and typography

---

## Screenshots

| Trending | Details | Favorites |
|:---:|:---:|:---:|
| ![Trending](docs/screenshots/trending-movies-view.png) | ![Details](docs/screenshots/details-view.png) | ![Favourites](docs/screenshots/favourites-view.png) |

| Search | Search Results | TV Shows |
|:---:|:---:|:---:|
| ![Start Typing](docs/screenshots/start-typing-search.png) | ![Searching](docs/screenshots/searching-movies.png) | ![TV Shows](docs/screenshots/tvShows-search-result.png) |

| No Search Results | Offline Mode |
|:---:|:---:|
| ![NoResults](docs/screenshots/noResult-found-search.png) | ![Offline](docs/screenshots/offline-mode.png) |

---

## Architecture

The app follows **MVVM + Repository + Clean Architecture** with strict separation of concerns. The core business logic is packaged as a standalone, multi-platform Swift Package:

```
┌─────────────────────────────────────────┐
│     MoviesApp (iOS, SwiftUI + UIKit)    │
│   Views, ViewModels, Navigation, Theme  │
└────────────────┬────────────────────────┘
                 │ imports
                 ▼
┌─────────────────────────────────────────┐
│       MoviesCore (Swift Package)        │
│   iOS · iPadOS · tvOS · macOS support   │
└────────────────┬────────────────────────┘
                 │ contains
                 ▼
┌─────────────────────────────────────────┐
│         ViewModels (@Observable)        │
│     (TrendingViewModel, DetailVM...)    │
└────────────────┬────────────────────────┘
                 │ calls
                 ▼
┌─────────────────────────────────────────┐
│        Repositories (Protocols)         │
│   (MovieRepository, OfflineRepository)  │
└────────────────┬────────────────────────┘
                 │ uses
                 ▼
┌─────────────────────────────────────────┐
│       Network Layer + Cache Layer       │
│(URLSession, Interceptors, OfflineStore, │
│                SwiftData)               │
└─────────────────────────────────────────┘
```

### Key Patterns
- **Multi-Platform Package** — Core logic packaged as a Swift Package supporting four Apple platforms
- **Protocol-Based DI** — All dependencies injected via protocols for testability
- **Router Pattern** — Centralized navigation with `@Observable` + `NavigationPath`
- **Swift Concurrency** — `async/await`, actors, and `@MainActor` isolation
- **Repository Pattern** — Separates data source from business logic

---

## MoviesCore Package

`MoviesCore` is a standalone Swift Package that contains all platform-agnostic business logic. It can be consumed by any app across Apple platforms.

### Supported Platforms
- iOS 17+
- iPadOS 17+ (via iOS)
- tvOS 17+
- macOS 14+

### What's in the Package

```
MoviesCore/
├── Sources/
│   └── MoviesCore/
│       ├── Models/          # Movie, MovieDetail, Credits, TVShow, etc.
│       ├── Networking/      # NetworkClient, Endpoint, Interceptors
│       ├── Repositories/    # Protocol-based data access
│       ├── Cache/           # Image prefetching & offline store
│       ├── Storage/         # SwiftData models
│       ├── Helpers/         # DateFormatting and utilities
│       └── Views/           # Progressive image loading (cross-platform)
└── Package.swift
```

### Why Swift Package Manager?
I chose Swift Package Manager over a traditional `.xcframework` because:
- **Modern standard** — Apple's recommended approach for reusable code
- **Multi-platform native** — declarative platform support in `Package.swift`
- **Seamless integration** — works natively with Xcode
- **Flexible distribution** — can be used as a local dependency (as here) or published to a remote repository
- **Source-based** — easier to debug and maintain than binary frameworks

### Public API Design
Types exposed to consumers are explicitly marked `public` with public initializers, making the framework boundary clear and intentional. Internal implementation details remain `internal`.

---

## Project Structure

```
MoviesApp/
├── MoviesCore/                    # Multi-platform Swift Package
│   ├── Package.swift
│   └── Sources/
│       └── MoviesCore/
│           ├── Cache/
│           ├── Helpers/
│           ├── Models/
│           ├── Networking/
│           ├── Repositories/
│           ├── Storage/
│           └── Views/
│
├── MoviesApp/                     # Main iOS app
│   ├── Core/
│   │   ├── DI/                    # Dependency injection container
│   │   ├── Navigation/            # Router and AppRoute (SwiftUI-specific)
│   │   └── Views/                 # NoConnectionBanner (SwiftUI-specific)
│   ├── Features/
│   │   ├── Trending/              # UIKit collection view + SwiftUI wrapper
│   │   ├── Detail/
│   │   ├── Search/
│   │   └── Favorites/
│   ├── Theme/                     # Design system
│   └── MoviesAppApp.swift         # App entry point
│
├── MoviesAppTests/                # Unit tests
└── MoviesAppUITests/              # UI tests
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI (primary), UIKit via `UIViewRepresentable` |
| Language | Swift 6 with `@MainActor` default isolation |
| Concurrency | `async/await`, actors, structured concurrency |
| Networking | URLSession with custom interceptors |
| Persistence | SwiftData (favorites) + file-based JSON cache (offline) |
| Packaging | Swift Package Manager (local package for multi-platform core) |
| Image Loading | [Kingfisher](https://github.com/onevcat/Kingfisher) |
| Linting | SwiftLint |
| Testing | Swift Testing (unit) + XCTest (UI) |
| Environments | Dev / Prod via `.xcconfig` files |

---

## Getting Started

### Prerequisites
- Xcode 26.0+
- Swift 5.0+
- iOS 26.0+ simulator or device
- [TMDB API token](https://www.themoviedb.org/settings/api)

### Installation

1. **Clone the repository:**
```bash
   git clone https://github.com/angelatasik/MoviesApp.git
   cd MoviesApp
```

2. **Open the project:**
```bash
   open MoviesApp.xcodeproj
```
   Xcode will automatically resolve the `MoviesCore` local package dependency.

3. **(Optional) Configure signing for real device:**
   
   If you want to run the app on a physical iOS device, create a `Local.xcconfig` 
   file at the project root with your Apple Developer Team ID.
   This file is gitignored. Find your Team ID at 
   [developer.apple.com/account](https://developer.apple.com/account).
   
   For simulator testing, this step is not required — TMDB API credentials 
   are already configured in `Dev.xcconfig` and `Prod.xcconfig`.

4. **Install SwiftLint** (optional but recommended):
```bash
   brew install swiftlint
```

5. **Select a scheme:**
   - `MoviesApp-Dev` — Development configuration
   - `MoviesApp-Prod` — Production configuration

6. **Run:** `⌘R`

---

## Testing

The project achieves **~94% code coverage** on the framework target.

### Test Structure

```
MoviesAppTests/              # Unit tests (Swift Testing framework)
├── SearchViewModelTests     # 20+ tests — debounce, states, errors, pagination
└── NetworkErrorTests        # 11 tests — all error cases covered
```

```
MoviesAppUITests/            # UI tests (XCTest / XCUITest)
├── testOpenMovieDetailFromTrending
├── testSearchForMovie
├── testFavoritesFlow
└── testNoConnectionBannerAppearsWhenOffline
```

### Running Tests

- **All tests:** `⌘U`
- **Unit tests only:** Right-click `MoviesAppTests` in Test Navigator → Run
- **UI tests only:** Right-click `MoviesAppUITests` in Test Navigator → Run

### Testing Highlights
- **Async testing** with `Task.sleep` to verify debounce behavior
- **Protocol-based mocking** via `MockMovieRepository` and `MockImageConfigurationCache`
- **State machine coverage** — initial, loading, success, empty, and error states
- **Edge cases** — whitespace queries, cancellation errors, pagination boundaries
- **UI tests** with accessibility identifiers for stable selectors
- **Offline banner testing** with launch argument `-UITest_ForceOffline`

---

## Author

**Angela Tasikj**  

🌐 [GitHub](https://github.com/angelatasik/MoviesApp)

Built as part of an iOS technical assessment.
