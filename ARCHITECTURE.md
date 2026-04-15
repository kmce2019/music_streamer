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
