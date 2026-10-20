import 'package:flutter_test/flutter_test.dart';
import 'package:streambox/models/episode.dart';
import 'package:streambox/models/media_item.dart';
import 'package:streambox/models/season.dart';
import 'package:streambox/models/watch_progress.dart';

void main() {
  group('MediaItem & Model Tests', () {
    test('Movie MediaItem parsed correctly from JSON', () {
      final json = {
        'id': 'test-1',
        'title': 'Inception',
        'type': 'movie',
        'genre': 'Sci-Fi',
        'year': '2010',
        'duration': '2h 28m',
        'rating': '4.9',
        'description': 'A thief who steals corporate secrets through dream-sharing.',
        'posterUrl': 'https://example.com/poster.jpg',
        'bannerUrl': 'https://example.com/banner.jpg',
        'videoUrl': 'https://example.com/inception.mp4',
        'categories': ['Tendencias', 'Películas'],
      };

      final item = MediaItem.fromJson(json);

      expect(item.id, 'test-1');
      expect(item.title, 'Inception');
      expect(item.isMovie, true);
      expect(item.isSeries, false);
      expect(item.videoUrl, 'https://example.com/inception.mp4');
      expect(item.totalEpisodes, 1);
      expect(item.categories.length, 2);

      final exported = item.toJson();
      expect(exported['id'], 'test-1');
      expect(exported['title'], 'Inception');
      expect(exported['videoUrl'], 'https://example.com/inception.mp4');
    });

    test('Series MediaItem with Seasons & Episodes parsed correctly', () {
      final json = {
        'id': 'series-1',
        'title': 'Stranger Things',
        'type': 'series',
        'genre': 'Suspense',
        'year': '2024',
        'duration': '1 Temporada',
        'rating': '4.8',
        'description': 'Misterios en Hawkins.',
        'posterUrl': 'https://example.com/st_poster.jpg',
        'bannerUrl': 'https://example.com/st_banner.jpg',
        'categories': ['Series', 'Tendencias'],
        'seasons': [
          {
            'seasonNumber': 1,
            'title': 'Temporada 1',
            'episodes': [
              {
                'episodeNumber': 1,
                'title': 'Capítulo 1',
                'duration': '48m',
                'description': 'La desaparición...',
                'posterUrl': 'https://example.com/ep1.jpg',
                'videoUrl': 'https://example.com/ep1.mp4',
              },
              {
                'episodeNumber': 2,
                'title': 'Capítulo 2',
                'duration': '55m',
                'description': 'El monstruo...',
                'posterUrl': 'https://example.com/ep2.jpg',
                'videoUrl': 'https://example.com/ep2.mp4',
              },
            ],
          },
        ],
      };

      final item = MediaItem.fromJson(json);

      expect(item.id, 'series-1');
      expect(item.isSeries, true);
      expect(item.isMovie, false);
      expect(item.seasons.length, 1);
      expect(item.totalEpisodes, 2);

      final s1 = item.seasons.first;
      expect(s1.episodes.length, 2);
      expect(s1.episodes.first.title, 'Capítulo 1');
      expect(s1.episodes.first.videoUrl, 'https://example.com/ep1.mp4');
    });

    test('WatchProgress fraction calculations', () {
      final progress = WatchProgress(
        mediaId: 'test-1',
        positionSeconds: 120,
        totalSeconds: 240,
        updatedAt: DateTime.now(),
      );

      expect(progress.progressFraction, 0.5);

      final zeroTotal = WatchProgress(
        mediaId: 'test-2',
        positionSeconds: 50,
        totalSeconds: 0,
        updatedAt: DateTime.now(),
      );
      expect(zeroTotal.progressFraction, 0.0);
    });

    test('Season and Episode models JSON round-trip', () {
      const ep = Episode(
        episodeNumber: 1,
        title: 'Piloto',
        duration: '42m',
        description: 'Inicio',
        posterUrl: 'https://example.com/p.jpg',
        videoUrl: 'https://example.com/v.mp4',
      );

      const season = Season(
        seasonNumber: 1,
        title: 'T1',
        episodes: [ep],
      );

      final json = season.toJson();
      final fromJson = Season.fromJson(json);

      expect(fromJson.seasonNumber, 1);
      expect(fromJson.episodes.length, 1);
      expect(fromJson.episodes.first.title, 'Piloto');
    });
  });
}
