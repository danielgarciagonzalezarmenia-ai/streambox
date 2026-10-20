import 'season.dart';

class MediaItem {
  final String id;
  final String title;
  final String type; // 'movie' or 'series'
  final String genre;
  final String year;
  final String duration;
  final String rating;
  final String description;
  final String posterUrl;
  final String bannerUrl;
  final String? videoUrl; // for movies
  final List<String> categories;
  final List<Season> seasons; // for series

  const MediaItem({
    required this.id,
    required this.title,
    required this.type,
    required this.genre,
    required this.year,
    required this.duration,
    required this.rating,
    required this.description,
    required this.posterUrl,
    required this.bannerUrl,
    this.videoUrl,
    this.categories = const [],
    this.seasons = const [],
  });

  bool get isMovie => type.toLowerCase() == 'movie';
  bool get isSeries => type.toLowerCase() == 'series';

  int get totalEpisodes {
    if (isMovie) return 1;
    return seasons.fold(0, (sum, season) => sum + season.episodes.length);
  }

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    final rawCats = json['categories'] as List<dynamic>? ?? [];
    final rawSeasons = json['seasons'] as List<dynamic>? ?? [];

    return MediaItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Sin título',
      type: json['type'] as String? ?? 'movie',
      genre: json['genre'] as String? ?? 'General',
      year: json['year']?.toString() ?? '',
      duration: json['duration'] as String? ?? '',
      rating: json['rating']?.toString() ?? '5.0',
      description: json['description'] as String? ?? '',
      posterUrl: json['posterUrl'] as String? ?? '',
      bannerUrl: json['bannerUrl'] as String? ?? '',
      videoUrl: json['videoUrl'] as String?,
      categories: rawCats.map((c) => c.toString()).toList(),
      seasons: rawSeasons
          .whereType<Map<String, dynamic>>()
          .map((s) => Season.fromJson(s))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'genre': genre,
      'year': year,
      'duration': duration,
      'rating': rating,
      'description': description,
      'posterUrl': posterUrl,
      'bannerUrl': bannerUrl,
      if (videoUrl != null) 'videoUrl': videoUrl,
      'categories': categories,
      if (isSeries) 'seasons': seasons.map((s) => s.toJson()).toList(),
    };
  }
}
