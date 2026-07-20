import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import '../services/twist_api.dart';
import '../theme/app_theme.dart';
import '../widgets/achievement_tile.dart';

class AchievementsScreen extends StatefulWidget {
  final TwistApi api;
  final VoidCallback onBalanceChanged;
  const AchievementsScreen({super.key, required this.api, required this.onBalanceChanged});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Achievement> _items = [];
  bool _loading = true;
  bool _running = false;
  String? _busyId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await widget.api.getAchievements();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _completeAll() async {
    setState(() => _running = true);
    for (final a in _items.where((e) => !e.rewarded)) {
      setState(() => _busyId = a.id);
      final ok = await widget.api.completeAchievement(a.id);
      if (ok) {
        setState(() {
          final idx = _items.indexWhere((e) => e.id == a.id);
          _items[idx] = Achievement(id: a.id, name: a.name, rewarded: true, coins: a.coins);
        });
      }
      await Future.delayed(const Duration(milliseconds: 250));
    }
    setState(() {
      _busyId = null;
      _running = false;
    });
    widget.onBalanceChanged();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _items.where((e) => !e.rewarded).length;

    if (_loading) {
      return Shimmer.fromColors(
        baseColor: AppColors.surface,
        highlightColor: AppColors.surfaceHigh,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: 6,
          itemBuilder: (_, __) => Container(
            height: 60,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.gold,
      backgroundColor: AppColors.surface,
      onRefresh: _load,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    remaining == 0 ? 'كل المهام مكتملة ✨' : 'باقي $remaining مهمة',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (remaining > 0)
                  ElevatedButton(
                    onPressed: _running ? null : _completeAll,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(120, 42)),
                    child: _running
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bg),
                          )
                        : const Text('نفّذ الكل'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  final a = _items[i];
                  return AnimationConfiguration.staggeredList(
                    position: i,
                    duration: const Duration(milliseconds: 400),
                    child: SlideAnimation(
                      verticalOffset: 24,
                      child: FadeInAnimation(
                        child: AchievementTile(achievement: a, busy: _busyId == a.id),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
