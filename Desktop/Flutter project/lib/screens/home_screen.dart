import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../controllers/providers.dart';
import '../utils/constants.dart';
import '../widgets/country_list_tile.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/animated_background.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnim;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutCubic));
    _headerAnim.forward();
    _scrollController.addListener(_handlePaginationScroll);
  }

  void _handlePaginationScroll() {
    if (!_scrollController.hasClients) return;

    final threshold = _scrollController.position.maxScrollExtent - 180;
    if (_scrollController.position.pixels < threshold) return;

    final hasMore = ref.read(hasMoreCountriesProvider);
    if (!hasMore) return;

    ref.read(countriesPageProvider.notifier).state++;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handlePaginationScroll);
    _headerAnim.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncCountries = ref.watch(countriesProvider);
    final isDark = ref.watch(isDarkModeProvider);

    // Light Blue Theme Palette
    final Color pageBgColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF0F9FF);
    final Color textPrimaryColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final Color textSecondaryColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF475569);
    final Color primaryAccentColor = const Color(
      0xFF0284C7,
    ); // Vibrant modern light blue accent

    return Scaffold(
      backgroundColor: pageBgColor,
      body: AnimatedBackground(
        isDark: isDark,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 170,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: pageBgColor.withOpacity(0.95),
              elevation: 0,
              scrolledUnderElevation: 2,
              leading: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: _ElegantHoverActionButton(
                  icon: isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  iconColor: isDark
                      ? Colors.white
                      : const Color(0xFF0369A1),
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.75),
                  hoverColor: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white,
                  onTap: () =>
                      ref.read(isDarkModeProvider.notifier).state = !isDark,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _ElegantHoverActionButton(
                    icon: Icons.refresh_rounded,
                    iconColor: isDark
                        ? Colors.white
                        : const Color(0xFF0369A1),
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white.withOpacity(0.75),
                    hoverColor: isDark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white,
                    onTap: () {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                        );
                      }
                      ref.invalidate(countriesProvider);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _ElegantHoverActionButton(
                    icon: Icons.favorite_rounded,
                    iconColor: isDark
                        ? Colors.white
                        : const Color(0xFFEC4899),
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white.withOpacity(0.75),
                    hoverColor: isDark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white,
                    onTap: () => context.push('/bucket-list'),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '🌍 Country Explorer',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.plusJakartaSans(
                                            color: textPrimaryColor,
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.8,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Discover the world seamlessly',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: textSecondaryColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(136),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search Bar — stays pinned on scroll
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B).withOpacity(0.75)
                                  : Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFBAE6FD).withOpacity(0.9),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0284C7,
                                  ).withOpacity(0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search countries...',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  color: textSecondaryColor.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: primaryAccentColor,
                                ),
                                fillColor: Colors.transparent,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 16,
                                ),
                              ),
                              style: GoogleFonts.plusJakartaSans(
                                color: textPrimaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                              onChanged: (val) {
                                ref.read(searchQueryProvider.notifier).state =
                                    val;
                                ref.read(countriesPageProvider.notifier).state =
                                    1;
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Filter dropdowns
                      Row(
                        children: [
                          Expanded(
                            child: _FilterDropdown(
                              value: ref.watch(selectedRegionProvider),
                              icon: Icons.public_outlined,
                              items: AppConstants.regions,
                              onChanged: (val) {
                                ref
                                        .read(selectedRegionProvider.notifier)
                                        .state =
                                    val!;
                                ref.read(countriesPageProvider.notifier).state =
                                    1;
                              },
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _FilterDropdown(
                              value: ref.watch(sortOrderProvider),
                              icon: Icons.sort_rounded,
                              items: AppConstants.sortOptions,
                              onChanged: (val) {
                                ref.read(sortOrderProvider.notifier).state =
                                    val!;
                                ref.read(countriesPageProvider.notifier).state =
                                    1;
                              },
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: asyncCountries.when(
            data: (_) {
              final filteredCountries = ref.watch(filteredCountriesProvider);
              final visibleCountries = ref.watch(pagedCountriesProvider);
              final hasMore = ref.watch(hasMoreCountriesProvider);

              if (filteredCountries.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 72,
                        color: primaryAccentColor.withOpacity(0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No countries found',
                        style: GoogleFonts.plusJakartaSans(
                          color: textPrimaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your filters',
                        style: GoogleFonts.plusJakartaSans(
                          color: textSecondaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                color: primaryAccentColor,
                onRefresh: () async {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                    );
                  }
                  ref.read(countriesPageProvider.notifier).state = 1;
                  ref.invalidate(countriesProvider);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 32),
                  itemCount: visibleCountries.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= visibleCountries.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: primaryAccentColor,
                            ),
                          ),
                        ),
                      );
                    }

                    return _StaggeredAnimatedListItem(
                      index: index,
                      child: CountryListTile(
                        country: visibleCountries[index],
                        index: index,
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const ShimmerLoader(),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.wifi_off_rounded,
                        size: 48,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Oops! Something went wrong',
                      style: GoogleFonts.plusJakartaSans(
                        color: textPrimaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      err.toString(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryAccentColor,
                            primaryAccentColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: primaryAccentColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => ref.invalidate(countriesProvider),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            child: Text(
                              'Try Again',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helper Widgets ──────────────────────────────────────────────────────────

class _ElegantHoverActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color backgroundColor;
  final Color hoverColor;

  const _ElegantHoverActionButton({
    Key? key,
    required this.icon,
    required this.onTap,
    required this.iconColor,
    required this.backgroundColor,
    required this.hoverColor,
  }) : super(key: key);

  @override
  State<_ElegantHoverActionButton> createState() =>
      _ElegantHoverActionButtonState();
}

class _ElegantHoverActionButtonState extends State<_ElegantHoverActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isHovered ? widget.hoverColor : widget.backgroundColor,
              shape: BoxShape.circle,
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.hoverColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Icon(widget.icon, color: widget.iconColor, size: 20),
          ),
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final IconData icon;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool isDark;

  const _FilterDropdown({
    required this.value,
    required this.icon,
    required this.items,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final bgColor = isDark
        ? const Color(0xFF1E293B).withOpacity(0.75)
        : Colors.white.withOpacity(0.7);
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFBAE6FD);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              icon: Icon(icon, size: 18, color: const Color(0xFF0284C7)),
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              style: GoogleFonts.plusJakartaSans(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              items: items
                  .map(
                    (r) => DropdownMenuItem(
                      value: r,
                      child: Text(
                        r,
                        style: GoogleFonts.plusJakartaSans(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}

class _StaggeredAnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;
  const _StaggeredAnimatedListItem({required this.index, required this.child});

  @override
  State<_StaggeredAnimatedListItem> createState() =>
      _StaggeredAnimatedListItemState();
}

class _StaggeredAnimatedListItemState extends State<_StaggeredAnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _scale = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Staggered animation timing: 0ms, 80ms, 160ms, 240ms...
    final delayMs = (widget.index * 80).clamp(0, 600);
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
  }
}
