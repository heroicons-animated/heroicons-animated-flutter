import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heroicons_animated_docs/data/app_consts.dart';
import 'package:heroicons_animated_docs/data/icons_data.dart' as icons_data;
import 'package:heroicons_animated_docs/widgets/icon_card.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
  static const double _installControlHeight = 42;
  static const String _heartSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 21s-7.5-4.35-9.5-8.53C.64 8.59 2.43 4.5 6.31 4.5c2.2 0 3.38 1.08 4.19 2.32.81-1.24 1.99-2.32 4.19-2.32 3.88 0 5.67 4.09 3.81 7.97C19.5 16.65 12 21 12 21Z"/>
</svg>
''';
  static const String _githubSvg = '''
<svg viewBox="0 0 16 16" fill="currentColor">
  <path d="M8 0C3.58 0 0 3.65 0 8.15c0 3.6 2.29 6.66 5.47 7.74.4.08.55-.18.55-.4 0-.2-.01-.85-.01-1.54-2.01.38-2.53-.51-2.69-.98-.09-.24-.48-.98-.82-1.17-.28-.16-.68-.55-.01-.56.63-.01 1.08.59 1.23.83.72 1.24 1.87.89 2.33.68.07-.53.28-.89.5-1.09-1.78-.21-3.64-.92-3.64-4.08 0-.9.31-1.64.82-2.21-.08-.21-.36-1.05.08-2.18 0 0 .67-.22 2.2.84a7.35 7.35 0 0 1 2-.28c.68 0 1.37.1 2 .28 1.53-1.06 2.2-.84 2.2-.84.44 1.13.16 1.97.08 2.18.51.57.82 1.31.82 2.21 0 3.17-1.87 3.87-3.65 4.08.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .22.15.48.55.4A8.2 8.2 0 0 0 16 8.15C16 3.65 12.42 0 8 0Z"/>
</svg>
''';
  static const String _dartSvg = '''
