# Music Streamer

Music Streamer can now run in **server mode** and be accessed via a **web player**.

## What changed
- Added a Rust HTTP service (`server/`) for library scanning and media streaming.
- Added a web UI (`server/web/index.html`) served by the same backend.
- This is optimized for headless/server deployments where you access playback via browser.

## Server mode (recommended)

### Prerequisites
- Rust toolchain (`cargo`)
- Linux server with read access to your music folders

### Run
From repository root:

```bash
cd server
cargo run
```

Service starts on `http://0.0.0.0:8787` by default.

Configure port:

```bash
MUSIC_STREAMER_PORT=9090 cargo run
```

### Use
1. Open `http://<server-ip>:8787` in your browser.
2. Enter one or more scan roots (comma-separated), e.g. `/srv/music,/mnt/media/music`.
3. Click **Scan Library**.
4. Click any track to play in the browser audio player.

## API quick reference
- `GET /api/health`
- `POST /api/library/scan` with body `{ "roots": ["/music"] }`
- `GET /api/library/tracks`
- `GET /api/library/artists`
- `GET /api/library/albums`
- `GET|POST /api/playback/queue`
- `GET /api/stream/:id`

## Notes
- This service currently performs lightweight metadata extraction from file/folder names.
- Only local files are scanned/served.
- Plugin/legal constraints remain: no scraping/ripping unauthorized sources.

## Legacy Flutter client
The original Flutter client scaffold is still present in `lib/`, but server mode is now the preferred deployment shape for headless systems.
A legally safer, production-minded, cross-platform music app inspired by modern local-first players.


- Search, favorites, playlists, history, theme settings.
- Plugin runtime with capability declarations and safety policy checks.
- Safe bundled plugin: internet radio directory.


flutter test
```

## Project docs
- [ARCHITECTURE.md](ARCHITECTURE.md)
- [ROADMAP.md](ROADMAP.md)
- [TODO.md](TODO.md)

## Rust helper placeholder
See `rust/` for optional performance/security helper integration points.
