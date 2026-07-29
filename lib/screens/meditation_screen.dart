import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';
import 'package:relax_mindfulness/components/glass_components.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  String _selectedCategory = 'All';

  static const _sessions = [
    ('🌊', 'Deep Stress Release', '15', 'Stress', 'Let go of body tension through guided breath and body scan'),
    ('💆', 'Body Scan Relaxation', '18', 'Stress', 'Release tension progressively from head to toe'),
    ('🌅', 'Morning Clarity & Energy', '10', 'Morning', 'Start your day with peaceful awareness of the present'),
    ('🫁', 'Mindful Breath Awareness', '8', 'Morning', 'Anchor your full attention to the rhythm of breath'),
    ('🌸', 'Evening Gratitude Unwind', '20', 'Sleep', 'Softly transition into a restful, grateful sleep state'),
    ('🌙', 'Yoga Nidra Sleep Prep', '35', 'Sleep', 'Full body-mind relaxation for deep restorative sleep'),
    ('🕊️', 'Inner Calm & Serenity', '12', 'Focus', 'Find your silent quiet center beneath all the noise'),
    ('🌄', 'Visualization Journey', '25', 'Focus', 'A guided imagery trip to your own peaceful safe place'),
    ('🔮', 'Chakra Balancing Tones', '30', 'Healing', 'Align your energy centers with healing sound frequencies'),
    ('💗', 'Loving-Kindness Meditation', '15', 'Healing', 'Cultivate deep compassion for yourself and others'),
  ];

  static const _colorPairs = [
    [Color(0xFF162534), tealPrimary],
    [Color(0xFF162830), mintAccent],
    [Color(0xFF261C30), purpleAccent],
    [Color(0xFF1E2830), tealDark],
    [Color(0xFF2D201A), coralAccent],
    [Color(0xFF181C30), tealPrimary],
    [Color(0xFF1A2930), mintAccent],
    [Color(0xFF241A30), purpleAccent],
    [Color(0xFF2A1E26), coralAccent],
    [Color(0xFF1B2830), tealPrimary],
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? _sessions
        : _sessions.where((s) => s.$4 == _selectedCategory).toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bgDark, bgMid, bgDark],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ─────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GUIDED MEDITATION',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: tealPrimary,
                                  letterSpacing: 1.8,
                                ),
                              ),
                              Text(
                                'Find Your Calm',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: tealPrimary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.self_improvement_rounded, color: tealPrimary, size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Search by how you feel — curated practices for your emotional state',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                    const SizedBox(height: 20),

                    // Daily Featured Card (Real Nature Photography)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
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
                                    Colors.black.withOpacity(0.85),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white30, width: 1),
                                  ),
                                  child: const Center(child: Text('🌅', style: TextStyle(fontSize: 28))),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'DAILY GUIDED JOURNEY',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: coralAccent,
                                          letterSpacing: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Calm Mountain Horizon',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Text(
                                        '10 Min • Deep Relaxation',
                                        style: TextStyle(fontSize: 12, color: Colors.white70),
                                      ),
                                      const SizedBox(height: 10),
                                      Consumer<AppState>(
                                        builder: (ctx, state, _) => GlassPillButton(
                                          text: 'Begin Session',
                                          icon: Icons.play_arrow_rounded,
                                          onTap: () {
                                            state.playGuidedSession('Calm Mountain Horizon', 10);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // EMOTIONAL INTENT FILTER CHIPS
                    const Text(
                      'BROWSE BY EMOTIONAL INTENT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: tealPrimary,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 10),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'Stress', 'Morning', 'Sleep', 'Focus', 'Healing'].map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GlassChip(
                              label: cat == 'All' ? 'All Moods ✨' : cat,
                              isSelected: isSelected,
                              selectedColor: tealPrimary,
                              onTap: () => setState(() => _selectedCategory = cat),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Session List Filtered by Mood Intent ───────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final s = filtered[i];
                    final colors = _colorPairs[i % _colorPairs.length];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SessionCard(
                        emoji: s.$1,
                        title: s.$2,
                        duration: s.$3,
                        category: s.$4,
                        description: s.$5,
                        accentColor: colors[1],
                        bgColor: colors[0],
                      ),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final String emoji, title, duration, category, description;
  final Color accentColor, bgColor;

  const _SessionCard({
    required this.emoji,
    required this.title,
    required this.duration,
    required this.category,
    required this.description,
    required this.accentColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (ctx, state, _) => GestureDetector(
        onTap: () {
          state.playGuidedSession(title, int.parse(duration));
        },
        child: GlassCard(
          cornerRadius: 22,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 10,
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 13, color: textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '$duration min • Guided',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                        const Spacer(),
                        Text(
                          'Begin →',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
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
    );
  }
}
