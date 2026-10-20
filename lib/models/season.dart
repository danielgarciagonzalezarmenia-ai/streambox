import 'episode.dart';

class Season {
  final int seasonNumber;
  final String title;
  final List<Episode> episodes;

  const Season({
    required this.seasonNumber,
    required this.title,
    required this.episodes,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    final rawEpisodes = json['episodes'] as List<dynamic>? ?? [];
    return Season(
      seasonNumber: json['seasonNumber'] is int
          ? json['seasonNumber'] as int
          : int.tryParse(json['seasonNumber']?.toString() ?? '1') ?? 1,
      title: json['title'] as String? ?? 'Temporada ${json['seasonNumber'] ?? 1}',
      episodes: rawEpisodes
          .whereType<Map<String, dynamic>>()
          .map((e) => Episode.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seasonNumber': seasonNumber,
      'title': title,
      'episodes': episodes.map((e) => e.toJson()).toList(),
    };
  }
}
