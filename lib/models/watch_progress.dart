class WatchProgress {
  final String mediaId;
  final int? seasonNumber;
  final int? episodeNumber;
  final int positionSeconds;
  final int totalSeconds;
  final DateTime updatedAt;

  const WatchProgress({
    required this.mediaId,
    this.seasonNumber,
    this.episodeNumber,
    required this.positionSeconds,
    required this.totalSeconds,
    required this.updatedAt,
  });

  double get progressFraction {
    if (totalSeconds <= 0) return 0.0;
    return (positionSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  factory WatchProgress.fromJson(Map<String, dynamic> json) {
    return WatchProgress(
      mediaId: json['mediaId'] as String? ?? '',
      seasonNumber: json['seasonNumber'] as int?,
      episodeNumber: json['episodeNumber'] as int?,
      positionSeconds: json['positionSeconds'] is int
          ? json['positionSeconds'] as int
          : int.tryParse(json['positionSeconds']?.toString() ?? '0') ?? 0,
      totalSeconds: json['totalSeconds'] is int
          ? json['totalSeconds'] as int
          : int.tryParse(json['totalSeconds']?.toString() ?? '0') ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mediaId': mediaId,
      'seasonNumber': seasonNumber,
      'episodeNumber': episodeNumber,
      'positionSeconds': positionSeconds,
      'totalSeconds': totalSeconds,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
