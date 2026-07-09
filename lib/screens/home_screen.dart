import 'package:flutter/material.dart';
import '../services/twist_api.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_counter.dart';
import 'achievements_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
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
