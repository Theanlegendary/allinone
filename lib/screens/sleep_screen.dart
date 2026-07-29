import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';
import 'package:relax_mindfulness/components/glass_components.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  Timer? _sleepTimer;
  int? _remainingSec;
  int? _totalSec;
  bool _isRunning = false;

  // Thematic Category 1: Nature Sanctuary
  static const _natureStories = [
    ('🌲', 'Midnight Alpine Forest', 'Elena Vance', '25', 'Soothing whispering pine trees under soft moonlight'),
    ('🌧️', 'Cozy Rainfall Cabin', 'David Miller', '40', 'Warm fireplace glow with gentle roof rainfall'),
    ('🌊', 'Starlit Ocean Voyage', 'Julian Ross', '30', 'Lapping waves beneath calm starry night skies'),
    ('🏜️', 'Desert Stargazing', 'Kai Thompson', '32', 'Beneath a million stars in the vast quiet Sahara'),
  ];

  // Thematic Category 2: Fantasy & Dreamscapes
  static const _fantasyStories = [
    ('☁️', 'Floating on Cloud Nine', 'Aria Moon', '22', 'Drift weightlessly through soft cotton evening clouds'),
    ('✨', 'Enchanted Forest Dream', 'Sofia Chen', '28', 'Walk through a glowing bioluminescent forest pathway'),
  ];

  // Thematic Category 3: Cultural & Tranquil
  static const _culturalStories = [
    ('🎋', 'The Secret Japanese Garden', 'Mei Lin', '35', 'Bamboo water fountain in a quiet zen sanctuary'),
    ('🔔', 'Ancient Temple Bells', 'Ravi Sharma', '45', 'Deep resonant temple chimes echoing into silence'),
  ];

  void _startTimer(int minutes) {
    _sleepTimer?.cancel();
    final total = minutes * 60;
    setState(() {
      _totalSec = total;
      _remainingSec = total;
      _isRunning = true;
    });

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSec == null || _remainingSec! <= 0) {
        t.cancel();
        setState(() {
          _isRunning = false;
          _remainingSec = null;
        });
        context.read<AppState>().recordSession(
          context.read<AppState>().selectedStory != null
              ? 'Sleep Story: ${context.read<AppState>().selectedStory}'
              : 'Sleep Auto-Fade Session',
          'Sleep',
          minutes,
        );
      } else {
        setState(() {
          _remainingSec = _remainingSec! - 1;
        });
      }
    });
  }

  void _extendTimer(int extraMins) {
    if (_isRunning && _remainingSec != null) {
      setState(() {
        _remainingSec = _remainingSec! + (extraMins * 60);
        _totalSec = (_totalSec ?? 0) + (extraMins * 60);
      });
    } else {
      _startTimer(extraMins);
    }
  }

  void _cancelTimer() {
    _sleepTimer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSec = null;
      _totalSec = null;
    });
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    super.dispose();
  }

  Widget _buildStoryTile((String, String, String, String, String) s, AppState state) {
    final emoji = s.$1;
    final title = s.$2;
    final narrator = s.$3;
    final duration = s.$4;
    final desc = s.$5;
    final isSelected = state.selectedStory == title;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          state.setStory(title);
          _startTimer(int.parse(duration));
          state.recordSession('Story: $title', 'Sleep', int.parse(duration), showMoodCheckIn: false);
        },
        child: GlassCard(
          cornerRadius: 22,
          padding: const EdgeInsets.all(16),
          backgroundColor: isSelected ? coralAccent.withOpacity(0.12) : null,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? coralAccent.withOpacity(0.2) : Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$narrator • $duration min',
                      style: TextStyle(fontSize: 11.5, color: coralAccent, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              Icon(
                isSelected ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                color: isSelected ? coralAccent : textSecondary.withOpacity(0.6),
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bgDark, Color(0xFF0C1924), bgDark],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
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
                                'BEDTIME & SLEEP',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: coralAccent,
                                  letterSpacing: 1.8,
                                ),
                              ),
                              Text(
                                'Deep Slumber',
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
                            color: coralAccent.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.nightlight_round, color: coralAccent, size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bedtime journeys & auto-fade sleep timer for uninterrupted rest',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                    const SizedBox(height: 20),

                    // Sleep Auto-Fade Timer Card (Real Nature Starlight Photography)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=800&q=80',
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
                                    Colors.black.withOpacity(0.4),
                                    Colors.black.withOpacity(0.85),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'SLEEP AUTO-FADE TIMER',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: coralAccent,
                                        letterSpacing: 1.4,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.battery_saver_rounded, color: Colors.greenAccent, size: 12),
                                          SizedBox(width: 4),
                                          Text(
                                            'Battery Saver',
                                            style: TextStyle(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                if (_isRunning && _remainingSec != null) ...[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Stopping in ${(_remainingSec! ~/ 60).toString().padLeft(2, '0')}:${(_remainingSec! % 60).toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary),
                                      ),
                                      Text(
                                        'Fading out volume in final minute',
                                        style: TextStyle(fontSize: 12, color: textSecondary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: _totalSec != null && _totalSec! > 0 ? 1 - (_remainingSec! / _totalSec!) : 0,
                                      backgroundColor: Colors.white.withOpacity(0.08),
                                      valueColor: const AlwaysStoppedAnimation<Color>(coralAccent),
                                      minHeight: 6,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      GlassPillButton(
                                        text: '+15 Min',
                                        icon: Icons.add,
                                        containerColor: Colors.white.withOpacity(0.12),
                                        contentColor: textPrimary,
                                        onTap: () => _extendTimer(15),
                                      ),
                                      const SizedBox(width: 10),
                                      GlassPillButton(
                                        text: 'Stop Timer',
                                        icon: Icons.stop_rounded,
                                        containerColor: Colors.white.withOpacity(0.08),
                                        contentColor: textSecondary,
                                        onTap: _cancelTimer,
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  Text(
                                    'Set a timer to automatically stop ambient audio as you fall asleep:',
                                    style: TextStyle(fontSize: 12.5, color: textSecondary),
                                  ),
                                  const SizedBox(height: 12),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [15, 30, 45, 60, 90].map((m) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: GlassChip(
                                            label: '$m min',
                                            isSelected: false,
                                            onTap: () => _startTimer(m),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // SECTION 1: NATURE SANCTUARY
                    Row(
                      children: [
                        const Icon(Icons.park_rounded, color: mintAccent, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'NATURE SANCTUARY STORIES',
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
                  ],
                ),
              ),
            ),

            // NATURE STORIES LIST
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildStoryTile(_natureStories[i], state),
                  childCount: _natureStories.length,
                ),
              ),
            ),

            // SECTION 2: FANTASY & DREAMSCAPES
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: purpleAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'FANTASY & DREAMSCAPES',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: textSecondary,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // FANTASY STORIES LIST
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildStoryTile(_fantasyStories[i], state),
                  childCount: _fantasyStories.length,
                ),
              ),
            ),

            // SECTION 3: CULTURAL & TRANQUIL
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_rounded, color: coralAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'CULTURAL & TRANQUIL SANCTUARIES',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: textSecondary,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // CULTURAL STORIES LIST
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildStoryTile(_culturalStories[i], state),
                  childCount: _culturalStories.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
