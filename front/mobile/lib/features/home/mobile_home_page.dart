import 'package:flutter/material.dart';

import '../../core/study_stats.dart';
import '../kana/kana_page.dart';
import '../words/word_listening_page.dart';
import '../words/words_page.dart';
import 'study_history_page.dart';

class MobileHomePage extends StatefulWidget {
  const MobileHomePage({super.key});

  @override
  State<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage> {
  final StudyStatsService _statsService = StudyStatsService();
  StudyStats _stats = StudyStats.empty;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _statsService.load();
    if (!mounted) return;
    setState(() => _stats = stats);
  }

  /// 打开学习页面，返回后刷新统计。
  Future<void> _open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    await _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadStats,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: _HomeHeader(
                    onHistory: () => _open(const StudyHistoryPage()),
                    onLogout: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(child: _StatusPanel(stats: _stats)),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.28,
                  children: [
                    _MetricCard(
                      label: '今日复习',
                      value: '${_stats.todayReviews}',
                      icon: Icons.task_alt_rounded,
                    ),
                    _MetricCard(
                      label: '连续学习',
                      value: '${_stats.streakDays}天',
                      icon: Icons.local_fire_department_rounded,
                    ),
                    _MetricCard(
                      label: '已学单词',
                      value: '${_stats.learnedWords}',
                      icon: Icons.style_rounded,
                    ),
                    _MetricCard(
                      label: 'N5进度',
                      value: '${_stats.n5Percent}%',
                      icon: Icons.verified_rounded,
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                sliver: SliverToBoxAdapter(child: _QuickActions(onOpen: _open)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onHistory, required this.onLogout});

  final VoidCallback onHistory;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '日语学习',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '今日も一歩ずつ，继续保持节奏',
                style: textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onHistory,
          icon: const Icon(Icons.insights_rounded),
          tooltip: '学习记录',
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: onLogout,
          icon: const Icon(Icons.logout_rounded),
          tooltip: '退出登录',
        ),
      ],
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.stats});

  final StudyStats stats;

  @override
  Widget build(BuildContext context) {
    const goal = StudyStatsService.dailyGoal;
    final done = stats.todayReviews;
    final reached = done >= goal;
    final progress = (done / goal).clamp(0.0, 1.0);
    final remaining = (goal - done).clamp(0, goal);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF166534), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332563EB),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                reached
                    ? Icons.celebration_rounded
                    : Icons.menu_book_rounded,
                color: Colors.white,
                size: 30,
              ),
              const Spacer(),
              Text(
                '$done / $goal',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '今日学习计划',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            reached
                ? '今日目标已完成，太棒了！保持节奏继续加分。'
                : '今天再复习 $remaining 次即可达成目标，去翻卡或做测验吧。',
            style: const TextStyle(color: Color(0xFFDDEBFF), height: 1.5),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0x33FFFFFF),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: const Color(0xFF2563EB)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Color(0xFF6B7280))),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onOpen});

  final Future<void> Function(Widget page) onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '学习入口',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        _ActionTile(
          icon: Icons.translate_rounded,
          title: '五十音练习',
          subtitle: '平假名、片假名快速识别',
          color: const Color(0xFF166534),
          onTap: () => onOpen(const KanaPage()),
        ),
        _ActionTile(
          icon: Icons.style_rounded,
          title: '单词卡片',
          subtitle: 'N5 高频词和例句复习',
          color: const Color(0xFFDC2626),
          onTap: () => onOpen(const WordsPage()),
        ),
        _ActionTile(
          icon: Icons.hearing_rounded,
          title: '听力跟读',
          subtitle: '听发音选释义，练听辨能力',
          color: const Color(0xFFF59E0B),
          onTap: () => onOpen(const WordListeningPage()),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final available = onTap != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap:
              onTap ??
              () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('该功能正在开发中，敬请期待'),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (!available) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '即将上线',
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
