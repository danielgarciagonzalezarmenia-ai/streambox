import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../models/episode.dart';
import '../models/media_item.dart';
import '../models/watch_progress.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class PlayerScreen extends StatefulWidget {
  final MediaItem item;
  final Episode? initialEpisode;
  final int? initialPositionSeconds;
  final StorageService storageService;

  const PlayerScreen({
    super.key,
    required this.item,
    this.initialEpisode,
    this.initialPositionSeconds,
    required this.storageService,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showControls = true;
  Timer? _hideTimer;
  Timer? _progressSaveTimer;
  late Episode? _currentEpisode;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _currentEpisode = widget.initialEpisode;

    // Enable all orientations for playback
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);

    _initPlayer();
  }

  String _getVideoUrl() {
    if (widget.item.isMovie) {
      return widget.item.videoUrl ?? '';
    }
    if (_currentEpisode != null) {
      return _currentEpisode!.videoUrl;
    }
    if (widget.item.seasons.isNotEmpty &&
        widget.item.seasons.first.episodes.isNotEmpty) {
      _currentEpisode = widget.item.seasons.first.episodes.first;
      return _currentEpisode!.videoUrl;
    }
    return '';
  }

  Future<void> _initPlayer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = _getVideoUrl();
    if (url.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No hay URL de video configurada para este título.';
      });
      return;
    }

    try {
      final oldController = _controller;
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));

      await _controller!.initialize();

      // Seek to initial position if provided
      if (widget.initialPositionSeconds != null &&
          widget.initialPositionSeconds! > 0) {
        final target = Duration(seconds: widget.initialPositionSeconds!);
        if (target < _controller!.value.duration) {
          await _controller!.seekTo(target);
        }
      }

      await _controller!.play();
      _startHideTimer();
      _startProgressSaver();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      await oldController?.dispose();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'No se pudo reproducir el video. Verifica que la URL sea válida.\n$e';
        });
      }
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _controller != null && _controller!.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    }
  }

  void _startProgressSaver() {
    _progressSaveTimer?.cancel();
    _progressSaveTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => _saveCurrentProgress());
  }

  Future<void> _saveCurrentProgress() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final position = _controller!.value.position.inSeconds;
    final total = _controller!.value.duration.inSeconds;

    if (total > 0) {
      await widget.storageService.saveProgress(
        WatchProgress(
          mediaId: widget.item.id,
          seasonNumber: widget.item.isSeries ? 1 : null,
          episodeNumber: _currentEpisode?.episodeNumber,
          positionSeconds: position,
          totalSeconds: total,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  void _seekRelative(int seconds) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final current = _controller!.value.position;
    final target = current + Duration(seconds: seconds);
    final max = _controller!.value.duration;
    if (target < Duration.zero) {
      _controller!.seekTo(Duration.zero);
    } else if (target > max) {
      _controller!.seekTo(max);
    } else {
      _controller!.seekTo(target);
    }
    _startHideTimer();
  }

  void _changeEpisode(Episode ep) {
    _saveCurrentProgress();
    setState(() {
      _currentEpisode = ep;
    });
    _initPlayer();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _progressSaveTimer?.cancel();
    _saveCurrentProgress();
    _controller?.dispose();

    // Revert to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Video Surface
            Center(
              child: _controller != null && _controller!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : const SizedBox.shrink(),
            ),

            // Loading state
            if (_isLoading)
              const Center(
                child: CupertinoActivityIndicator(
                  radius: 18,
                  color: CupertinoColors.white,
                ),
              ),

            // Error state
            if (_errorMessage != null)
              Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xEE1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.exclamationmark_triangle_fill,
                        color: AppTheme.accentGlow,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Error de reproducción',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CupertinoButton(
                        color: AppTheme.accent,
                        onPressed: _initPlayer,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),

            // Controls Overlay
            if (_showControls && !_isLoading && _errorMessage == null)
              _buildControlsOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        color: const Color(0x66000000),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Bar
              _buildTopBar(),

              // Middle Playback Controls
              if (!_isLocked) _buildCenterControls(),

              // Bottom Scrubber Bar
              if (!_isLocked) _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0x66000000),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.chevron_back,
                color: CupertinoColors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (widget.item.isSeries && _currentEpisode != null)
                  Text(
                    'T1 : E${_currentEpisode!.episodeNumber} - ${_currentEpisode!.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),

          // Lock Controls button
          GestureDetector(
            onTap: () {
              setState(() {
                _isLocked = !_isLocked;
              });
              _startHideTimer();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isLocked ? AppTheme.accent : const Color(0x66000000),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isLocked
                    ? CupertinoIcons.lock_fill
                    : CupertinoIcons.lock_open,
                color: CupertinoColors.white,
                size: 20,
              ),
            ),
          ),

          // Series Episode Selector Button
          if (widget.item.isSeries && !_isLocked) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _showEpisodePickerModal,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x66000000),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.square_list,
                      color: CupertinoColors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Episodios',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCenterControls() {
    final isPlaying = _controller?.value.isPlaying ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Rewind 10s
        GestureDetector(
          onTap: () => _seekRelative(-10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0x55000000),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.gobackward_10,
              color: CupertinoColors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(width: 36),

        // Play / Pause
        GestureDetector(
          onTap: () {
            if (_controller != null) {
              if (isPlaying) {
                _controller!.pause();
              } else {
                _controller!.play();
              }
              setState(() {});
              _startHideTimer();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Color(0x88000000),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying
                  ? CupertinoIcons.pause_fill
                  : CupertinoIcons.play_arrow_solid,
              color: CupertinoColors.white,
              size: 44,
            ),
          ),
        ),
        const SizedBox(width: 36),

        // Forward 10s
        GestureDetector(
          onTap: () => _seekRelative(10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0x55000000),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.goforward_10,
              color: CupertinoColors.white,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final position = _controller!.value.position;
    final duration = _controller!.value.duration;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Slider Scrubber
          ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: _controller!,
            builder: (context, value, child) {
              final currentMs = value.position.inMilliseconds.toDouble();
              final totalMs = value.duration.inMilliseconds.toDouble();
              final safeCurrent = totalMs > 0 ? currentMs.clamp(0.0, totalMs) : 0.0;

              return SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3.5,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 12,
                  ),
                  activeTrackColor: AppTheme.accent,
                  inactiveTrackColor: const Color(0x44FFFFFF),
                  thumbColor: CupertinoColors.white,
                ),
                child: Slider(
                  value: safeCurrent,
                  min: 0.0,
                  max: totalMs > 0 ? totalMs : 1.0,
                  onChanged: (val) {
                    _startHideTimer();
                    _controller?.seekTo(Duration(milliseconds: val.toInt()));
                  },
                ),
              );
            },
          ),

          // Timestamps row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '-${_formatDuration(duration - position)}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEpisodePickerModal() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text('Episodios de ${widget.item.title}'),
          actions: [
            for (final season in widget.item.seasons)
              for (final ep in season.episodes)
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _changeEpisode(ep);
                  },
                  isDefaultAction: _currentEpisode?.episodeNumber == ep.episodeNumber,
                  child: Text(
                    'T${season.seasonNumber} : E${ep.episodeNumber} - ${ep.title} (${ep.duration})',
                  ),
                ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        );
      },
    );
  }
}
