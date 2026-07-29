import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';
import 'package:relax_mindfulness/components/glass_components.dart';

class MindfulnessScreen extends StatelessWidget {
  const MindfulnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [bgDark, Color(0xFF132932), bgDark],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text('MINDFULNESS & STATS',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: mintAccent,
                          letterSpacing: 2)),
                  const Text('Your Mindful Journey',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Track session history, mood trends & practice consistency',
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6))),
                  const SizedBox(height: 20),

                  // Daily Banner
                  GlassCard(
                    cornerRadius: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DAILY MINDFUL MINUTE',
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: tealPrimary,
                                letterSpacing: 1.5)),
                        const SizedBox(height: 6),
                        const Text('Cultivate Calm Presence',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Take 5 minutes to pause, observe your breath, and reset your nervous system.',
                            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7))),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            GlassPillButton(
                              text: 'Quick Start',
                              icon: Icons.air,
                              onTap: () => state.setTab(AppTab.breathe),
                            ),
                            const SizedBox(width: 10),
                            GlassPillButton(
                              text: 'Guided Session',
                              icon: Icons.self_improvement,
                              containerColor: Colors.white.withOpacity(0.15),
                              contentColor: Colors.white,
                              onTap: () => state.setTab(AppTab.meditate),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats grid 1
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          cornerRadius: 18,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('⏱️', style: TextStyle(fontSize: 24)),
                              const SizedBox(height: 6),
                              Text('${state.totalMinutes}',
                                  style: const TextStyle(
                                      fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                              Text('Total Relaxed Min',
                                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassCard(
                          cornerRadius: 18,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('🏆', style: TextStyle(fontSize: 24)),
                              const SizedBox(height: 6),
                              Text('${state.sessions.length}',
                                  style: const TextStyle(
                                      fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                              Text('Sessions Done',
                                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stats grid 2
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          cornerRadius: 18,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 24)),
                              const SizedBox(height: 6),
                              Text('${state.streak}',
                                  style: const TextStyle(
                                      fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                              Text('Current Streak (Days)',
                                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassCard(
                          cornerRadius: 18,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('⭐', style: TextStyle(fontSize: 24)),
                              const SizedBox(height: 6),
                              Text(state.avgMood > 0 ? state.avgMood.toStringAsFixed(1) : '--',
                                  style: const TextStyle(
                                      fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                              Text('Average Mood Rating',
                                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Weekly Chart Card
                  GlassCard(
                    cornerRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PRACTICE TIME THIS WEEK',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: tealPrimary,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 140,
                          child: _BarChartWidget(weeklyData: state.weeklyMinutes),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Breakdown
                  if (state.categoryBreakdown.isNotEmpty) ...[
                    const Text('CATEGORY BREAKDOWN',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: tealPrimary,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: state.categoryBreakdown.entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GlassChip(
                              label: '${e.key}: ${e.value}m',
                              isSelected: true,
                              selectedColor: tealPrimary,
                              onTap: () {},
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Session History
                  const Text('RECENT SESSIONS',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: tealPrimary,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 12),

                  if (state.sessions.isEmpty)
                    GlassCard(
                      cornerRadius: 18,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Text('🍃', style: TextStyle(fontSize: 40)),
                              const SizedBox(height: 8),
                              const Text('No sessions recorded yet',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Complete your first session to see history here',
                                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...state.sessions.take(10).map((s) {
                      final moodEmojis = ['', '😔', '😕', '😐', '🙂', '😊'];
                      final moodEmoji = (s.moodRating >= 1 && s.moodRating <= 5) ? moodEmojis[s.moodRating] : null;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassCard(
                          cornerRadius: 16,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: tealPrimary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  s.type == 'Meditation'
                                      ? '🧘'
                                      : s.type == 'Breathing'
                                          ? '💨'
                                          : s.type == 'Sleep'
                                              ? '🌙'
                                              : '🎵',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.title,
                                        style: const TextStyle(
                                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 2),
                                    Text('${s.type} • ${s.durationMinutes} minutes',
                                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                                  ],
                                ),
                              ),
                              if (moodEmoji != null) Text(moodEmoji, style: const TextStyle(fontSize: 22)),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BarChartWidget extends StatelessWidget {
  final List<MapEntry<String, int>> weeklyData;
  const _BarChartWidget({required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    final maxY = weeklyData.map((e) => e.value).fold(0, (a, b) => a > b ? a : b).toDouble();
    final today = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][DateTime.now().weekday - 1];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY < 10 ? 30 : maxY * 1.25,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                final idx = val.toInt();
                if (idx < 0 || idx >= weeklyData.length) return const SizedBox();
                final isToday = weeklyData[idx].key == today;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    weeklyData[idx].key,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? coralAccent : Colors.white.withOpacity(0.5),
                    ),
                  ),
                );
              },
              reservedSize: 24,
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (_) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: weeklyData.asMap().entries.map((e) {
          final isToday = e.value.key == today;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value.toDouble(),
                width: 16,
                color: isToday ? coralAccent : tealPrimary.withOpacity(0.7),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
