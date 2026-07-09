import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/twist_api.dart';
import '../theme/app_theme.dart';

class AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final bool busy;
  const AchievementTile({super.key, required this.achievement, this.busy = false});

  @override
  Widget build(BuildContext context) {
    final done = achievement.rewarded;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: done ? AppColors.gold.withOpacity(0.35) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          _MiniEqualizer(active: done),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              achievement.name,
              style: GoogleFonts.tajawal(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (busy)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.signalSoft),
            )
          else
            Icon(
              done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: done ? AppColors.gold : AppColors.textSecondary,
              size: 22,
            ),
        ],
      ),
    );
  }
}

class _MiniEqualizer extends StatelessWidget {
  final bool active;
  const _MiniEqualizer({required this.active});

  @override
  Widget build(BuildContext context) {
    final heights = active ? [14.0, 22.0, 10.0, 26.0, 16.0] : [6.0, 9.0, 5.0, 10.0, 7.0];
    return SizedBox(
      width: 36,
      height: 28,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(5, (i) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 350 + i * 60),
            curve: Curves.easeOutBack,
            width: 4,
            height: heights[i],
            decoration: BoxDecoration(
              color: active ? AppColors.gold : AppColors.textSecondary.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
