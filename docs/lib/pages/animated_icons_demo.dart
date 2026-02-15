import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_consts.dart';
import '../data/icons_data.dart' as icons_data;
import '../widgets/icon_card.dart';

class AnimatedIconsDemo extends StatefulWidget {
  const AnimatedIconsDemo({
    required this.themeMode,
    required this.onToggleThemeMode,
    super.key,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleThemeMode;

  @override
  State<AnimatedIconsDemo> createState() => _AnimatedIconsDemoState();
}

class _AnimatedIconsDemoState extends State<AnimatedIconsDemo> {
  static const double _gridMaxCrossAxisExtent = 170;
  static const double _gridSpacing = 16;
  static const double _buttonHeight = 30;

  final TextEditingController _searchController = TextEditingController();
  List<icons_data.IconEntry> _filteredIcons = [];

  List<icons_data.IconEntry> get _sortedIcons {
    final sorted = List<icons_data.IconEntry>.from(icons_data.icons);
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  @override
  void initState() {
    super.initState();
    _filteredIcons = _sortedIcons;
    _searchController.addListener(_filterIcons);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterIcons() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredIcons = _sortedIcons
          .where((icon) => icon.name.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${AppStrings.copiedToClipboardPrefix}$text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _copyIconCode(String iconName) async {
    await _copyToClipboard('${icons_data.toPascalIconName(iconName)}()');
  }

  Future<void> _openIconCode(String iconName) async {
    final url = '${AppStrings.reactSourceBaseUrl}$iconName.tsx';
    await _launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111111) : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildNavbar(isDark)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDescriptionSection(isDark),
                  const SizedBox(height: 24),
                  _buildInstallationSection(isDark),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(
                      color: isDark ? Colors.white12 : Colors.grey.shade200,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickySearchDelegate(
              child: _buildSearchSection(isDark),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _buildIconsGridSliver(isDark),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildNavbar(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF111111) : Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          Text(
            AppStrings.appBarTitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const Spacer(),
          _buildTextLinkContainer(
            AppStrings.sponsorLabel,
            AppStrings.sponsorUrl,
            isDark: isDark,
          ),
          _buildThemeToggleButton(isDark),
          _buildTextLinkContainer(
            AppStrings.githubLabel,
            AppStrings.githubUrl,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDescriptionText(AppStrings.description1, isDark),
        const SizedBox(height: 12),
        _buildDescriptionText(AppStrings.description2, isDark),
        const SizedBox(height: 12),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 4,
          children: [
            _buildDescriptionText(AppStrings.madeWith, isDark),
            _buildTextLinkContainer(
              AppStrings.flutterLabel,
              AppStrings.flutterUrl,
              isDark: isDark,
            ),
            _buildDescriptionText(AppStrings.and, isDark),
            _buildTextLinkContainer(
              AppStrings.heroiconsLabel,
              AppStrings.heroiconsUrl,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionText(String text, bool isDark) {
    return SelectableText(
      text,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
    );
  }

  Widget _buildInstallationSection(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => _copyToClipboard(AppStrings.installCommand),
                  child: Icon(
                    Icons.copy,
                    size: 16,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.installCommand,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildTextLinkContainer(
          AppStrings.pubDevLabel,
          AppStrings.pubDevUrl,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSearchSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 16,
            color: isDark ? Colors.white70 : Colors.grey.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    '${AppStrings.searchHintPrefix} ${icons_data.icons.length} icons',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey.shade500,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            InkWell(
              onTap: _searchController.clear,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.clear,
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconsGridSliver(bool isDark) {
    if (_filteredIcons.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Text(
              AppStrings.noIconsFound,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white60 : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      );
    }

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.crossAxisExtent / _gridMaxCrossAxisExtent)
            .floor()
            .clamp(1, 7);
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: _gridSpacing,
            mainAxisSpacing: _gridSpacing,
            childAspectRatio: 1,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final icon = _filteredIcons[index];
              return IconCard(
                name: icon.name,
                icon: icon.icon,
                isDark: isDark,
                onCopy: () => _copyIconCode(icon.name),
                onViewCode: () => _openIconCode(icon.name),
              );
            },
            childCount: _filteredIcons.length,
          ),
        );
      },
    );
  }

  Widget _buildTextLinkContainer(
    String text,
    String url, {
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(6),
      child: IntrinsicWidth(
        child: Container(
          constraints: const BoxConstraints(minHeight: _buttonHeight),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isDark ? Colors.white24 : Colors.grey),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggleButton(bool isDark) {
    final icon = switch (widget.themeMode) {
      ThemeMode.system => Icons.brightness_auto,
      ThemeMode.light => Icons.light_mode,
      ThemeMode.dark => Icons.dark_mode,
    };
    return InkWell(
      onTap: widget.onToggleThemeMode,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: _buttonHeight,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isDark ? Colors.white24 : Colors.grey),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class _StickySearchDelegate extends SliverPersistentHeaderDelegate {
  _StickySearchDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 64;

  @override
  double get maxExtent => 64;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isSticky = shrinkOffset > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF111111) : Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111111) : Colors.white,
          boxShadow: isSticky
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickySearchDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
