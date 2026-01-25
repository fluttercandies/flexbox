import 'package:easy_refresh/easy_refresh.dart';
import 'package:example/config/image_config.dart';
import 'package:example/models/image_post.dart';
import 'package:example/sources/image_source_factory.dart';
import 'package:flexbox_layout/flexbox_layout.dart';
import 'package:flutter/material.dart';

import '../shared/cache_image.dart';
import '../shared/safe_state_mixin.dart';
import '../theme/neo_brutalism.dart';
import '../widgets/neo_easy_refresh.dart';
import '../widgets/neo_widgets.dart';
import '../widgets/scale_scroll_coordinator.dart';

/// A page demonstrating the scalable flexbox with pinch-to-zoom functionality.
///
/// This page shows a Google Photos-like grid that can be zoomed with pinch
/// gestures or by using the zoom buttons in the app bar.
///
/// Features:
/// - Pinch-to-zoom to change grid size smoothly with spring physics
/// - Double-tap to toggle between snap points
/// - Pull-to-refresh to reload images
/// - Load more when scrolling to bottom
/// - Mode switching: aspect ratio mode ↔ 1:1 grid mode
/// - Snap-to-grid animations with momentum
class ScalableFlexboxPage extends StatefulWidget {
  const ScalableFlexboxPage({super.key});

  @override
  State<ScalableFlexboxPage> createState() => _ScalableFlexboxPageState();
}

