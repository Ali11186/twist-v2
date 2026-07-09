import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CoinCounter extends StatelessWidget {
  final int balance;
  const CoinCounter({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: balance),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Column(
          children: [
            Text(
              'رصيدك من الكوينز',
              style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 6),
            ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                colors: [AppColors.goldSoft, AppColors.gold],
              ).createShader(rect),
              child: Text(
                '$value',
                style: GoogleFonts.cairo(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ),
            Text('كوينز', style: GoogleFonts.tajawal(color: AppColors.gold, fontSize: 15)),
          ],
        );
      },
    );
  }
}
