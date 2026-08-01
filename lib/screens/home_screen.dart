import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';
import 'package:relax_mindfulness/theme/neumorphism_demo.dart';
import 'package:relax_mindfulness/components/glass_components.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning, Welcome 🌸';
    if (h < 17) return 'Good Afternoon, Soft Rest 🌿';
    return 'Good Evening, Rest Easy 🌙';
  }

  static const _featured = [
    {
      'title': 'Morning Clarity',
      'desc': '10 Min • Quiet Awareness',
      'icon': Icons.wb_sunny_rounded,
      'type': 'Meditation',
      'mins': 10,
      'color': tealPrimary
    },
    {
      'title': 'Box Breath Reset',
      'desc': '5 Min • Stress Relief',
      'icon': Icons.air_rounded,
      'type': 'Breathing',
      'mins': 5,
      'color': mintAccent
    },
    {
      'title': 'Deep Ocean Sleep',
      'desc': '30 Min • Restorative Slumber',
      'icon': Icons.nightlight_round,
      'type': 'Sleep',
      'mins': 30,
      'color': coralAccent
    },
    {
      'title': '432Hz Sound Bath',
      'desc': '20 Min • Solfeggio Tones',
      'icon': Icons.graphic_eq_rounded,
      'type': 'Sounds',
      'mins': 20,
      'color': purpleAccent
    },
    {
      'title': 'Evening Gratitude',
      'desc': '15 Min • Mindful Presence',
      'icon': Icons.spa_rounded,
      'type': 'Meditation',
      'mins': 15,
      'color': mintAccent
    },
  ];

  @override
  Widget build(BuildContext context) {
    final today = _featured[DateTime.now().weekday % _featured.length];
    final IconData featuredIcon = today['icon'] as IconData;
    final Color featuredColor = today['color'] as Color;

    return Consumer<AppState>(
      builder: (context, state, _) {
        final isClay = state.themeMode.isLight;
        final activeTextColor = isClay ? clayText : textPrimary;
        final activeSubtextColor = isClay ? claySubtext : textSecondary;

        return Stack(
          children: [
            // 🌿 Soft Nature Aurora Backdrop for Home Header
            if (!isClay)
              Positioned(
                top: 0, left: 0, right: 0,
                height: 260,
                child: ShaderMask(
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.transparent],
                  ).createShader(rect),
                  blendMode: BlendMode.dstIn,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=1200&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const SizedBox.shrink(),
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isClay
                      ? [state.themeMode.bgDark, state.themeMode.bgMid, state.themeMode.bgDark]
                      : [
                          const Color(0xFF071810).withOpacity(0.72),
                          state.themeMode.bgDark,
                          state.themeMode.bgMid,
                        ],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // ── Soothing Header ────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: activeTextColor,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Take a deep breath. You are safe and at peace here.',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: activeSubtextColor,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: isClay ? clayCardBg : Colors.white.withOpacity(0.08),
                              shape: BoxShape.circle,
                              boxShadow: isClay
                                  ? const [
                                      BoxShadow(color: Color(0x33B89679), blurRadius: 8, offset: Offset(4, 4)),
                                      BoxShadow(color: Colors.white, blurRadius: 6, offset: Offset(-3, -3)),
                                    ]
                                  : null,
                            ),
                            child: PopupMenuButton<SanctuaryThemeMode>(
                              icon: Icon(
                                Icons.palette_rounded,
                                color: isClay ? clayText : textPrimary,
                                size: 22,
                              ),
                              onSelected: (mode) => state.setThemeMode(mode),
                              itemBuilder: (ctx) => SanctuaryThemeMode.values.map((mode) {
                                return PopupMenuItem(
                                  value: mode,
                                  child: Row(
                                    children: [
                                      Icon(
                                        mode == state.themeMode ? Icons.check_circle_rounded : Icons.circle_outlined,
                                        color: mode.isLight ? clayAccent : tealPrimary,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        mode.displayName,
                                        style: TextStyle(
                                          fontWeight: mode == state.themeMode ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Neumorphism Soft UI Showcase Button
                          Container(
                            decoration: BoxDecoration(
                              color: isClay ? clayCardBg : Colors.white.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Text('✨', style: TextStyle(fontSize: 16)),
                              tooltip: 'Neumorphism Theme Showcase',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const NeumorphismDemoScreen()),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (state.streak > 0) StreakBadge(streakCount: state.streak),
                        ],
                      ),
                    ],
                  ),
                      const SizedBox(height: 16),

                      // ── 0. Daily Affirmation & Mindfulness Inspiration ──
                      const _DailyAffirmationBanner(),
                      const SizedBox(height: 20),

                      // ── 1. Hero Featured Sanctuary Card (Tall 240px & Alive Motion) ──
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 230,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.35),
                                        Colors.black.withOpacity(0.88),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(22),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: coralAccent.withOpacity(0.25),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: coralAccent.withOpacity(0.4)),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.spa_rounded, color: Colors.white, size: 12),
                                              SizedBox(width: 5),
                                              Text(
                                                'DAILY PRACTICE',
                                                style: TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        const AnimatedSoundWave(accentColor: coralAccent),
                                      ],
                                    ),

                                    Row(
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.18),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white30, width: 1.5),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: Icon(featuredIcon, color: Colors.white, size: 26),
                                        ),
                                        const SizedBox(width: 16),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                today['title']! as String,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: -0.3,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                today['desc']! as String,
                                                style: const TextStyle(
                                                  fontSize: 12.5,
                                                  color: Colors.white70,
                                                  height: 1.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(
                                      width: double.infinity,
                                      child: GlassPillButton(
                                        text: 'Begin Peaceful Journey →',
                                        icon: Icons.play_arrow_rounded,
                                        containerColor: tealPrimary,
                                        contentColor: Colors.black,
                                        onTap: () {
                                          final type = today['type']! as String;
                                          if (type == 'Meditation') {
                                            state.playGuidedSession(today['title']! as String, today['mins']! as int);
                                          } else if (type == 'Breathing') {
                                            state.setTab(AppTab.breathe);
                                          } else if (type == 'Sleep') {
                                            state.setTab(AppTab.sleep);
                                          } else {
                                            state.setTab(AppTab.sounds);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── 2. Mood Selector Bar ("How do you feel today?") ───
                      Text(
                        'HOW DO YOU FEEL TODAY?',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: textSecondary,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(height: 10),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ('😌 Calm', 'Calm'),
                            ('😰 Stressed', 'Stressed'),
                            ('😴 Sleepy', 'Sleepy'),
                            ('🧠 Need Focus', 'Focus'),
                            ('❤️ Emotional', 'Anxiety'),
                            ('🌧️ Want Nature', 'Nature'),
                          ].map((item) {
                            final isSelected = state.selectedMoodFilter == item.$2;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GlassChip(
                                label: item.$1,
                                isSelected: isSelected,
                                selectedColor: tealPrimary,
                                onTap: () => state.setMoodFilter(item.$2),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ── 2b. Dynamic Curated Recommendations for Selected Mood ──
                      const _DynamicMoodRecommendations(),
                      const SizedBox(height: 24),

                      // ── 2c. Embedded Instant 1-Minute Calm Breathing Widget ──
                      const _HomeQuickBreathWidget(),
                      const SizedBox(height: 26),

                      // ── 3. FEATURED AMBIENT CAROUSEL (Large 240px Cards) ──
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: tealPrimary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'FEATURED AMBIENT SOUNDSCAPES',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: tealPrimary,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _SpotifyAmbientCard(
                              title: '432Hz Healing Chimes',
                              subtitle: 'Deep Solfeggio Resonant Harmonic Tones',
                              duration: '20 min',
                              imageUrl: 'https://images.unsplash.com/photo-1511295742362-92c96b124e52?auto=format&fit=crop&w=500&q=80',
                              color: tealPrimary,
                              onTap: () => state.playGuidedSession('Healing Crystal Chimes', 20),
                            ),
                            const SizedBox(width: 14),
                            _SpotifyAmbientCard(
                              title: 'Cozy Rain & Hearth',
                              subtitle: 'Soft Downpour & Warm Fireplace Crackle',
                              duration: '25 min',
                              imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=500&q=80',
                              color: coralAccent,
                              onTap: () => state.applyCuratedPreset('🌧️ Rainy Cabin'),
                            ),
                            const SizedBox(width: 14),
                            _SpotifyAmbientCard(
                              title: 'Alpine Forest Stream',
                              subtitle: 'Flowing Mountain Water & Morning Birds',
                              duration: '30 min',
                              imageUrl: 'https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?auto=format&fit=crop&w=500&q=80',
                              color: mintAccent,
                              onTap: () => state.applyCuratedPreset('🌲 Forest Walk'),
                            ),
                            const SizedBox(width: 14),
                            _SpotifyAmbientCard(
                              title: 'Cosmic Deep Waves',
                              subtitle: '108Hz Delta Drone & Soft Space Pad',
                              duration: '35 min',
                              imageUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=500&q=80',
                              color: purpleAccent,
                              onTap: () => state.applyCuratedPreset('🌌 Deep Space'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── 4. RICHER "YOUR SANCTUARY JOURNEY" CARD (Circular Progress Ring) ──
                      Row(
                        children: [
                          const Icon(Icons.favorite_rounded, color: coralAccent, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'YOUR SANCTUARY JOURNEY',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: textSecondary,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF0F262B),
                              Color(0xFF0C1924),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: tealPrimary.withOpacity(0.25), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Circular Progress Ring Indicator
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: CircularProgressIndicator(
                                    value: (state.totalMinutes % 60) / 60.0 == 0 ? 0.65 : (state.totalMinutes % 60) / 60.0,
                                    strokeWidth: 6,
                                    backgroundColor: Colors.white.withOpacity(0.1),
                                    color: tealPrimary,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${state.totalMinutes}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      'MINS',
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: tealPrimary,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(width: 18),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.local_fire_department_rounded, color: coralAccent, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${state.streak} Day Peace Streak 🌸',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.totalMinutes > 0
                                        ? 'You have spent ${state.totalMinutes} minutes resting & healing this week 🕊️'
                                        : 'Take a gentle breath and start your first peaceful moment today 🌿',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textSecondary,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── 5. Quick Practice Pills ─────────────────────────
                      Text(
                        'PRACTICE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: textSecondary,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          _QuickAction(
                            icon: Icons.self_improvement_rounded,
                            label: 'Meditate',
                            color: tealPrimary,
                            onTap: () => state.setTab(AppTab.meditate),
                          ),
                          const SizedBox(width: 10),
                          _QuickAction(
                            icon: Icons.air_rounded,
                            label: 'Breathe',
                            color: mintAccent,
                            onTap: () => state.setTab(AppTab.breathe),
                          ),
                          const SizedBox(width: 10),
                          _QuickAction(
                            icon: Icons.nightlight_round,
                            label: 'Sleep',
                            color: coralAccent,
                            onTap: () => state.setTab(AppTab.sleep),
                          ),
                          const SizedBox(width: 10),
                          _QuickAction(
                            icon: Icons.auto_awesome_rounded,
                            label: 'AI Music',
                            color: purpleAccent,
                            onTap: () => state.setTab(AppTab.aiStudio),
                          ),
                        ],
                      ),


                      // ── 5. Subtle Streak Sanctuary ───────────────────────
                      GlassCard(
                        cornerRadius: 24,
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.local_fire_department_rounded, color: coralAccent, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${state.streak} Day Streak',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.practicedToday
                                        ? 'Practiced today — habit active'
                                        : 'Practice today to maintain your streak',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Soft 7-day Dots
                                  Row(
                                    children: List.generate(7, (i) {
                                      final practiced = i < (state.streak % 7 == 0 && state.streak > 0 ? 7 : state.streak % 7);
                                      return Container(
                                        width: 18,
                                        height: 18,
                                        margin: const EdgeInsets.only(right: 5),
                                        decoration: BoxDecoration(
                                          color: practiced ? tealPrimary.withOpacity(0.8) : Colors.white.withOpacity(0.08),
                                          shape: BoxShape.circle,
                                        ),
                                        child: practiced
                                            ? const Icon(Icons.check_rounded, color: Colors.black, size: 11)
                                            : null,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '${state.longestStreak}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: coralAccent,
                                  ),
                                ),
                                Text(
                                  'Best Streak',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),   // ← Container ends (Stack child)
          ],     // ← Stack children end
        );       // ← Stack end (returned by Consumer builder)
      },         // ← Consumer builder lambda end
    );           // ← Consumer widget end
  }
}

// ── Soft Quick Action Pill ───────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Soft Stat Metric Item (Frameless) ─────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Soft Muted Data Visualization Chart ──────────────────────────────────────
class _WeeklyBarChart extends StatelessWidget {
  final List<MapEntry<String, int>> weeklyData;
  const _WeeklyBarChart({required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    if (weeklyData.isEmpty) return const SizedBox();
    final maxY = weeklyData.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();
    final today = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][DateTime.now().weekday - 1];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY < 10 ? 30 : maxY * 1.3,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= weeklyData.length) return const SizedBox();
                final isToday = weeklyData[idx].key == today;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    weeklyData[idx].key,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                      color: isToday ? coralAccent : textSecondary,
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
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withOpacity(0.04),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: weeklyData.asMap().entries.map((e) {
          final isToday = e.value.key == today;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value.toDouble(),
                width: 14,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: isToday
                      ? [coralAccent.withOpacity(0.7), coralAccent]
                      : [tealPrimary.withOpacity(0.2), tealPrimary.withOpacity(0.5)],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SpotifyAmbientCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final String imageUrl;
  final Color color;
  final VoidCallback onTap;

  const _SpotifyAmbientCard({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.imageUrl,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 115,
            height: 115,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.35), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(color: color.withOpacity(0.2)),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 115,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            duration,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 0. Daily Affirmation Banner ──────────────────────────────────────────────
class _DailyAffirmationBanner extends StatefulWidget {
  const _DailyAffirmationBanner();

  @override
  State<_DailyAffirmationBanner> createState() => _DailyAffirmationBannerState();
}

class _DailyAffirmationBannerState extends State<_DailyAffirmationBanner> {
  int _quoteIndex = 0;

  static const List<Map<String, String>> _quotes = [
    {
      'quote': '“In the midst of movement and chaos, keep stillness inside of you.”',
      'author': 'Deepak Chopra',
    },
    {
      'quote': '“Peace comes from within. Do not seek it without.”',
      'author': 'Buddha',
    },
    {
      'quote': '“Breath is the finest gift of nature. Be grateful for this marvelous gift.”',
      'author': 'Amit Ray',
    },
    {
      'quote': '“Quiet the mind, and the soul will speak.”',
      'author': 'Ma Jaya Sati Bhagavati',
    },
    {
      'quote': '“Rest is not idleness, but a restorative sanctuary for your spirit.”',
      'author': 'Sanctuary Mind',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final current = _quotes[_quoteIndex];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tealPrimary.withOpacity(0.25), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tealPrimary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.format_quote_rounded, color: tealPrimary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  current['quote']!,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '— ${current['author']!}',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: tealPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _quoteIndex = (_quoteIndex + 1) % _quotes.length;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2b. Dynamic Mood Intent Recommendations ────────────────────────────────
class _DynamicMoodRecommendations extends StatelessWidget {
  const _DynamicMoodRecommendations();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final mood = state.selectedMoodFilter;

        final Map<String, List<Map<String, dynamic>>> moodData = {
          'Calm': [
            {'title': 'Peaceful Haven Journey', 'desc': '15 min • Soft River Stream', 'type': 'Guided', 'icon': Icons.spa_rounded, 'color': tealPrimary, 'action': () => state.playGuidedSession('Peaceful Haven Journey', 15)},
            {'title': 'Resonance 5-5 Coherence', 'desc': '5 min • Heart Coherence', 'type': 'Breathe', 'icon': Icons.air_rounded, 'color': mintAccent, 'action': () => state.setTab(AppTab.breathe)},
            {'title': '432Hz Healing Chimes', 'desc': '20 min • Solfeggio Tones', 'type': 'Sounds', 'icon': Icons.graphic_eq_rounded, 'color': purpleAccent, 'action': () => state.playGuidedSession('Healing Crystal Chimes', 20)},
          ],
          'Stressed': [
            {'title': 'Deep Stress Release', 'desc': '12 min • Body Tension Melt', 'type': 'Guided', 'icon': Icons.self_improvement_rounded, 'color': coralAccent, 'action': () => state.playGuidedSession('Gentle Relief & Comfort', 12)},
            {'title': 'Box Breathing 4-4-4-4', 'desc': '4 min • Calm Nervous System', 'type': 'Breathe', 'icon': Icons.air_rounded, 'color': tealPrimary, 'action': () => state.setTab(AppTab.breathe)},
            {'title': 'Cozy Rainfall Cabin', 'desc': 'Soft Downpour & Hearth', 'type': 'Sounds', 'icon': Icons.thunderstorm_rounded, 'color': mintAccent, 'action': () => state.applyCuratedPreset('🌧️ Rainy Cabin')},
          ],
          'Sleepy': [
            {'title': 'Midnight Alpine Forest', 'desc': '25 min • Sleep Story', 'type': 'Sleep', 'icon': Icons.bedtime_rounded, 'color': purpleAccent, 'action': () => state.setTab(AppTab.sleep)},
            {'title': '4-7-8 Sleep Breath', 'desc': '7 min • Dr. Weil Method', 'type': 'Breathe', 'icon': Icons.air_rounded, 'color': coralAccent, 'action': () => state.setTab(AppTab.breathe)},
            {'title': 'Cosmic Deep Space Waves', 'desc': 'Delta Wave Slumber', 'type': 'Sounds', 'icon': Icons.nights_stay_rounded, 'color': tealPrimary, 'action': () => state.applyCuratedPreset('🌌 Deep Space')},
          ],
          'Focus': [
            {'title': 'Morning Clarity & Focus', 'desc': '10 min • Crisp Awareness', 'type': 'Guided', 'icon': Icons.wb_sunny_rounded, 'color': mintAccent, 'action': () => state.playGuidedSession('Peaceful Morning Start', 10)},
            {'title': 'Power 6-2-6 Breath', 'desc': '5 min • Clean Mental Energy', 'type': 'Breathe', 'icon': Icons.bolt_rounded, 'color': tealPrimary, 'action': () => state.setTab(AppTab.breathe)},
            {'title': 'Alpine Forest Stream', 'desc': 'Focus Soundscape', 'type': 'Sounds', 'icon': Icons.forest_rounded, 'color': purpleAccent, 'action': () => state.applyCuratedPreset('🌲 Forest Walk')},
          ],
          'Anxiety': [
            {'title': 'Warm Heart Comfort', 'desc': '15 min • Gentle Relief', 'type': 'Guided', 'icon': Icons.favorite_rounded, 'color': coralAccent, 'action': () => state.playGuidedSession('Warm Heart Comfort', 15)},
            {'title': 'Quiet Mind Sanctuary', 'desc': '12 min • Silent Center', 'type': 'Guided', 'icon': Icons.spa_rounded, 'color': tealPrimary, 'action': () => state.playGuidedSession('Quiet Mind Sanctuary', 12)},
            {'title': 'Singing Bowls 432Hz', 'desc': 'Harmonic Healing', 'type': 'Sounds', 'icon': Icons.graphic_eq_rounded, 'color': mintAccent, 'action': () => state.playGuidedSession('Healing Crystal Chimes', 20)},
          ],
          'Nature': [
            {'title': 'Forest Bathing Journey', 'desc': '20 min • Woodland Sanctuary', 'type': 'Guided', 'icon': Icons.park_rounded, 'color': mintAccent, 'action': () => state.playGuidedSession('Peaceful Haven Journey', 20)},
            {'title': 'Mountain Stream Flow', 'desc': 'Nature Soundscape', 'type': 'Sounds', 'icon': Icons.water_drop_rounded, 'color': tealPrimary, 'action': () => state.applyCuratedPreset('🌲 Forest Walk')},
            {'title': 'Starlit Ocean Voyage', 'desc': '30 min • Bedtime Story', 'type': 'Sleep', 'icon': Icons.tsunami_rounded, 'color': purpleAccent, 'action': () => state.setTab(AppTab.sleep)},
          ],
        };

        final recs = moodData[mood] ?? moodData['Calm']!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: tealPrimary, size: 15),
                const SizedBox(width: 6),
                Text(
                  'CURATED FOR YOUR "$mood" MOOD',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: tealPrimary,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Column(
              children: recs.map((item) {
                final Color color = item['color'] as Color;
                final VoidCallback onTap = item['action'] as VoidCallback;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: color.withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(item['icon'] as IconData, color: color, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['desc'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.65),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.play_arrow_rounded, color: color, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'Begin',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

// ── 2c. Embedded Instant 1-Minute Calm Breathing Widget ──────────────────────
class _HomeQuickBreathWidget extends StatefulWidget {
  const _HomeQuickBreathWidget();

  @override
  State<_HomeQuickBreathWidget> createState() => _HomeQuickBreathWidgetState();
}

class _HomeQuickBreathWidgetState extends State<_HomeQuickBreathWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  bool _isActive = false;
  String _phaseLabel = 'Tap to start 1-min calm breath';
  int _secondsLeft = 60;
  dynamic _timer;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _toggleBreathing() {
    if (_isActive) {
      _stopBreathing();
    } else {
      _startBreathing();
    }
  }

  void _startBreathing() {
    setState(() {
      _isActive = true;
      _secondsLeft = 60;
      _phaseLabel = 'Inhale deeply...';
    });
    _animCtrl.repeat(reverse: true);

    _timer?.cancel();
    _timer = Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        _stopBreathing();
      } else {
        setState(() {
          _secondsLeft--;
          final cycleSec = _secondsLeft % 8;
          if (cycleSec >= 4) {
            _phaseLabel = 'Exhale softly...';
          } else {
            _phaseLabel = 'Inhale deeply...';
          }
        });
      }
    });
  }

  void _stopBreathing() {
    _timer?.cancel();
    _animCtrl.stop();
    _animCtrl.reset();
    if (mounted) {
      setState(() {
        _isActive = false;
        _phaseLabel = 'Tap to start 1-min calm breath';
        _secondsLeft = 60;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0C2226),
            Color(0xFF091720),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: mintAccent.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated Glowing Breathing Circle
          AnimatedBuilder(
            animation: _animCtrl,
            builder: (_, __) {
              final scale = _isActive ? 0.75 + (0.35 * _animCtrl.value) : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        mintAccent.withOpacity(0.8),
                        tealPrimary.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: mintAccent.withOpacity(_isActive ? 0.6 : 0.2),
                        blurRadius: _isActive ? 20 : 8,
                        spreadRadius: _isActive ? 4 : 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _isActive ? Icons.air_rounded : Icons.spa_rounded,
                      color: Colors.black,
                      size: 26,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'INSTANT 1-MIN CALM',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: mintAccent,
                        letterSpacing: 1.4,
                      ),
                    ),
                    if (_isActive) ...[
                      const Spacer(),
                      Text(
                        '00:${_secondsLeft.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _phaseLabel,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          GestureDetector(
            onTap: _toggleBreathing,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _isActive ? coralAccent : mintAccent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (_isActive ? coralAccent : mintAccent).withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Text(
                _isActive ? 'Stop' : 'Start',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
