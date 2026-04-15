import 'package:equatable/equatable.dart';

enum RepeatMode { off, one, all }

class Track extends Equatable {
  const Track({
    required this.id,
    required this.title,
    required this.artistId,
    required this.albumId,
    required this.durationMs,
    required this.source,
    this.artworkUri,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String artistId;
  final String albumId;
  final int durationMs;
  final String source;
  final String? artworkUri;
  final bool isFavorite;

  Track copyWith({bool? isFavorite}) => Track(
        id: id,
        title: title,
        artistId: artistId,
        albumId: albumId,
        durationMs: durationMs,
        source: source,
        artworkUri: artworkUri,
        isFavorite: isFavorite ?? this.isFavorite,
      );

  @override
  List<Object?> get props => [id, title, artistId, albumId, durationMs, source, artworkUri, isFavorite];
}

class Album extends Equatable {
  const Album({required this.id, required this.title, required this.artistId, this.artworkUri});
  final String id;
  final String title;
  final String artistId;
  final String? artworkUri;
  @override
  List<Object?> get props => [id, title, artistId, artworkUri];
}

class Artist extends Equatable {
  const Artist({required this.id, required this.name});
  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

class Playlist extends Equatable {
  const Playlist({required this.id, required this.name, required this.trackIds, required this.createdAt});
  final String id;
  final String name;
  final List<String> trackIds;
  final DateTime createdAt;

  Playlist copyWith({String? name, List<String>? trackIds}) => Playlist(
        id: id,
        name: name ?? this.name,
        trackIds: trackIds ?? this.trackIds,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, name, trackIds, createdAt];
}

class RecentHistoryItem extends Equatable {
  const RecentHistoryItem({required this.trackId, required this.playedAt});
  final String trackId;
  final DateTime playedAt;

  @override
  List<Object?> get props => [trackId, playedAt];
}
