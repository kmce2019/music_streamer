use std::{
    collections::{HashMap, HashSet},
    net::SocketAddr,
    path::{Path, PathBuf},
    sync::Arc,
};

use axum::{
    extract::{Path as AxumPath, State},
    http::{header, HeaderValue, StatusCode},
    response::{Html, IntoResponse, Response},
    routing::{get, post},
    Json, Router,
};
use serde::{Deserialize, Serialize};
use tokio::{fs, sync::RwLock};
use tower_http::{cors::CorsLayer, services::ServeDir, trace::TraceLayer};
use tracing::{info, warn};
use uuid::Uuid;
use walkdir::WalkDir;

#[derive(Clone)]
struct AppState {
    inner: Arc<RwLock<LibraryState>>,
}

#[derive(Default)]
struct LibraryState {
    tracks: Vec<Track>,
    artists: Vec<Artist>,
    albums: Vec<Album>,
    queue: PlaybackQueue,
}

#[derive(Debug, Clone, Serialize)]
struct Track {
    id: String,
    title: String,
    artist_id: String,
    album_id: String,
    path: String,
}

#[derive(Debug, Clone, Serialize)]
struct Artist {
    id: String,
    name: String,
}

#[derive(Debug, Clone, Serialize)]
struct Album {
    id: String,
    title: String,
    artist_id: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
struct PlaybackQueue {
    track_ids: Vec<String>,
    current_index: usize,
    shuffle: bool,
    repeat: String,
}

#[derive(Debug, Deserialize)]
struct ScanRequest {
    roots: Vec<String>,
}

#[derive(Debug, Serialize)]
struct ScanResponse {
    scanned_files: usize,
    imported_tracks: usize,
    artists: usize,
    albums: usize,
}

#[derive(Debug, Deserialize)]
struct QueueRequest {
    track_ids: Vec<String>,
    current_index: Option<usize>,
    shuffle: Option<bool>,
    repeat: Option<String>,
}

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt()
        .with_env_filter(
            std::env::var("RUST_LOG")
                .unwrap_or_else(|_| "music_streamer_service=info,tower_http=info".to_string()),
        )
        .init();

    let state = AppState {
        inner: Arc::new(RwLock::new(LibraryState::default())),
    };

    let app = Router::new()
        .route("/api/health", get(health))
        .route("/api/library/scan", post(scan_library))
        .route("/api/library/tracks", get(get_tracks))
        .route("/api/library/artists", get(get_artists))
        .route("/api/library/albums", get(get_albums))
        .route("/api/playback/queue", get(get_queue).post(set_queue))
        .route("/api/stream/:id", get(stream_track))
        .route("/", get(index_html))
        .nest_service("/web", ServeDir::new("server/web"))
        .with_state(state)
        .layer(CorsLayer::permissive())
        .layer(TraceLayer::new_for_http());

    let port = std::env::var("MUSIC_STREAMER_PORT")
        .ok()
        .and_then(|v| v.parse::<u16>().ok())
        .unwrap_or(8787);
    let addr: SocketAddr = ([0, 0, 0, 0], port).into();

