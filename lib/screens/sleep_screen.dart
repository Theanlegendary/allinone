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

  static const _playlists = [
    (
      'Ocean Waves',
      '45 min',
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=80',
      purpleAccent
    ),
    (
      'Campfire',
      '35 min',
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
      coralAccent
    ),
    (
      'Night Forest',
      '40 min',
      'https://images.unsplash.com/photo-1511295742362-92c96b124e52?auto=format&fit=crop&w=400&q=80',
      tealPrimary
    ),
    (
      'Heavy Rain',
      '30 min',
      'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?auto=format&fit=crop&w=400&q=80',
      mintAccent
    ),
    (
      'Thunderstorm',
      '45 min',
      'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=400&q=80',
      purpleAccent
    ),
  ];

  static const _quickMixerTracks = [
    ('Ocean', Icons.graphic_eq_rounded, 'Ocean Waves', purpleAccent),
    ('Rain', Icons.grain_rounded, 'Soft Rain', mintAccent),
    ('Wind', Icons.air_rounded, 'Soothing Breeze', tealPrimary),
    ('Thunder', Icons.flash_on_rounded, 'Thunderstorm', coralAccent),
    ('Nature', Icons.eco_rounded, 'Mountain Stream', Colors.greenAccent),
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
          'Sleep Sanctuary Session',
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

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Stack(
      children: [
        // 🌌 Cosmic Night Sky Header Artwork Backdrop
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 320,
          child: ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.transparent],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstIn,
            child: Image.network(
              'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=1200&q=80',
              fit: BoxFit.cover,
            ),
          ),
        ),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF080F16).withOpacity(0.65),
                const Color(0xFF0D1E2C),
                const Color(0xFF070E15),
              ],
            ),
          ),
          child: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // ── Header (Pixel-Perfect to Screenshot) ───────────────
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Good Evening ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '🌙',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Sleep Sanctuary',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Everything you need for a perfect night\'s rest ♡',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.12)),
                          ),
                          child: const Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                              Positioned(
                                top: 11,
                                right: 12,
                                child: CircleAvatar(
                                  radius: 3.5,
                                  backgroundColor: purpleAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // ── Tonight's Journey Hero Card (Ocean Sleep) ───────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: purpleAccent.withOpacity(0.35), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: purpleAccent.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
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
                                      Colors.black.withOpacity(0.3),
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
                                          color: purpleAccent.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: purpleAccent.withOpacity(0.5)),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.star_rounded, color: purpleAccent, size: 12),
                                            SizedBox(width: 4),
                                            Text(
                                              'Tonight\'s Journey',
                                              style: TextStyle(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () => state.playGuidedSession('Cozy Bedtime Slumber', 45),
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.4),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                                          ),
                                          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
                                        ),
                                      ),
                                    ],
                                  ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Ocean Sleep',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Deep Relaxation',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Row(
                                        children: [
                                          Icon(Icons.schedule_rounded, size: 13, color: Colors.white60),
                                          SizedBox(width: 4),
                                          Text(
                                            '45 min • 🎵 Ocean + Rain',
                                            style: TextStyle(fontSize: 11.5, color: Colors.white60),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: [
                                      GlassPillButton(
                                        text: 'Begin Sleep',
                                        icon: Icons.play_arrow_rounded,
                                        containerColor: purpleAccent,
                                        contentColor: Colors.white,
                                        onTap: () => state.playGuidedSession('Cozy Bedtime Slumber', 45),
                                      ),
                                      const Spacer(),
                                      const AnimatedSoundWave(accentColor: purpleAccent),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Continue Listening Card ───────────────────────────
                    const Row(
                      children: [
                        Icon(Icons.access_time_rounded, color: purpleAccent, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Continue Listening',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    GlassCard(
                      cornerRadius: 22,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?auto=format&fit=crop&w=200&q=80',
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Rain on Window',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  '31 min remaining',
                                  style: TextStyle(fontSize: 11.5, color: Colors.white60),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: const LinearProgressIndicator(
                                          value: 0.68,
                                          backgroundColor: Colors.white10,
                                          valueColor: AlwaysStoppedAnimation<Color>(purpleAccent),
                                          minHeight: 4,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '68%',
                                      style: TextStyle(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          GlassPillButton(
                            text: 'Resume',
                            icon: Icons.play_arrow_rounded,
                            containerColor: purpleAccent.withOpacity(0.3),
                            contentColor: Colors.white,
                            onTap: () => state.applyCuratedPreset('🌧️ Rainy Cabin'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Wind Down Playlist (Horizontal 120x120 Carousel) ───
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: purpleAccent, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Wind Down Playlist',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'See All >',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: purpleAccent.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _playlists.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: GestureDetector(
                              onTap: () => state.applyCuratedPreset('🌧️ Rainy Cabin'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: item.$4.withOpacity(0.3)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: item.$4.withOpacity(0.2),
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
                                              item.$3,
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
                                    width: 120,
                                    child: Text(
                                      item.$1,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    item.$2,
                                    style: const TextStyle(fontSize: 11, color: Colors.white60),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Sleep Sounds Mixer (Quick Touch Buttons) ───────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.tune_rounded, color: purpleAccent, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Sleep Sounds Mixer',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => state.setTab(AppTab.sounds),
                          child: Text(
                            'Customize >',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: purpleAccent.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    GlassCard(
                      cornerRadius: 24,
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _quickMixerTracks.map((t) {
                          final label = t.$1;
                          final icon = t.$2;
                          final trackName = t.$3;
                          final color = t.$4;
                          final vol = state.getTrackVolume(trackName);
                          final isActive = vol > 0;

                          return GestureDetector(
                            onTap: () {
                              state.updateSoundTrackVolume(trackName, isActive ? 0.0 : 0.6);
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: isActive ? color.withOpacity(0.2) : Colors.white.withOpacity(0.06),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isActive ? color : Colors.white.withOpacity(0.15),
                                      width: 1.5,
                                    ),
                                    boxShadow: isActive
                                        ? [
                                            BoxShadow(
                                              color: color.withOpacity(0.4),
                                              blurRadius: 12,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Icon(
                                    icon,
                                    color: isActive ? color : Colors.white60,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
                                    color: isActive ? color : Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 44,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: vol.clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ],
);
  }
}
