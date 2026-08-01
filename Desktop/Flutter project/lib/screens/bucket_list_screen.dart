import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/providers.dart';
import '../utils/constants.dart';
import '../widgets/animated_background.dart';

class BucketListScreen extends ConsumerStatefulWidget {
  const BucketListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BucketListScreen> createState() => _BucketListScreenState();
}

class _BucketListScreenState extends ConsumerState<BucketListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _headerAnim;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerAnim.forward();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bucketList = ref.watch(sortedBucketListProvider);
    final isDark = ref.watch(isDarkModeProvider);
    final theme = Theme.of(context);

    // Color definitions matching the premium theme
    final textPrimaryColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondaryColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final cardBgColor = isDark ? const Color(0xFF1E293B).withOpacity(0.85) : Colors.white.withOpacity(0.8);
    final controlBgColor = isDark ? const Color(0xFF0F172A).withOpacity(0.6) : Colors.white.withOpacity(0.65);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFF0369A1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
          tooltip: 'Back to Home',
        ),
        title: Text(
          '❤️ My Bucket List',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              '${bucketList.length} saved',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withOpacity(0.75),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: AnimatedBackground(
        isDark: isDark,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 0,
              floating: false,
              pinned: false,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              flexibleSpace: const FlexibleSpaceBar(
                background: SizedBox.shrink(),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(102),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor.withOpacity(0.7),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        border: Border(
                          top: BorderSide(
                            color: isDark ? const Color(0xFF334155).withOpacity(0.5) : const Color(0xFFBAE6FD).withOpacity(0.5),
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Region dropdown ──────────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Region',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: textSecondaryColor,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                decoration: BoxDecoration(
                                  color: controlBgColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF0EA5E9).withOpacity(0.3),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: ref.watch(bucketListRegionProvider),
                                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0EA5E9), size: 18),
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF0EA5E9),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                    dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    items: AppConstants.regions
                                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                                        .toList(),
                                    onChanged: (val) => ref.read(bucketListRegionProvider.notifier).state = val!,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // ── Sort dropdown ────────────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sort by',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: textSecondaryColor,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                decoration: BoxDecoration(
                                  color: controlBgColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF0EA5E9).withOpacity(0.3),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: ref.watch(bucketListSortProvider),
                                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0EA5E9), size: 18),
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF0EA5E9),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                    dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    items: AppConstants.bucketSortOptions
                                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                        .toList(),
                                    onChanged: (val) => ref.read(bucketListSortProvider.notifier).state = val!,
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
          ],
          body: Column(
            children: [

              // ── Main list ────────────────────────────────────────────────
              Expanded(
                child: bucketList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0EA5E9).withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.flight_takeoff_rounded,
                                size: 64,
                                color: const Color(0xFF0EA5E9).withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Your bucket list is empty',
                              style: GoogleFonts.plusJakartaSans(
                                color: textPrimaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Start adding your dream destinations!',
                              style: GoogleFonts.plusJakartaSans(
                                color: textSecondaryColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 12, bottom: 32),
                        itemCount: bucketList.length,
                        itemBuilder: (context, index) {
                          final item = bucketList[index];
                          return _AnimatedBucketCard(
                            index: index,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: cardBgColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF334155).withOpacity(0.4) : const Color(0xFFBAE6FD).withOpacity(0.4),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF0284C7).withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => context.push('/country', extra: item.country),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              // Flag with styled frame
                                              Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: const Color(0xFF0EA5E9).withOpacity(0.2),
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: CachedNetworkImage(
                                                    imageUrl: item.country.flag,
                                                    width: 72,
                                                    height: 52,
                                                    fit: BoxFit.cover,
                                                    errorWidget: (context, url, error) => Container(
                                                      width: 72,
                                                      height: 52,
                                                      color: isDark ? const Color(0xFF1E293B) : Colors.grey[200],
                                                      child: Icon(Icons.flag, color: textSecondaryColor.withOpacity(0.5)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.country.name,
                                                      style: GoogleFonts.plusJakartaSans(
                                                        color: textPrimaryColor,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w800,
                                                        letterSpacing: -0.3,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.sticky_note_2_outlined,
                                                          size: 13,
                                                          color: Color(0xFF0EA5E9),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            item.notes.isNotEmpty ? item.notes : 'No notes written yet...',
                                                            style: GoogleFonts.plusJakartaSans(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w500,
                                                              color: item.notes.isEmpty
                                                                  ? textSecondaryColor.withOpacity(0.5)
                                                                  : textSecondaryColor,
                                                              fontStyle: item.notes.isEmpty ? FontStyle.italic : FontStyle.normal,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Delete action
                                              IconButton(
                                                icon: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.withOpacity(0.08),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.delete_outline_rounded,
                                                    color: Colors.red,
                                                    size: 18,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  ref.read(bucketListProvider.notifier).remove(item.country.name);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('${item.country.name} removed from your list'),
                                                      backgroundColor: const Color(0xFF0EA5E9),
                                                      behavior: SnackBarBehavior.floating,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedBucketCard extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedBucketCard({required this.index, required this.child});

  @override
  State<_AnimatedBucketCard> createState() => _AnimatedBucketCardState();
}

class _AnimatedBucketCardState extends State<_AnimatedBucketCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    final delay = Duration(milliseconds: (widget.index * 60).clamp(0, 600));
    Future.delayed(delay, () {
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
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}


