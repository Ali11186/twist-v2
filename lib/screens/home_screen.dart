import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/twist_api.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_counter.dart';
import 'achievements_screen.dart';
import 'login_screen.dart';
import 'redeem_screen.dart';

class HomeScreen extends StatefulWidget {
  final TwistApi api;
  const HomeScreen({super.key, required this.api});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  int _balance = 0;
  bool _loadingBalance = true;

  @override
  void initState() {
    super.initState();
    _refreshBalance();
  }

  Future<void> _refreshBalance() async {
    setState(() => _loadingBalance = true);
    final b = await widget.api.getBalance();
    if (!mounted) return;
    setState(() {
      _balance = b;
      _loadingBalance = false;
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('تسجيل الخروج', style: GoogleFonts.cairo(color: AppColors.textPrimary)),
        content: Text(
          'هيتم تسجيل خروجك عشان تقدر تدخل برقم تاني.',
          style: GoogleFonts.tajawal(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء', style: GoogleFonts.tajawal(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('تسجيل الخروج', style: GoogleFonts.tajawal(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _openChannel() async {
    final uri = Uri.parse('https://t.me/ahrgq');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _openChannel,
                    icon: const Icon(Icons.send_rounded, size: 18, color: AppColors.signalSoft),
                    label: Text(
                      'قناتنا على تليجرام',
                      style: GoogleFonts.tajawal(color: AppColors.signalSoft, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
                    tooltip: 'تسجيل الخروج',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: _loadingBalance
                  ? const SizedBox(
                      height: 90,
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2.4),
                      ),
                    )
                  : CoinCounter(balance: _balance),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  AchievementsScreen(api: widget.api, onBalanceChanged: _refreshBalance),
                  RedeemScreen(api: widget.api, balance: _balance, onRedeemed: _refreshBalance),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.gold.withOpacity(0.18),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.graphic_eq_rounded, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.graphic_eq_rounded, color: AppColors.gold),
            label: 'المهام',
          ),
          NavigationDestination(
            icon: Icon(Icons.card_giftcard_rounded, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.card_giftcard_rounded, color: AppColors.gold),
            label: 'استبدال',
          ),
        ],
      ),
    );
  }
}