<svg viewBox="0 0 256 256" preserveAspectRatio="xMidYMid"><defs><radialGradient id="dart__a" cx="50%" cy="50.002%" r="50.004%" fx="50%" fy="50.002%" gradientTransform="matrix(1 0 0 .99985 0 0)"><stop offset="0%" stop-color="#FFF" stop-opacity=".1"/><stop offset="100%" stop-color="#FFF" stop-opacity="0"/></radialGradient></defs><path fill="#01579B" d="M52.209 203.791 8.413 159.995C3.218 154.67 0 147.141 0 139.782c0-3.407 1.92-8.733 3.369-11.782l40.427-84.204 8.413 159.995Z"/><path fill="#40C4FF" d="M202.116 52.209 158.32 8.413C154.5 4.573 146.538 0 139.8 0c-5.796 0-11.48 1.167-15.15 3.369L43.815 43.796l158.301 8.413ZM104.418 256h106.111v-45.471l-79.16-25.276-72.422 25.276z"/><path fill="#29B6F6" d="M43.796 180.209c0 13.513 1.694 16.826 8.413 23.582l6.738 6.738h151.582l-74.097-84.204-92.636-82.53V180.21Z"/><path fill="#01579B" d="M178.534 43.777H43.796L210.529 210.51H256V106.093L202.097 52.19c-7.566-7.585-14.285-8.413-23.563-8.413Z"/><path fill="#FFF" d="M53.903 205.466c-6.738-6.756-8.413-13.419-8.413-25.257V45.47l-1.675-1.675v136.413c-.02 11.838-.02 15.113 10.088 25.257l5.044 5.044-5.044-5.044Z" opacity=".2"/><path fill="#263238" d="M254.325 104.418v104.417h-45.471l1.675 1.694H256V106.093z" opacity=".2"/><path fill="#FFF" d="M202.116 52.209c-8.356-8.357-15.188-8.413-25.257-8.413H43.815l1.675 1.675h131.369c5.025 0 17.71-.847 25.257 6.738Z" opacity=".2"/><path fill="url(#dart__a)" d="m254.325 104.418-52.209-52.21L158.32 8.414C154.5 4.573 146.538 0 139.8 0c-5.796 0-11.48 1.167-15.15 3.369L43.815 43.796 3.388 128c-1.45 3.068-3.37 8.394-3.37 11.782 0 7.359 3.238 14.868 8.414 20.213l40.351 40.07c.96 1.185 2.09 2.39 3.426 3.726l1.675 1.675 5.044 5.044 43.796 43.796 1.675 1.675H210.49v-45.47h45.471V106.092l-1.637-1.675Z" opacity=".2"/></svg>
''';

  final TextEditingController _searchController = TextEditingController();
  late final Future<int> _githubStarsFuture;
  List<icons_data.IconEntry> _filteredIcons = [];

  List<icons_data.IconEntry> get _sortedIcons {
    final sorted = List<icons_data.IconEntry>.from(icons_data.icons)
      ..sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  @override
  void initState() {
    super.initState();
    _githubStarsFuture = _fetchGithubStars();
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
      _filteredIcons =
          _sortedIcons
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

  bool _isMobileLayout(BuildContext context) {
    return MediaQuery.sizeOf(context).width <= AppStrings.mobileBreakpoint;
  }

  Future<int> _fetchGithubStars() async {
    final response = await http
        .get(
          Uri.parse(AppStrings.githubApiUrl),
          headers: const {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
          },
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception('GitHub API error: ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Unexpected GitHub response format');
    }
    final stars = decoded['stargazers_count'];
    if (stars is! int) {
      throw const FormatException('Missing stargazers_count in response');
    }
    return stars;
  }

  String _formatStars(int stars) {
    if (stars >= 1000000) {
      final value = stars / 1000000;
      final fraction = stars % 1000000 == 0 ? 0 : 1;
      return '${value.toStringAsFixed(fraction)}m';
    }
    if (stars >= 1000) {
      final value = stars / 1000;
      final fraction = stars % 1000 == 0 ? 0 : 1;
      return '${value.toStringAsFixed(fraction)}k';
    }
    return stars.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF141414) : const Color(0xFFF5F5F5),
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
    final isMobile = _isMobileLayout(context);
    return Container(
      color: isDark ? const Color(0xFF141414) : const Color(0xFFF5F5F5),
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
          _buildSponsorButton(isDark: isDark, iconOnly: isMobile),
          _buildThemeToggleButton(isDark),
          _buildGithubButton(isDark: isDark, iconOnly: isMobile),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(bool isDark) {
    final isMobile = _isMobileLayout(context);
    final linkButtons = [
      _buildTextLinkContainer(
        AppStrings.flutterLabel,
        AppStrings.flutterUrl,
        isDark: isDark,
        margin: EdgeInsets.zero,
      ),
      _buildTextLinkContainer(
        AppStrings.heroiconsLabel,
        AppStrings.heroiconsUrl,
        isDark: isDark,
        margin: EdgeInsets.zero,
      ),
      _buildTextLinkContainer(
        AppStrings.lucideInspiredLabel,
        AppStrings.lucideAnimatedUrl,
        isDark: isDark,
        margin: EdgeInsets.zero,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDescriptionText(AppStrings.description1, isDark),
        const SizedBox(height: 12),
        _buildDescriptionText(AppStrings.description2, isDark),
        const SizedBox(height: 12),
        if (isMobile) ...[
          _buildDescriptionText(AppStrings.madeWith, isDark),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: linkButtons,
          ),
        ] else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildDescriptionText(AppStrings.madeWith, isDark),
                const SizedBox(width: 8),
                ..._withHorizontalSpacing(linkButtons),
              ],
            ),
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
    final isMobile = _isMobileLayout(context);
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInstallCommandContainer(isDark: isDark, fullWidth: true),
          const SizedBox(height: 8),
          _buildPubDevButton(isDark: isDark, fullWidth: true),
        ],
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildInstallCommandContainer(isDark: isDark, fullWidth: false),
        _buildPubDevButton(isDark: isDark, fullWidth: false),
      ],
    );
  }

  Widget _buildSearchSection(bool isDark) {
    final searchHintText =
        '${AppStrings.searchHintPrefix} ${icons_data.icons.length} icons';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
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
                hintText: searchHintText,
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
        final crossAxisCount = (constraints.crossAxisExtent /
                _gridMaxCrossAxisExtent)
            .floor()
            .clamp(1, 7);
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: _gridSpacing,
            mainAxisSpacing: _gridSpacing,
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

  List<Widget> _withHorizontalSpacing(
    List<Widget> items, {
    double spacing = 8,
  }) {
    final spacedItems = <Widget>[];
    for (final item in items) {
      if (spacedItems.isNotEmpty) {
        spacedItems.add(SizedBox(width: spacing));
      }
      spacedItems.add(item);
    }
    return spacedItems;
  }

  Widget _buildInstallCommandContainer({
    required bool isDark,
    required bool fullWidth,
  }) {
    final textStyle = TextStyle(
      fontSize: 14,
      color: isDark ? Colors.white70 : Colors.black54,
    );

    final commandContent = Container(
      constraints: BoxConstraints(
        minHeight: _installControlHeight,
        maxWidth: fullWidth ? double.infinity : 460,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => _copyToClipboard(AppStrings.installCommand),
            child: Icon(
              Icons.copy,
              size: 16,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(width: 10),
          if (fullWidth)
            Expanded(
              child: Text(
                AppStrings.installCommand,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: textStyle,
              ),
            )
          else
            Text(
              AppStrings.installCommand,
              style: textStyle,
            ),
        ],
      ),
    );

    if (fullWidth) {
      return commandContent;
    }
    return IntrinsicWidth(child: commandContent);
  }

  Widget _buildPubDevButton({
    required bool isDark,
    required bool fullWidth,
  }) {
    return _buildLinkContainer(
      url: AppStrings.pubDevUrl,
      isDark: isDark,
      height: _installControlHeight,
      fullWidth: fullWidth,
      margin: EdgeInsets.zero,
      horizontalPadding: 14,
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSvgIcon(
            _dartSvg,
            isDark: isDark,
            size: 18,
            preserveColor: true,
          ),
          const SizedBox(width: 8),
          Text(
            AppStrings.pubDevLabel,
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorButton({
    required bool isDark,
    required bool iconOnly,
  }) {
    return _buildLinkContainer(
      url: AppStrings.sponsorUrl,
      isDark: isDark,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSvgIcon(_heartSvg, isDark: isDark, size: 14),
          if (!iconOnly) ...[
            const SizedBox(width: 6),
            Text(
              AppStrings.sponsorLabel,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGithubButton({
    required bool isDark,
    required bool iconOnly,
  }) {
    final textColor = isDark ? Colors.white : Colors.black;
    final mutedColor = isDark ? Colors.white70 : Colors.black54;
    return _buildLinkContainer(
      url: AppStrings.githubUrl,
      isDark: isDark,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSvgIcon(_githubSvg, isDark: isDark, size: 14),
          if (!iconOnly) ...[
            const SizedBox(width: 6),
            FutureBuilder<int>(
              future: _githubStarsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.githubLabel,
                        style: TextStyle(fontSize: 14, color: textColor),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.6,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  );
                }

                if (snapshot.hasError) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.githubLabel,
                        style: TextStyle(fontSize: 14, color: textColor),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.error_outline,
                        size: 14,
                        color: mutedColor,
                      ),
                    ],
                  );
                }

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.githubLabel,
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.star,
                      size: 14,
                      color: mutedColor,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _formatStars(snapshot.data ?? 0),
                      style: TextStyle(fontSize: 13, color: mutedColor),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSvgIcon(
    String svg, {
    required bool isDark,
    required double size,
    bool preserveColor = false,
  }) {
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      colorFilter:
          preserveColor
              ? null
              : ColorFilter.mode(
                isDark ? Colors.white : Colors.black,
                BlendMode.srcIn,
              ),
    );
  }

  Widget _buildLinkContainer({
    required String url,
    required bool isDark,
    required Widget child,
    double height = _buttonHeight,
    bool fullWidth = false,
    double horizontalPadding = 10,
    EdgeInsetsGeometry margin = const EdgeInsets.symmetric(horizontal: 4),
  }) {
    return InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: fullWidth ? double.infinity : null,
        height: height,
        margin: margin,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isDark ? Colors.white24 : Colors.grey),
        ),
        child: child,
      ),
    );
  }

  Widget _buildTextLinkContainer(
    String text,
    String url, {
    required bool isDark,
    EdgeInsetsGeometry margin = const EdgeInsets.symmetric(horizontal: 4),
  }) {
    return _buildLinkContainer(
      url: url,
      isDark: isDark,
      margin: margin,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black,
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
          color: isDark ? Colors.black : Colors.white,
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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isSticky = shrinkOffset > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: isDark ? const Color(0xFF141414) : const Color(0xFFF5F5F5),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141414) : const Color(0xFFF5F5F5),
          boxShadow:
              isSticky
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
