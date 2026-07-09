import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WaveformBackground extends StatefulWidget {
  final Widget child;
  const WaveformBackground({super.key, required this.child});

  @override
  State<WaveformBackground> createState() => _WaveformBackgroundState();
}

class _WaveformBackgroundState extends State<WaveformBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<double> _seeds = List.generate(28, (i) => Random(i).nextDouble());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.bg, Color(0xFF150F28), AppColors.bg],
            ),
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: _BarsPainter(_controller.value, _seeds),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _BarsPainter extends CustomPainter {
  final double t;
  final List<double> seeds;
  _BarsPainter(this.t, this.seeds);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final barWidth = size.width / seeds.length;
    for (var i = 0; i < seeds.length; i++) {
      final phase = (t * 2 * pi) + seeds[i] * 2 * pi;
      final amp = 0.10 + 0.10 * (0.5 + 0.5 * sin(phase));
      final h = size.height * amp * (0.4 + seeds[i] * 0.6);
      final opacity = 0.05 + 0.05 * seeds[i];
      paint.color = (i.isEven ? AppColors.signal : AppColors.gold)
          .withOpacity(opacity);
      final rect = Rect.fromLTWH(
        i * barWidth,
        size.height - h,
        barWidth * 0.6,
        h,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter oldDelegate) => true;
}
