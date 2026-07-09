import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/twist_api.dart';
import '../theme/app_theme.dart';

class RedeemScreen extends StatefulWidget {
  final TwistApi api;
  final int balance;
  final VoidCallback onRedeemed;
  const RedeemScreen({
    super.key,
    required this.api,
    required this.balance,
    required this.onRedeemed,
  });

  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  String? _busyCode;
  String? _message;
  bool _messageOk = false;

  Future<void> _redeem(RedeemOption o) async {
    setState(() {
      _busyCode = o.code;
      _message = null;
    });
    final ok = await widget.api.redeem(o.code);
    if (!mounted) return;
    setState(() {
      _busyCode = null;
      _messageOk = ok;
      _message = ok ? 'تم سحب ${o.units} وحدة بنجاح' : 'فشلت عملية الاستبدال';
    });
    if (ok) widget.onRedeemed();
  }

  @override
  Widget build(BuildContext context) {
    final options = RedeemOption.availableFor(widget.balance);

    if (options.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'اجمع كوينز أكتر عشان تقدر تستبدل وحدات',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Column(
      children: [
        if (_message != null)
          Container(
            margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: (_messageOk ? AppColors.success : AppColors.danger).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _message!,
              style: TextStyle(color: _messageOk ? AppColors.success : AppColors.danger),
            ),
          ),
        Expanded(
          child: AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: options.length,
              itemBuilder: (context, i) {
                final o = options[i];
                final busy = _busyCode == o.code;
                return AnimationConfiguration.staggeredList(
                  position: i,
                  duration: const Duration(milliseconds: 400),
                  child: SlideAnimation(
                    verticalOffset: 24,
                    child: FadeInAnimation(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.surfaceHigh, AppColors.surface],
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.gold.withOpacity(0.15),
                              ),
                              child: const Icon(Icons.bolt_rounded, color: AppColors.gold),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${o.units} وحدة',
                                      style: GoogleFonts.cairo(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      )),
                                  const SizedBox(height: 2),
                                  Text('${o.cost} كوينز',
                                      style: GoogleFonts.tajawal(color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 92,
                              height: 42,
                              child: ElevatedButton(
                                onPressed: busy ? null : () => _redeem(o),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.signal,
                                  foregroundColor: Colors.white,
                                ),
                                child: busy
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Text('استبدال'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
