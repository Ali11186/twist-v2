import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/twist_api.dart';
import '../theme/app_theme.dart';
import '../widgets/waveform_background.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = TextEditingController();
  final _api = TwistApi();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    final raw = _controller.text.trim();
    if (raw.length < 10) {
      setState(() => _error = 'أدخل رقم هاتف صحيح');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final phone = TwistApi.normalizePhone(raw);
    final ok = await _api.sendCode(phone);

    if (!mounted) return;
    setState(() => _loading = false);

    if (!ok) {
      setState(() => _error = 'تعذر إرسال رمز التحقق، حاول مرة أخرى');
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => OtpScreen(api: _api, phone: phone),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WaveformBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [AppColors.signal, AppColors.signalSoft],
                    ),
                  ),
                  child: const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 32),
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 28),
                Text('تسجيل الدخول', style: Theme.of(context).textTheme.displayLarge)
                    .animate()
                    .fadeIn(delay: 150.ms)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                Text(
                  'ادخل رقم هاتفك وهنبعتلك كود تحقق',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 36),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.phone,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: '01xxxxxxxxx',
                    prefixIcon: Icon(Icons.phone_iphone_rounded, color: AppColors.textSecondary),
                  ),
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.15, end: 0),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.danger)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.bg),
                        )
                      : const Text('إرسال الكود'),
                ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.15, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