    info!("music_streamer_service listening on http://{}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn health() -> impl IntoResponse {
    Json(serde_json::json!({"ok": true}))
}

async fn scan_library(
    State(state): State<AppState>,
    Json(payload): Json<ScanRequest>,
) -> Result<Json<ScanResponse>, (StatusCode, String)> {
    if payload.roots.is_empty() {
        return Err((StatusCode::BAD_REQUEST, "roots cannot be empty".to_string()));
    }

    let mut files_scanned = 0;
    let mut imported_tracks = 0;

    let mut tracks: Vec<Track> = Vec::new();
    let mut artists_map: HashMap<String, Artist> = HashMap::new();
    let mut albums_map: HashMap<String, Album> = HashMap::new();

    let mut seen_paths = HashSet::new();

    for root in payload.roots {
        let root_path = PathBuf::from(root);
        if !root_path.exists() {
            warn!("scan root does not exist: {}", root_path.display());
            continue;
        }

        for entry in WalkDir::new(&root_path)
            .into_iter()
            .filter_map(Result::ok)
            .filter(|e| e.file_type().is_file())
        {
            let path = entry.into_path();
            let Some(ext) = path.extension().and_then(|e| e.to_str()) else {
                continue;
            };
            let ext = ext.to_ascii_lowercase();
            if !matches!(ext.as_str(), "mp3" | "m4a" | "flac" | "wav" | "ogg") {
                continue;
            }
            files_scanned += 1;

            let normalized_path = path.to_string_lossy().to_string();
            if !seen_paths.insert(normalized_path.clone()) {
                continue;
            }

            let meta = parse_metadata(&path);

            let artist_id = stable_id("artist", &meta.artist);
            let album_id = stable_id("album", &format!("{}::{}", meta.artist, meta.album));

            artists_map.entry(artist_id.clone()).or_insert(Artist {
                id: artist_id.clone(),
                name: meta.artist,
            });
            albums_map.entry(album_id.clone()).or_insert(Album {
                id: album_id.clone(),
                title: meta.album,
                artist_id: artist_id.clone(),
            });

            tracks.push(Track {
                id: Uuid::new_v4().to_string(),
                title: meta.title,
                artist_id,
                album_id,
                path: normalized_path,
            });
            imported_tracks += 1;
        }
    }

    let mut guard = state.inner.write().await;
    guard.tracks = tracks;
    guard.artists = artists_map.into_values().collect();
    guard.albums = albums_map.into_values().collect();

    if guard.queue.current_index >= guard.queue.track_ids.len() {
        guard.queue.current_index = 0;
    }

    Ok(Json(ScanResponse {
        scanned_files: files_scanned,
        imported_tracks,
        artists: guard.artists.len(),
        albums: guard.albums.len(),
    }))
}

async fn get_tracks(State(state): State<AppState>) -> impl IntoResponse {
    let guard = state.inner.read().await;
    Json(guard.tracks.clone())
}

async fn get_artists(State(state): State<AppState>) -> impl IntoResponse {
    let guard = state.inner.read().await;
    Json(guard.artists.clone())
}

async fn get_albums(State(state): State<AppState>) -> impl IntoResponse {
    let guard = state.inner.read().await;
    Json(guard.albums.clone())
}

async fn get_queue(State(state): State<AppState>) -> impl IntoResponse {
    let guard = state.inner.read().await;
    Json(guard.queue.clone())
}

async fn set_queue(
    State(state): State<AppState>,
    Json(payload): Json<QueueRequest>,
) -> Result<Json<PlaybackQueue>, (StatusCode, String)> {
    let mut guard = state.inner.write().await;

    let valid_track_ids: HashSet<&str> = guard.tracks.iter().map(|t| t.id.as_str()).collect();
    if payload
        .track_ids
        .iter()
        .any(|id| !valid_track_ids.contains(id.as_str()))
    {
        return Err((
            StatusCode::BAD_REQUEST,
            "queue contains unknown track id".to_string(),
        ));
    }

    let current_index = payload.current_index.unwrap_or(0);
    let bounded_index = if payload.track_ids.is_empty() {
        0
    } else {
        current_index.min(payload.track_ids.len() - 1)
    };

    guard.queue = PlaybackQueue {
        track_ids: payload.track_ids,
        current_index: bounded_index,
        shuffle: payload.shuffle.unwrap_or(false),
        repeat: payload.repeat.unwrap_or_else(|| "off".to_string()),
    };

    Ok(Json(guard.queue.clone()))
}

async fn stream_track(
    State(state): State<AppState>,
    AxumPath(id): AxumPath<String>,
) -> Result<Response, (StatusCode, String)> {
    let track_path = {
        let guard = state.inner.read().await;
        guard
            .tracks
            .iter()
            .find(|t| t.id == id)
            .map(|t| t.path.clone())
            .ok_or((StatusCode::NOT_FOUND, "track not found".to_string()))?
    };

    let data = fs::read(&track_path).await.map_err(|e| {
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            format!("failed to read file: {e}"),
        )
    })?;

    let mut resp = Response::new(data.into());
    resp.headers_mut().insert(
        header::CONTENT_TYPE,
        HeaderValue::from_static(content_type_for_path(&track_path)),
    );
    Ok(resp)
}

async fn index_html() -> Html<&'static str> {
    Html(include_str!("../web/index.html"))
}

fn content_type_for_path(path: &str) -> &'static str {
    if path.ends_with(".mp3") {
        "audio/mpeg"
    } else if path.ends_with(".m4a") {
        "audio/mp4"
    } else if path.ends_with(".flac") {
        "audio/flac"
    } else if path.ends_with(".wav") {
        "audio/wav"
    } else if path.ends_with(".ogg") {
        "audio/ogg"
    } else {
        "application/octet-stream"
    }
}

#[derive(Debug)]
struct ParsedMeta {
    title: String,
    artist: String,
    album: String,
}

fn parse_metadata(path: &Path) -> ParsedMeta {
    let title_raw = path
        .file_stem()
        .and_then(|s| s.to_str())
        .unwrap_or("Unknown Track")
        .trim()
        .to_string();
    let album = path
        .parent()
        .and_then(|p| p.file_name())
        .and_then(|s| s.to_str())
        .unwrap_or("Unknown Album")
        .trim()
        .to_string();

    if let Some((artist, title)) = title_raw.split_once(" - ") {
        return ParsedMeta {
            title: title.trim().to_string(),
            artist: artist.trim().to_string(),
            album,
        };
    }

    ParsedMeta {
        title: title_raw,
        artist: "Unknown Artist".to_string(),
        album,
    }
}

fn stable_id(prefix: &str, value: &str) -> String {
    let mut hash: u64 = 1469598103934665603;
    for b in value.as_bytes() {
        hash ^= *b as u64;
        hash = hash.wrapping_mul(1099511628211);
    }
    format!("{prefix}-{hash}")
}
