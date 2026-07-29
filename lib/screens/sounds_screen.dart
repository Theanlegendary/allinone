import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';
import 'package:relax_mindfulness/components/glass_components.dart';

class SoundsScreen extends StatefulWidget {
  const SoundsScreen({super.key});

  @override
  State<SoundsScreen> createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen> {
  bool _isPlaying = false;
  final Map<String, double> _volumes = {
    'Soft Rain': 0.3,
    'Ocean Waves': 0.3,
    'Mountain Stream': 0.0,
    'Soothing Breeze': 0.0,
    'Singing Bowls': 0.0,
    'Cozy Hearth': 0.0,
    'Thunderstorm': 0.0,
    'Forest Birds': 0.0,
    'Bamboo Chimes': 0.0,
    'Deep Space Drone': 0.0,
    'Ambient Piano': 0.0,
  };

  // Group 1: Natural Environment Sounds (Popular)
  static const _popularNaturalSounds = [
    ('🌧️', 'Soft Rain', 'Gentle Downpour', Color(0xFF42A5F5)),
    ('🌊', 'Ocean Waves', 'Rolling Pacific Tide', Color(0xFF26A69A)),
    ('🌲', 'Mountain Stream', 'Flowing Crystal Creek', Color(0xFF66BB6A)),
    ('🔥', 'Cozy Hearth', 'Warm Crackling Fire', Color(0xFFFF7043)),
    ('💨', 'Soothing Breeze', 'Calm Wind Sweep', Color(0xFF78909C)),
    ('⚡', 'Thunderstorm', 'Distant Low Rumble', Color(0xFF5C6BC0)),
  ];

  // Group 2: Advanced Healing Enhancements
  static const _advancedSounds = [
    ('🔮', 'Singing Bowls', '432Hz Solfeggio Tones', Color(0xFFAB47BC)),
    ('🪐', 'Deep Space Drone', '108Hz Delta Frequency', Color(0xFF00ACC1)),
    ('🎹', 'Ambient Piano', 'Generative Calm Chords', Color(0xFF8E24AA)),
    ('🐦', 'Forest Birds', 'Morning Canopy Chirp', Color(0xFF9CCC65)),
    ('🎋', 'Bamboo Chimes', 'Pentatonic Wind Chimes', Color(0xFF26C6DA)),
  ];

  void _applyVolumes(Map<String, double> vols, AppState state) {
    setState(() {
      _volumes.forEach((k, _) {
        final v = vols[k] ?? 0.0;
        _volumes[k] = v;
        state.updateSoundTrackVolume(k, v);
      });
      _isPlaying = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preset Applied ✓ Playing ambient soundscape'), duration: Duration(seconds: 1)),
    );
  }

  void _toggleMasterPlay(AppState state) {
    setState(() {
      _isPlaying = !_isPlaying;
      if (!_isPlaying) {
        state.stopAllAudio();
      } else {
        _volumes.forEach((name, vol) {
          if (vol > 0) {
            state.updateSoundTrackVolume(name, vol);
          }
        });
      }
    });
  }

  void _randomizeMix(AppState state) {
    final Map<String, double> newVols = {};
    _volumes.keys.forEach((key) {
      // 30% chance for track to be active
      final active = (DateTime.now().microsecondsSinceEpoch % 10) > 6;
      newVols[key] = active ? (0.2 + (DateTime.now().millisecondsSinceEpoch % 5) * 0.1) : 0.0;
    });
    _applyVolumes(newVols, state);
  }

  void _showSavePresetDialog(BuildContext context, AppState state) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Save Sound Preset', style: TextStyle(color: textPrimary)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. Rainy Study Night',
            hintStyle: TextStyle(color: textSecondary),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: tealPrimary.withOpacity(0.5))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: tealPrimary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: tealPrimary),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                state.savePreset(controller.text.trim(), Map.from(_volumes));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preset Saved ✓')),
                );
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackCard(
    (String, String, String, Color) t,
    AppState state,
  ) {
    final emoji = t.$1;
    final name = t.$2;
    final desc = t.$3;
    final color = t.$4;
    final vol = _volumes[name] ?? 0.0;
    final isActive = vol > 0 && _isPlaying;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        cornerRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 6),
                            AnimatedSoundWave(accentColor: color),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        desc,
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                    ],
                  ),
                ),

                Text(
                  '${(vol * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: vol > 0 ? color : textSecondary.withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 10),

                Switch(
                  value: vol > 0,
                  activeColor: color,
                  onChanged: (val) {
                    final newVol = val ? 0.6 : 0.0;
                    setState(() {
                      _volumes[name] = newVol;
                      _isPlaying = true;
                    });
                    state.updateSoundTrackVolume(name, newVol);
                  },
                ),
              ],
            ),

            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: vol > 0 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: color,
                    thumbColor: color,
                    overlayColor: color.withOpacity(0.15),
                  ),
                  child: Slider(
                    value: vol,
                    onChanged: (v) {
                      setState(() {
                        _volumes[name] = v;
                        _isPlaying = true;
                      });
                      state.updateSoundTrackVolume(name, v);
                    },
                  ),
                ),
              ),
            ),
          ],
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
          colors: [bgDark, bgMid, bgDark],
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
                                'AMBIENT SOUND MIXER',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: tealPrimary,
                                  letterSpacing: 1.8,
                                ),
                              ),
                              Text(
                                'Build Your Environment',
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
                          child: const Icon(Icons.tune_rounded, color: tealPrimary, size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Layer natural sounds & healing frequencies for work, study, or sleep',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                    const SizedBox(height: 20),

                    // Master Control Bar
                    GlassCard(
                      cornerRadius: 22,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _toggleMasterPlay(state),
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isPlaying ? tealPrimary : Colors.white.withOpacity(0.08),
                              ),
                              child: Icon(
                                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: _isPlaying ? Colors.black : Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isPlaying ? 'Soundscape Active 🔊' : 'Mixer Paused',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textPrimary),
                                ),
                                Text(
                                  _isPlaying
                                      ? '${_volumes.values.where((v) => v > 0).length} tracks playing'
                                      : 'Tap play to listen',
                                  style: TextStyle(fontSize: 12, color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.shuffle_rounded, color: textSecondary, size: 20),
                            onPressed: () => _randomizeMix(state),
                            tooltip: 'Randomize Mix',
                          ),
                          GlassPillButton(
                            text: 'Save',
                            icon: Icons.bookmark_add_rounded,
                            containerColor: Colors.white.withOpacity(0.12),
                            contentColor: textPrimary,
                            onTap: () => _showSavePresetDialog(context, state),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 1-TAP CURATED PRESET MIXES
                    const Text(
                      'CURATED ONE-TAP MIXES',
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
                        children: AppState.curatedPresets.entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GlassChip(
                              label: e.key,
                              onTap: () => _applyVolumes(e.value, state),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // POPULAR NATURAL SOUNDS HEADER
                    Row(
                      children: [
                        const Icon(Icons.park_rounded, color: mintAccent, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'NATURAL ENVIRONMENT SOUNDS',
                          style: TextStyle(
                            fontSize: 11,
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

            // LIST OF POPULAR NATURAL SOUNDS
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildTrackCard(_popularNaturalSounds[i], state),
                  childCount: _popularNaturalSounds.length,
                ),
              ),
            ),

            // ADVANCED HEALING ENHANCEMENTS HEADER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    const Icon(Icons.graphic_eq_rounded, color: purpleAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'ADVANCED HEALING ENHANCEMENTS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: textSecondary,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // LIST OF ADVANCED SOUNDS
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildTrackCard(_advancedSounds[i], state),
                  childCount: _advancedSounds.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
