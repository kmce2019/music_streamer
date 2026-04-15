# Music Streamer

A legally safer, production-minded, cross-platform music app inspired by modern local-first players.

## Key capabilities
- Flutter app shell with GoRouter navigation.
- BLoC/Cubit state management and strict layered architecture.
- Local music import from user-selected folders.
- Playback via `just_audio` with queue, seek, shuffle, repeat.
- Mini player + full now-playing screen.
- Search, favorites, playlists, history, theme settings.
- Plugin runtime with capability declarations and safety policy checks.
- Safe bundled plugin: internet radio directory.

## Legal and safety constraints
This project intentionally avoids scraping, DRM circumvention, ad bypassing, or unauthorized extraction from third-party services.

## Setup
1. Install Flutter stable (>=3.24).
2. Run:
   ```bash
   flutter pub get
   flutter run
   ```

## Test
```bash
flutter test
```

## Project docs
- [ARCHITECTURE.md](ARCHITECTURE.md)
- [ROADMAP.md](ROADMAP.md)
- [TODO.md](TODO.md)

## Rust helper placeholder
See `rust/` for optional performance/security helper integration points.
