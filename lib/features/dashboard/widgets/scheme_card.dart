// lib/features/dashboard/widgets/scheme_card.dart
import 'package:flutter/material.dart';
import 'package:bias_mitra/core/constants.dart';

class SchemeCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final int index;
  final VoidCallback? onTap;

  /// Pass true for corporate cards, false for government cards.
  final bool isCorporate;

  const SchemeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.index,
    this.onTap,
    this.isCorporate = false,
  });

  @override
  State<SchemeCard> createState() => _SchemeCardState();
}

class _SchemeCardState extends State<SchemeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
    _elevationAnimation = Tween<double>(begin: 4.0, end: 14.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  // ── Returns gradient matching the scheme's sector & position ──────────────
  List<Color> _cardGradient() {
    if (widget.isCorporate) {
      // Corporate: slate → emerald green family
      final List<List<Color>> corpPalette = [
        [const Color(0xFF1F2937), AppColors.secondaryGreen],          // Hiring
        [const Color(0xFF065F46), const Color(0xFF10B981)],           // Promotions
        [const Color(0xFF374151), const Color(0xFF6EE7B7)],           // Credit
        [const Color(0xFF1E293B), const Color(0xFF34D399)],           // fallback
      ];
      return corpPalette[widget.index % corpPalette.length];
    } else {
      // Government: blue → saffron family
      final List<List<Color>> govPalette = [
        [AppColors.primaryBlue, AppColors.primaryBlueLight],          // PM-KISAN
        [const Color(0xFF065F46), AppColors.secondaryGreen],          // Scholarships
        [AppColors.accentSaffron, const Color(0xFFFF9F6B)],           // Bank Loans
        [const Color(0xFF7C3AED), const Color(0xFFA78BFA)],           // Ujjwala
      ];
      return govPalette[widget.index % govPalette.length];
    }
  }

  // ── Soft semi-transparent icon background tint ────────────────────────────
  Color _iconBgColor() => Colors.white.withOpacity(0.18);

  @override
  Widget build(BuildContext context) {
    final gradient = _cardGradient();

    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _hoverController.forward(),
        onTapUp: (_) => _hoverController.reverse(),
        onTapCancel: () => _hoverController.reverse(),
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withOpacity(0.4),
                      blurRadius: _elevationAnimation.value,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Icon bubble ──────────────────────────────────────────────
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _iconBgColor(),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 30,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 14),

                // ── Title ────────────────────────────────────────────────────
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // ── Subtitle ─────────────────────────────────────────────────
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.78),
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // ── Audit CTA chip ────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        widget.isCorporate ? 'Audit Now' : 'Run Audit',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
