import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/episode.dart';
import '../models/media_item.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import 'player_screen.dart';

class DetailScreen extends StatefulWidget {
  final MediaItem item;
  final StorageService storageService;

  const DetailScreen({
    super.key,
    required this.item,
    required this.storageService,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isFavorite = false;
  int _selectedSeasonIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final fav = await widget.storageService.isFavorite(widget.item.id);
    if (mounted) {
      setState(() {
        _isFavorite = fav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    await widget.storageService.toggleFavorite(widget.item.id);
    _checkFavorite();
  }

  void _playVideo({Episode? episode}) {
    final progress = widget.storageService.getProgress(widget.item.id);
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => PlayerScreen(
          item: widget.item,
          initialEpisode: episode,
          initialPositionSeconds: progress?.positionSeconds,
          storageService: widget.storageService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seasons = widget.item.seasons;
    final currentSeason =
        seasons.isNotEmpty && _selectedSeasonIndex < seasons.length
            ? seasons[_selectedSeasonIndex]
            : null;

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      child: CustomScrollView(
        slivers: [
          // Cupertino Navigation Bar with Back button
          CupertinoSliverNavigationBar(
            largeTitle: const Text(''),
            backgroundColor: const Color(0xCC000000),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.chevron_back, color: CupertinoColors.white),
                  Text(
                    'Atrás',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Backdrop Image with Gradient
                Stack(
                  children: [
                    SizedBox(
                      height: 280,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: widget.item.bannerUrl.isNotEmpty
                            ? widget.item.bannerUrl
                            : widget.item.posterUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.surfaceElevated,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x33000000),
                              Color(0x99000000),
                              AppTheme.background,
                            ],
                            stops: [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Centered Play Button on Header
                    Positioned.fill(
                      child: Center(
                        child: GestureDetector(
                          onTap: () => _playVideo(),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xAA000000),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: CupertinoColors.white.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              CupertinoIcons.play_arrow_solid,
                              color: CupertinoColors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Title & Details Container
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: widget.item.isSeries
                              ? const Color(0xFF0A84FF)
                              : AppTheme.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.item.isSeries ? 'SERIE ORIGINAL' : 'PELÍCULA',
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        widget.item.title,
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Meta Row
                      Row(
                        children: [
                          Text(
                            widget.item.year,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.textMuted),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '4K HDR',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.item.duration,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.star_fill,
                                color: Color(0xFFFFD60A),
                                size: 13,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                widget.item.rating,
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Primary Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: CupertinoButton(
                              color: CupertinoColors.white,
                              borderRadius: BorderRadius.circular(10),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              onPressed: () => _playVideo(),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.play_arrow_solid,
                                    color: CupertinoColors.black,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Reproducir',
                                    style: TextStyle(
                                      color: CupertinoColors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // My List Toggle
                          GestureDetector(
                            onTap: _toggleFavorite,
                            child: GlassContainer(
                              padding: const EdgeInsets.all(12),
                              borderRadius: BorderRadius.circular(10),
                              child: Icon(
                                _isFavorite
                                    ? CupertinoIcons.check_mark
                                    : CupertinoIcons.add,
                                color: _isFavorite
                                    ? AppTheme.accentGlow
                                    : CupertinoColors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Synopsis
                      Text(
                        widget.item.description,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Genre tag
                      Text(
                        'Género: ${widget.item.genre}',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Series: Episodes Section
                if (widget.item.isSeries && currentSeason != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: AppTheme.divider),
                        const SizedBox(height: 12),
                        const Text(
                          'Episodios',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Seasons selector pills if multiple seasons
                        if (seasons.length > 1)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(seasons.length, (index) {
                                final isSelected = _selectedSeasonIndex == index;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedSeasonIndex = index;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.accent
                                          : AppTheme.surfaceElevated,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      seasons[index].title,
                                      style: TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        const SizedBox(height: 12),

                        // List of episodes
                        for (final episode in currentSeason.episodes)
                          _buildEpisodeTile(episode),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeTile(Episode episode) {
    return GestureDetector(
      onTap: () => _playVideo(episode: episode),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with Play overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 110,
                    height: 70,
                    color: AppTheme.surfaceElevated,
                    child: CachedNetworkImage(
                      imageUrl: episode.posterUrl.isNotEmpty
                          ? episode.posterUrl
                          : widget.item.posterUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          Container(color: AppTheme.surfaceElevated),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: const Color(0x33000000),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.play_circle_fill,
                        color: CupertinoColors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          episode.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (episode.duration.isNotEmpty)
                        Text(
                          episode.duration,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (episode.description.isNotEmpty)
                    Text(
                      episode.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
