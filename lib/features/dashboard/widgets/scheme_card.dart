// lib/features/dashboard/widgets/scheme_card.dart
import 'package:flutter/material.dart';
import 'package:bias_mitra/core/constants.dart';

class SchemeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final int index;
  final VoidCallback? onTap;

  const SchemeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Icon(
                icon,
                size: 48,
                color: AppColors.accentSaffron,
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryGreen,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              // Subtitle
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryBlueLight,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
