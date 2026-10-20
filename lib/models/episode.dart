class Episode {
  final int episodeNumber;
  final String title;
  final String duration;
  final String description;
  final String posterUrl;
  final String videoUrl;

  const Episode({
    required this.episodeNumber,
    required this.title,
    required this.duration,
    required this.description,
    required this.posterUrl,
    required this.videoUrl,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episodeNumber: json['episodeNumber'] is int
          ? json['episodeNumber'] as int
          : int.tryParse(json['episodeNumber']?.toString() ?? '1') ?? 1,
      title: json['title'] as String? ?? 'Episodio',
      duration: json['duration'] as String? ?? '',
      description: json['description'] as String? ?? '',
      posterUrl: json['posterUrl'] as String? ?? '',
      videoUrl: json['videoUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'episodeNumber': episodeNumber,
      'title': title,
      'duration': duration,
      'description': description,
      'posterUrl': posterUrl,
      'videoUrl': videoUrl,
    };
  }
}