class _ScalableFlexboxPageState extends State<ScalableFlexboxPage>
    with TickerProviderStateMixin, SafeStateMixin {
  late final EasyRefreshController _refreshController;
  late final FlexboxScaleController _scaleController;
  late final ScrollController _scrollController;

  final List<ImagePost> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;
  bool _useSliverVersion = false;

  static const int _postsPerPage = 30;

  /// Mode threshold: when extent <= this value, switch to 1:1 grid mode.
  static const double _gridModeThreshold = 90;

  /// Returns true if the current extent indicates 1:1 grid mode.
  bool get _isGridMode => _scaleController.currentExtent <= _gridModeThreshold;

  @override
  void initState() {
    super.initState();
    _refreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );

    _scrollController = ScrollController();

    _scaleController = FlexboxScaleController(
      initialExtent: 160.0,
      minExtent: 60.0,
      maxExtent: 280.0,
      enableSnap: false, // Disable snap for smoother, more responsive scaling
    );

    _scaleController.attachTickerProvider(this);
    // No longer need to add listener for setState - using ListenableBuilder instead

    _loadPosts();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts({bool isRefresh = false}) async {
    if (_isLoading) return;
    if (!isRefresh && !_hasMore) return;

    setSafeState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final page = isRefresh ? 1 : _currentPage;
      final source = ImageSourceFactory.create(ImageConfig.currentSource);
      final newPosts = await source.fetchPosts(
        page: page,
        limit: _postsPerPage,
      );

      if (newPosts.isEmpty) {
        setSafeState(() {
          _hasMore = false;
          _isLoading = false;
        });
        return;
      }

      setSafeState(() {
        if (isRefresh) {
          _posts.clear();
          _currentPage = 1;
          _hasMore = true;
        }
        _posts.addAll(newPosts);
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setSafeState(() {
        _error = 'Load error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadPosts(isRefresh: true);
    _refreshController.finishRefresh();
    _refreshController.resetFooter();
  }

  Future<void> _onLoad() async {
    await _loadPosts();
    _refreshController.finishLoad(
      _hasMore ? IndicatorResult.success : IndicatorResult.noMore,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeoAppBar(
        title: 'Scalable Gallery',
        color: NeoBrutalism.cyan,
        actions: [
          ListenableBuilder(
            listenable: _scaleController,
            builder: (context, _) => NeoIconButton(
              icon: Icons.zoom_out_rounded,
              onPressed: _scaleController.canZoomIn
                  ? () => _scaleController.zoomIn()
                  : null,
              size: 40,
            ),
          ),
          const SizedBox(width: 4),
          ListenableBuilder(
            listenable: _scaleController,
            builder: (context, _) => NeoIconButton(
              icon: Icons.zoom_in_rounded,
              onPressed: _scaleController.canZoomOut
                  ? () => _scaleController.zoomOut()
                  : null,
              size: 40,
            ),
          ),
          const SizedBox(width: 4),
          NeoIconButton(
            icon: _useSliverVersion
                ? Icons.view_list_rounded
                : Icons.grid_view_rounded,
            onPressed: () {
              setSafeState(() {
                _useSliverVersion = !_useSliverVersion;
              });
            },
            size: 40,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          ListenableBuilder(
            listenable: _scaleController,
            builder: (context, _) => _buildInfoBar(_isGridMode),
          ),
          Expanded(child: _buildGalleryContainer()),
        ],
      ),
    );
  }

  Widget _buildGalleryContainer() {
    if (_error != null && _posts.isEmpty) {
      return _buildErrorState();
    }

    if (_posts.isEmpty && _isLoading) {
      return _buildLoadingState();
    }

    return ListenableBuilder(
      listenable: _scaleController,
      builder: (context, _) {
        final isGridMode = _isGridMode;
        return _useSliverVersion
            ? _buildSliverVersion(isGridMode)
            : _buildListVersion(isGridMode);
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: NeoBrutalism.circleDecoration(
                color: NeoBrutalism.red,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: NeoBrutalism.black.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            NeoButton.text(
              onPressed: _onRefresh,
              text: 'Try Again',
              color: NeoBrutalism.yellow,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: NeoBrutalism.circleDecoration(color: NeoBrutalism.cyan),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: NeoBrutalism.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading...',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBar(bool isGridMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: NeoBrutalism.white,
        border: Border(
          bottom: BorderSide(
            color: NeoBrutalism.black,
            width: NeoBrutalism.borderWidth,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: NeoBrutalism.shapeDecoration(
                  color: _useSliverVersion
                      ? NeoBrutalism.purple
                      : NeoBrutalism.cyan,
                  radius: 6,
                  hasShadow: false,
                ),
                child: Text(
                  _useSliverVersion ? 'SLIVER' : 'LIST',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: NeoBrutalism.shapeDecoration(
                  color: isGridMode ? NeoBrutalism.orange : NeoBrutalism.green,
                  radius: 6,
                  hasShadow: false,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isGridMode
                          ? Icons.grid_on_rounded
                          : Icons.auto_awesome_mosaic_rounded,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isGridMode ? '1:1 GRID' : 'ASPECT RATIO',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_posts.length} images',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: NeoBrutalism.black.withValues(alpha: 0.6),
                ),
              ),
              const Spacer(),
              Text(
                '${_scaleController.currentExtent.round()}px',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: NeoBrutalism.black.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.zoom_out_rounded, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: NeoBrutalism.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: NeoBrutalism.black, width: 1.5),
                  ),
                  child: Stack(
                    children: [
                      // Progress bar fill
                      FractionallySizedBox(
                        widthFactor: _scaleController.normalizedScale.clamp(
                          0.0,
                          1.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isGridMode
                                ? NeoBrutalism.orange
                                : NeoBrutalism.cyan,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      // Mode switch threshold marker
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final thresholdFraction =
                              (_gridModeThreshold -
                                  _scaleController.minExtent) /
                              (_scaleController.maxExtent -
                                  _scaleController.minExtent);
                          return Positioned(
                            left: constraints.maxWidth * thresholdFraction - 1,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 2,
                              color: NeoBrutalism.orange,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.zoom_in_rounded, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListVersion(bool isGridMode) {
    final aspectRatios = isGridMode
        ? List.filled(_posts.length, 1.0)
        : _posts.map((p) => p.aspectRatio).toList();

    // Use DirectExtent with fillFactor for smooth transitions
    // fillFactor: 0.0 = During scaling, items sized by targetExtent, gaps at row end possible
    // fillFactor: 1.0 = After scaling, items fill entire row
    final flexboxDelegate = SliverFlexboxDelegateWithDirectExtent(
      aspectRatios: aspectRatios,
      targetExtent: _scaleController.currentExtent,
      fillFactor: _scaleController.fillFactor,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
    );

    return ScaleScrollCoordinator(
      onScaleStart: _scaleController.onScaleStart,
      onScaleUpdate: _scaleController.onScaleUpdate,
      onScaleEnd: _scaleController.onScaleEnd,
      onDoubleTap: _scaleController.onDoubleTap,
      debugOwner: this,
      builder: (context, state) {
        return EasyRefresh(
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoad: _onLoad,
          header: const NeoBrutalismHeader(),
          footer: const NeoBrutalismFooter(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: state.isScaling
                ? const NeverScrollableScrollPhysics()
                : null,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(2),
                sliver: SliverFlexbox(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ScalableImageItem(
                      post: _posts[index],
                      index: index,
                      isGridMode: isGridMode,
                    ),
                    childCount: _posts.length,
                  ),
                  flexboxDelegate: flexboxDelegate,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverVersion(bool isGridMode) {
    final aspectRatios = isGridMode
        ? List.filled(_posts.length, 1.0)
        : _posts.map((p) => p.aspectRatio).toList();

    // Use DirectExtent with fillFactor for smooth transitions
    // fillFactor: 0.0 = During scaling, items sized by targetExtent, gaps at row end possible
    // fillFactor: 1.0 = After scaling, items fill entire row
    final flexboxDelegate = SliverFlexboxDelegateWithDirectExtent(
      aspectRatios: aspectRatios,
      targetExtent: _scaleController.currentExtent,
      fillFactor: _scaleController.fillFactor,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
    );

    return ScaleScrollCoordinator(
      onScaleStart: _scaleController.onScaleStart,
      onScaleUpdate: _scaleController.onScaleUpdate,
      onScaleEnd: _scaleController.onScaleEnd,
      onDoubleTap: _scaleController.onDoubleTap,
      debugOwner: this,
      builder: (context, state) {
        return EasyRefresh(
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoad: _onLoad,
          header: const NeoBrutalismHeader(),
          footer: const NeoBrutalismFooter(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: state.isScaling
                ? const NeverScrollableScrollPhysics()
                : null,
            slivers: [
              SliverToBoxAdapter(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(12),
                  decoration: NeoBrutalism.shapeDecoration(
                    color: isGridMode
                        ? NeoBrutalism.orange
                        : NeoBrutalism.yellow,
                    hasShadow: false,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isGridMode
                            ? Icons.grid_on_rounded
                            : Icons.info_outline_rounded,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isGridMode
                              ? '1:1 Grid Mode - All images shown as squares'
                              : 'Aspect Ratio Mode - Images preserve original proportions',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(2),
                sliver: SliverFlexbox(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ScalableImageItem(
                      post: _posts[index],
                      index: index,
                      isGridMode: isGridMode,
                    ),
                    childCount: _posts.length,
                  ),
                  flexboxDelegate: flexboxDelegate,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScalableImageItem extends StatelessWidget {
  const _ScalableImageItem({
    required this.post,
    required this.index,
    required this.isGridMode,
  });

  final ImagePost post;
  final int index;
  final bool isGridMode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: NeoBrutalism.white),
      child: Image(
        image: CacheImage(post.imageUrl),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: NeoBrutalism.grey,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: NeoBrutalism.black,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: NeoBrutalism.grey,
            child: const Icon(Icons.broken_image_rounded, size: 24),
          );
        },
      ),
    );
  }
}
