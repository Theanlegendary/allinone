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

  static const Map<String, String> sessionImages = {
    'Deep Stress Release': 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=400&q=80',
    'Body Scan Relaxation': 'https://images.unsplash.com/photo-1545205597-3d9d02c29597?auto=format&fit=crop&w=400&q=80',
    'Morning Clarity & Energy': 'https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?auto=format&fit=crop&w=400&q=80',
    'Mindful Breath Awareness': 'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?auto=format&fit=crop&w=400&q=80',
    'Evening Gratitude Unwind': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=80',
    'Yoga Nidra Sleep Prep': 'https://images.unsplash.com/photo-1511295742362-92c96b124e52?auto=format&fit=crop&w=400&q=80',
    'Inner Calm & Serenity': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
    'Visualization Journey': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=400&q=80',
    'Chakra Balancing Tones': 'https://images.unsplash.com/photo-1528319725582-ddc096101511?auto=format&fit=crop&w=400&q=80',
    'Loving-Kindness Meditation': 'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?auto=format&fit=crop&w=400&q=80',
  };

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
    final imgUrl = sessionImages[title];

    return Consumer<AppState>(
      builder: (ctx, state, _) {
        final isPlayingThis = state.isGuidedPlaying && state.currentGuidedTitle == title;

        return GestureDetector(
          onTap: () {
            if (isPlayingThis) {
              state.pauseGuidedSession();
            } else {
              state.playGuidedSession(title, int.parse(duration));
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isPlayingThis ? accentColor.withOpacity(0.9) : Colors.white.withOpacity(0.08),
                    width: isPlayingThis ? 1.8 : 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isPlayingThis ? accentColor.withOpacity(0.35) : Colors.black.withOpacity(0.35),
                      blurRadius: isPlayingThis ? 18 : 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // 🖼️ High-Definition Artwork Background
                    if (imgUrl != null) ...[
                      Positioned.fill(
                        child: Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const SizedBox.shrink(),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF09141D).withOpacity(0.82),
                                const Color(0xFF050D15).withOpacity(0.94),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    // 🎨 Card Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // 3D Artwork Badge Container
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isPlayingThis ? accentColor : Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: imgUrl != null
                                  ? Image.network(
                                      imgUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Center(
                                        child: Text(emoji, style: const TextStyle(fontSize: 24)),
                                      ),
                                    )
                                  : Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
                            ),
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
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isPlayingThis ? accentColor : textPrimary,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: accentColor.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: accentColor.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          fontSize: 10.5,
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
                                  style: TextStyle(fontSize: 12.5, color: textSecondary),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.schedule_rounded, size: 14, color: textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$duration min • Guided Session',
                                      style: TextStyle(fontSize: 11.5, color: textSecondary),
                                    ),
                                    if (isPlayingThis) ...[
                                      const SizedBox(width: 8),
                                      AnimatedSoundWave(accentColor: accentColor),
                                    ],
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isPlayingThis ? accentColor : accentColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isPlayingThis ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                            size: 15,
                                            color: isPlayingThis ? Colors.black : accentColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            isPlayingThis ? 'Pause' : 'Begin',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isPlayingThis ? Colors.black : accentColor,
                                            ),
                                          ),
                                        ],
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
