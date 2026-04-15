# Music Streamer Architecture

## Current deployment model

### Preferred: Service + Web Player
- `server/` (Rust, axum): library scan, metadata indexing, streaming endpoints, queue state API.
- `server/web/` (HTML/JS): browser-based player UI consuming backend APIs.

### Legacy: Flutter client scaffold
- Existing Flutter app layers remain in `lib/` for future reuse.

## Service layers
- API layer: HTTP handlers (`/api/*`)
- Domain layer: track/artist/album + queue state
- Data layer: in-memory state store (replaceable with DB later)
- File layer: recursive scanner + file streaming for allowed media types

## API endpoints
- `GET /api/health`
- `POST /api/library/scan`
- `GET /api/library/tracks`
- `GET /api/library/artists`
- `GET /api/library/albums`
- `GET|POST /api/playback/queue`
- `GET /api/stream/:id`

## Legal/safety boundaries
- Local file playback + approved plugin model only.
- No DRM circumvention, stream ripping, ad bypass, or unauthorized source extraction.
## Principles
- Strict layered architecture: UI -> Cubits/Blocs -> Repositories/Services -> Persistence/Providers.
- Domain models (`Track`, `Album`, etc.) are used in state; storage entities stay inside persistence.
- Plugin system supports authorized sources only and includes policy checks.

## Folder Layout
```
lib/
  core/        # bootstrap, models, cache, events, theme, persistence
  blocs/       # feature state management
  repository/  # domain-facing repositories
  services/    # technical integrations (audio, import, search, settings)
  routes/      # GoRouter setup
  screens/     # UI pages and shell widgets
  plugins/     # contracts, runtime, safe example plugin
  l10n/        # localization scaffolding
```

## Data + Flow
1. UI widgets dispatch intent to Cubits.
2. Cubits call repositories and emit immutable domain-state snapshots.
3. Repositories coordinate services and persistence.
4. Services perform IO/audio/plugin validation.

## Caching
- Tier 1: in-memory LRU (`MemoryLruCache`).
- Tier 2: persistent state store (`InMemoryDb` now, replaceable with Isar/Drift).

## Plugin Lifecycle
1. Install manifest/bundle.
2. Validate checksum/signature stub.
3. Validate policy (deny dangerous permissions).
4. Register plugin + enable/disable state.
5. Store plugin settings in namespaced bucket.

## Rust Expansion Points
- Detached signature verification and cryptography in plugin runtime.
- Metadata parsing and waveform generation.
- Persistent cache indexing and high-throughput media scans.
