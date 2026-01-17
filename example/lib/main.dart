import 'dart:math';

import 'package:flutter/material.dart';

import 'config/image_config.dart';
import 'models/image_post.dart';
import 'pages/basic_flexbox_page.dart';
import 'pages/cat_gallery_page.dart';
import 'pages/delegates_showcase_page.dart';
import 'pages/dynamic_flexbox_page.dart';
import 'pages/network_image_gallery_page.dart';
import 'pages/playground_page.dart';
import 'pages/scalable_flexbox_page.dart';
import 'pages/sliver_flexbox_page.dart';
import 'theme/neo_brutalism.dart';

void main() {
  runApp(const FlexboxExampleApp());
}

class FlexboxExampleApp extends StatelessWidget {
  const FlexboxExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flexbox',
      debugShowCheckedModeBanner: false,
      theme: NeoBrutalism.themeData(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SourceType _selectedSource = ImageConfig.currentSource;

  static const List<_ExampleItem> _examples = [
    _ExampleItem(
      title: 'Basic Flexbox',
      subtitle: 'Flexbox properties playground',
      icon: Icons.grid_view_rounded,
      color: NeoBrutalism.yellow,
      page: BasicFlexboxPage(),
    ),
    _ExampleItem(
      title: 'Cat Gallery',
      subtitle: 'Local images with aspect ratios',
      icon: Icons.pets_rounded,
      color: NeoBrutalism.pink,
      page: CatGalleryPage(),
    ),
    _ExampleItem(
      title: 'Sliver Flexbox',
      subtitle: 'CustomScrollView integration',
      icon: Icons.view_agenda_rounded,
      color: NeoBrutalism.green,
      page: SliverFlexboxPage(),
    ),
    _ExampleItem(
      title: 'Scalable Flexbox',
      subtitle: 'Pinch-to-zoom grid like Google Photos',
      icon: Icons.pinch_rounded,
      color: NeoBrutalism.cyan,
      page: ScalableFlexboxPage(),
    ),
    _ExampleItem(
      title: 'Network Gallery',
      subtitle: 'API-resolved image dimensions',
      icon: Icons.cloud_download_rounded,
      color: NeoBrutalism.blue,
      page: NetworkImageGalleryPage(),
    ),
    _ExampleItem(
      title: 'Dynamic Flexbox',
      subtitle: 'Auto-measuring sliver layout',
      icon: Icons.auto_fix_high_rounded,
      color: NeoBrutalism.purple,
      page: DynamicFlexboxPage(),
    ),
    _ExampleItem(
      title: 'Delegates',
      subtitle: 'All delegate types showcase',
      icon: Icons.dashboard_rounded,
      color: NeoBrutalism.grey,
      page: DelegatesShowcasePage(),
    ),
    _ExampleItem(
      title: 'Playground',
      subtitle: 'Interactive configuration',
      icon: Icons.science_rounded,
      color: NeoBrutalism.red,
      page: PlaygroundPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: BoxDecoration(
                color: NeoBrutalism.yellow,
                border: Border(
                  bottom: BorderSide(
                    color: NeoBrutalism.black,
                    width: NeoBrutalism.borderWidth,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: NeoBrutalism.shapeDecoration(
                          color: NeoBrutalism.black,
                          hasShadow: false,
                        ),
                        child: const Text(
                          'FLUTTER PACKAGE',
                          style: TextStyle(
                            color: NeoBrutalism.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _ConfigButton(
                        currentSource: _selectedSource,
                        onSourceChanged: (source) {
                          setState(() {
                            _selectedSource = source;
                            ImageConfig.currentSource = source;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 4, bottom: 4),
                    decoration: NeoBrutalism.shapeDecoration(
                      color: NeoBrutalism.pink,
                      hasShadow: true,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 6,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: NeoBrutalism.shapeDecoration(
                              color: NeoBrutalism.white,
                              radius: 12,
                              hasShadow: false,
                            ),
                            child: Transform.rotate(
                              angle: pi / 2,
                              child: Icon(Icons.dashboard_rounded, size: 22),
                            ),
                          ),
                          Text(
                            'Flexbox',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'CSS Flexbox layout for Flutter',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: NeoBrutalism.black.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = _examples[index];
                return _ExampleCard(item: item);
              }, childCount: _examples.length),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 280,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                mainAxisExtent: 140,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _ExampleItem {
  const _ExampleItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.page,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget page;
}

class _ExampleCard extends StatefulWidget {
  const _ExampleCard({required this.item});

  final _ExampleItem item;

  @override
  State<_ExampleCard> createState() => _ExampleCardState();
}

class _ExampleCardState extends State<_ExampleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => widget.item.page),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
          _isPressed ? NeoBrutalism.shadowOffset.dx : 0,
          _isPressed ? NeoBrutalism.shadowOffset.dy : 0,
          0,
        ),
        decoration: NeoBrutalism.shapeDecoration(
          color: widget.item.color,
          hasShadow: !_isPressed,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: NeoBrutalism.shapeDecoration(
                      color: NeoBrutalism.white,
                      radius: 8,
                      hasShadow: false,
                    ),
                    child: Icon(widget.item.icon, size: 22),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: NeoBrutalism.black.withValues(alpha: 0.5),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                widget.item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.item.subtitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: NeoBrutalism.black.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfigButton extends StatefulWidget {
  const _ConfigButton({
    required this.currentSource,
    required this.onSourceChanged,
  });

  final SourceType currentSource;
  final ValueChanged<SourceType> onSourceChanged;

  @override
  State<_ConfigButton> createState() => _ConfigButtonState();
}

class _ConfigButtonState extends State<_ConfigButton> {
  bool _isPressed = false;

  void _showSourceSelector() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SourceSelectorSheet(
        currentSource: widget.currentSource,
        onSourceChanged: (source) {
          widget.onSourceChanged(source);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sourceColor = _getSourceColor(widget.currentSource);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: _showSourceSelector,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
          _isPressed ? NeoBrutalism.shadowOffset.dx : 0,
          _isPressed ? NeoBrutalism.shadowOffset.dy : 0,
          0,
        ),
        decoration: NeoBrutalism.shapeDecoration(
          color: sourceColor,
          radius: 12,
          hasShadow: !_isPressed,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getSourceDisplayName(widget.currentSource),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.settings_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSourceColor(SourceType source) {
    switch (source) {
      case SourceType.yande:
        return NeoBrutalism.pink;
      case SourceType.zerochan:
        return NeoBrutalism.blue;
      case SourceType.nekosia:
        return NeoBrutalism.purple;
      case SourceType.konachan:
        return NeoBrutalism.yellow;
    }
  }

  String _getSourceDisplayName(SourceType source) {
    switch (source) {
      case SourceType.yande:
        return 'yande';
      case SourceType.zerochan:
        return 'zerochan';
      case SourceType.nekosia:
        return 'nekosia';
      case SourceType.konachan:
        return 'konachan';
    }
  }
}

class _SourceSelectorSheet extends StatelessWidget {
  const _SourceSelectorSheet({
    required this.currentSource,
    required this.onSourceChanged,
  });

  final SourceType currentSource;
  final ValueChanged<SourceType> onSourceChanged;

  static const List<_SourceOption> _sourceOptions = [
    _SourceOption(
      source: SourceType.yande,
      name: 'yande',
      color: NeoBrutalism.pink,
      icon: Icons.image_rounded,
    ),
    _SourceOption(
      source: SourceType.zerochan,
      name: 'zerochan',
      color: NeoBrutalism.blue,
      icon: Icons.collections_rounded,
    ),
    _SourceOption(
      source: SourceType.nekosia,
      name: 'nekosia',
      color: NeoBrutalism.purple,
      icon: Icons.photo_library_rounded,
    ),
    _SourceOption(
      source: SourceType.konachan,
      name: 'konachan',
      color: NeoBrutalism.yellow,
      icon: Icons.photo_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: NeoBrutalism.cream,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: NeoBrutalism.black,
            width: NeoBrutalism.borderWidth,
          ),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: NeoBrutalism.circleDecoration(
                    color: NeoBrutalism.orange,
                  ),
                  child: const Icon(Icons.settings_rounded, size: 24),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Image Source',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ..._sourceOptions.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SourceOptionCard(
                  option: option,
                  isSelected: option.source == currentSource,
                  onTap: () => onSourceChanged(option.source),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SourceOption {
  const _SourceOption({
    required this.source,
    required this.name,
    required this.color,
    required this.icon,
  });

  final SourceType source;
  final String name;
  final Color color;
  final IconData icon;
}

class _SourceOptionCard extends StatefulWidget {
  const _SourceOptionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _SourceOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_SourceOptionCard> createState() => _SourceOptionCardState();
}

class _SourceOptionCardState extends State<_SourceOptionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
          _isPressed ? NeoBrutalism.shadowOffset.dx : 0,
          _isPressed ? NeoBrutalism.shadowOffset.dy : 0,
          0,
        ),
        decoration: NeoBrutalism.shapeDecoration(
          color: widget.option.color,
          hasShadow: !_isPressed,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: NeoBrutalism.shapeDecoration(
                  color: NeoBrutalism.white,
                  radius: 12,
                  hasShadow: false,
                ),
                child: Icon(widget.option.icon, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.option.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (widget.isSelected)
                Container(
                  width: 32,
                  height: 32,
                  decoration: NeoBrutalism.circleDecoration(
                    color: NeoBrutalism.green,
                  ),
                  child: const Icon(Icons.check_rounded, size: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
