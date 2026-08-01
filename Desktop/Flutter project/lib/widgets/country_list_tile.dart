import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/country.dart';
import '../models/bucket_list_item.dart';
import '../controllers/providers.dart';
import 'package:go_router/go_router.dart';

class CountryListTile extends StatefulWidget {
  final Country country;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? cardColor;
  final BorderSide? borderSide;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final int index;

  const CountryListTile({
    Key? key,
    required this.country,
    this.trailing,
    this.onTap,
    this.cardColor,
    this.borderSide,
    this.titleStyle,
    this.subtitleStyle,
    this.index = 0,
  }) : super(key: key);

  @override
  State<CountryListTile> createState() => _CountryListTileState();
}

class _CountryListTileState extends State<CountryListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _tapScale;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    // Tap Animation: brief scale down to 0.98 and return to 1.0
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _tapScale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Pastel gradient combinations for cards
    final List<List<Color>> pastelGradients = [
      // Light lavender + soft blue
      [const Color(0xFFF3E8FF).withOpacity(0.7), const Color(0xFFE0F2FE).withOpacity(0.7)],
      // Light blue + soft pink
      [const Color(0xFFE0F2FE).withOpacity(0.7), const Color(0xFFFCE7F3).withOpacity(0.7)],
      // Soft pink + lavender
      [const Color(0xFFFCE7F3).withOpacity(0.7), const Color(0xFFF3E8FF).withOpacity(0.7)],
      // Mint + light cyan
      [const Color(0xFFD1FAE5).withOpacity(0.7), const Color(0xFFE0F2FE).withOpacity(0.7)],
      // Very light peach + lavender
      [const Color(0xFFFFEDD5).withOpacity(0.7), const Color(0xFFF3E8FF).withOpacity(0.7)],
    ];

    final List<Color> pastelBorders = [
      const Color(0xFFC084FC), // Pastel Purple
      const Color(0xFF60A5FA), // Pastel Blue
      const Color(0xFFF472B6), // Pastel Pink
      const Color(0xFF34D399), // Pastel Mint
      const Color(0xFFFB923C), // Pastel Orange
    ];

    final gradientPair = pastelGradients[widget.index % pastelGradients.length];
    final accentBorderColor = pastelBorders[widget.index % pastelBorders.length];

    final cardGradient = isDark
        ? LinearGradient(
            colors: [
              const Color(0xFF1E293B).withOpacity(0.85),
              const Color(0xFF0F172A).withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: _isHovered
                ? [gradientPair[1], gradientPair[0]] // Shift gradient gently on hover
                : gradientPair,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final borderColor = _isHovered
        ? accentBorderColor.withOpacity(0.8)
        : (isDark ? Colors.white10 : accentBorderColor.withOpacity(0.3));

    final shadowColor = _isHovered
        ? accentBorderColor.withOpacity(0.25)
        : (isDark ? Colors.black26 : accentBorderColor.withOpacity(0.08));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => _tapController.forward(),
          onTapUp: (_) {
            _tapController.reverse();
            if (widget.onTap != null) {
              widget.onTap!();
            } else {
              context.push('/country', extra: widget.country);
            }
          },
          onTapCancel: () => _tapController.reverse(),
          child: AnimatedBuilder(
            animation: _tapScale,
            builder: (context, child) {
              return Transform.scale(
                scale: _tapScale.value,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  transform: _isHovered
                      ? (Matrix4.identity()
                        ..translate(0.0, -5.0) // Hover moves up 4-6px smoothly
                        ..scale(1.015)) // Scale slightly to 1.015
                      : Matrix4.identity(),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: _isHovered ? 18 : 10,
                        offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          gradient: cardGradient,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: borderColor,
                            width: _isHovered ? 1.8 : 1.2,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            splashColor: accentBorderColor.withOpacity(0.12),
                            highlightColor: accentBorderColor.withOpacity(0.05),
                            onTap: null, // Handled by GestureDetector for scale physics
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  // Avatar Animation
                                  Hero(
                                    tag: 'flag-${widget.country.name}',
                                    child: AnimatedScale(
                                      scale: _isHovered ? 1.06 : 1.0, // Gently scales up on hover
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeOutCubic,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: _isHovered ? accentBorderColor : Colors.white,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: accentBorderColor.withOpacity(_isHovered ? 0.35 : 0.1),
                                              blurRadius: _isHovered ? 10 : 4,
                                              spreadRadius: _isHovered ? 1 : 0,
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(30),
                                          child: CachedNetworkImage(
                                            imageUrl: widget.country.flag,
                                            width: 52,
                                            height: 52,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              width: 52,
                                              height: 52,
                                              color: Colors.white.withOpacity(0.2),
                                            ),
                                            errorWidget: (context, url, error) =>
                                                const Icon(Icons.flag, size: 28, color: Color(0xFF64748B)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Country Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.country.name,
                                          style: widget.titleStyle ??
                                              TextStyle(
                                                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                letterSpacing: -0.3,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.country.capital.isEmpty ? 'No Capital' : widget.country.capital,
                                          style: widget.subtitleStyle ??
                                              TextStyle(
                                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Heart Favorite Button + Arrow
                                  Consumer(
                                    builder: (context, ref, child) {
                                      final bucketList = ref.watch(bucketListProvider);
                                      final isFavorite = bucketList.any((item) => item.country.name == widget.country.name);

                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                              color: isFavorite ? const Color(0xFFEC4899) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                              size: 22,
                                            ),
                                            tooltip: 'Add to Favorites',
                                            onPressed: () async {
                                              if (!isFavorite) {
                                                await ref.read(bucketListProvider.notifier).addOrUpdate(
                                                  BucketListItem(country: widget.country),
                                                );
                                              }
                                              if (context.mounted) {
                                                context.push('/bucket-list');
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 2),
                                          widget.trailing ??
                                              AnimatedContainer(
                                                duration: const Duration(milliseconds: 250),
                                                curve: Curves.easeOutCubic,
                                                transform: _isHovered
                                                    ? (Matrix4.identity()..translate(3.5, 0.0)) // Moves 3-4px to the right
                                                    : Matrix4.identity(),
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _isHovered
                                                      ? accentBorderColor.withOpacity(0.2)
                                                      : (isDark ? Colors.white10 : Colors.white.withOpacity(0.6)),
                                                ),
                                                child: Icon(
                                                  Icons.arrow_forward_ios_rounded,
                                                  size: 14,
                                                  color: _isHovered
                                                      ? accentBorderColor
                                                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                                ),
                                              ),
                                        ],
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
      ),
    );
  }
}
