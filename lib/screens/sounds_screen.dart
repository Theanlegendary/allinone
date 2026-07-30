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
  String _selectedCategory = '🌧️ Rain';

  // 75 Sound Volumes State Map
  final Map<String, double> _volumes = {
    // Rain (12)
    'Soft Rain': 0.3, 'Heavy Rain': 0.0, 'Rain on Window': 0.0, 'Rain on Roof': 0.0,
    'Rain on Umbrella': 0.0, 'Rain on Tent': 0.0, 'Thunderstorm': 0.0, 'Rain on Leaves': 0.0,
    'Urban Rain': 0.0, 'Light Drizzle': 0.0, 'Rain Cave': 0.0, 'Tropical Storm': 0.0,
    // Nature (15)
    'Ocean Waves': 0.3, 'Mountain Stream': 0.0, 'Forest Birds': 0.0, 'Campfire': 0.0,
    'Wind in Trees': 0.0, 'Crickets': 0.0, 'Waterfall': 0.0, 'Frogs': 0.0,
    'Waves on Pebbles': 0.0, 'Underwater': 0.0, 'Meadow Breeze': 0.0, 'Desert Wind': 0.0,
    'Jungle Night': 0.0, 'Leaves Rustling': 0.0, 'Mountain Echo': 0.0,
    // Places (10)
    'Coffee Shop': 0.0, 'Library': 0.0, 'Office Ambience': 0.0, 'Church Bells': 0.0,
    'Quiet Park': 0.0, 'Street Market': 0.0, 'Temple Bowl': 0.0, 'Zen Garden': 0.0,
    'Harbor': 0.0, 'Farmyard': 0.0,
    // Transport (8)
    'Train Track': 0.0, 'Airplane Cabin': 0.0, 'Driving Rain Car': 0.0, 'Boat Deck': 0.0,
    'Subway Train': 0.0, 'Bicycle Ride': 0.0, 'Sailing Ship': 0.0, 'Highway Traffic': 0.0,
    // Things (10)
    'Clock Ticking': 0.0, 'Fan Noise': 0.0, 'Keyboard Typing': 0.0, 'Washing Machine': 0.0,
    'Vinyl Crackle': 0.0, 'Boiling Kettle': 0.0, 'Bamboo Chimes': 0.0, 'Page Turning': 0.0,
    'Pendulum': 0.0, 'Wind Generator': 0.0,
    // Noise Colors (6)
    'White Noise': 0.0, 'Pink Noise': 0.0, 'Brown Noise': 0.0, 'Blue Noise': 0.0,
    'Violet Noise': 0.0, 'Grey Noise': 0.0,
    // Solfeggio (14)
    'Singing Bowls': 0.0, '432Hz Healing': 0.0, '528Hz Transformation': 0.0, '639Hz Harmonics': 0.0,
    '108Hz Theta Drone': 0.0, 'Deep Space Drone': 0.0, 'Delta Deep Sleep': 0.0, 'Alpha Focus Flow': 0.0,
    'Beta Energy Boost': 0.0, 'Gamma Insight': 0.0, '174Hz Pain Relief': 0.0, '285Hz Cellular': 0.0,
    '396Hz Liberation': 0.0, '741Hz Intuition': 0.0, '852Hz Awakening': 0.0, '963Hz Crown State': 0.0,
    'Ambient Piano': 0.0, 'Cozy Hearth': 0.0, 'Soothing Breeze': 0.0,
  };

  static const Map<String, List<(String, String, String, Color)>> soundCategories = {
    '🌧️ Rain': [
      ('🌧️', 'Soft Rain', 'Gentle Downpour', Color(0xFF42A5F5)),
      ('⛈️', 'Thunderstorm', 'Distant Low Rumble', Color(0xFF5C6BC0)),
      ('🪟', 'Rain on Window', 'Soft Drops on Glass', Color(0xFF29B6F6)),
      ('🏠', 'Rain on Roof', 'Cozy Attic Downpour', Color(0xFF0288D1)),
      ('🌂', 'Rain on Umbrella', 'Rhythmic Pitter Patter', Color(0xFF039BE5)),
      ('⛺', 'Rain on Tent', 'Wilderness Camping Rain', Color(0xFF00ACC1)),
      ('🍃', 'Rain on Leaves', 'Forest Canopy Drizzle', Color(0xFF26A69A)),
      ('🏙️', 'Urban Rain', 'City Street Rainfall', Color(0xFF78909C)),
      ('🌧️', 'Heavy Rain', 'Continuous Pouring Storm', Color(0xFF1E88E5)),
      ('🌧️', 'Light Drizzle', 'Gentle Atmospheric Mist', Color(0xFF80DEEA)),
      ('洞', 'Rain Cave', 'Echoing Cavern Drops', Color(0xFF3F51B5)),
      ('🌴', 'Tropical Storm', 'Warm Rainforest Gale', Color(0xFF00897B)),
    ],
    '🌲 Nature': [
      ('🌊', 'Ocean Waves', 'Rolling Pacific Tide', Color(0xFF26A69A)),
      ('🏞️', 'Mountain Stream', 'Flowing Crystal Creek', Color(0xFF66BB6A)),
      ('🐦', 'Forest Birds', 'Morning Canopy Chirp', Color(0xFF9CCC65)),
      ('🔥', 'Campfire', 'Warm Crackling Wood Logs', Color(0xFFFF7043)),
      ('💨', 'Wind in Trees', 'Calm Mountain Breeze', Color(0xFF78909C)),
      ('🦗', 'Crickets', 'Night Meadow Symphony', Color(0xFF8D6E63)),
      ('🌊', 'Waterfall', 'Majestic Cascade Spray', Color(0xFF00BCD4)),
      ('🐸', 'Frogs', 'Serene Marshland Night', Color(0xFF4CAF50)),
      ('🪨', 'Waves on Pebbles', 'Gentle Shoreline Shimmer', Color(0xFF80CBC4)),
      ('🤿', 'Underwater', 'Deep Ocean Submersion', Color(0xFF0277BD)),
      ('🌾', 'Meadow Breeze', 'Soft Grasslands Whispers', Color(0xFFAED581)),
      ('🏜️', 'Desert Wind', 'Solitary Dune Sweep', Color(0xFFFFB74D)),
      ('🌴', 'Jungle Night', 'Nocturnal Rainforest', Color(0xFF2E7D32)),
      ('🍂', 'Leaves Rustling', 'Autumn Footsteps', Color(0xFFD84315)),
      ('⛰️', 'Mountain Echo', 'Resonant Valley Stillness', Color(0xFF546E7A)),
    ],
    '☕ Places': [
      ('☕', 'Coffee Shop', 'Gentle Ambient Chatter', Color(0xFF8D6E63)),
      ('📚', 'Library', 'Silent Study Sanctuary', Color(0xFF5D4037)),
      ('🏢', 'Office Ambience', 'Low Productivity Hum', Color(0xFF78909C)),
      ('🔔', 'Church Bells', 'Distant Resonant Chimes', Color(0xFFFFB300)),
      ('🌳', 'Quiet Park', 'Peaceful Bench Retreat', Color(0xFF7CB342)),
      ('🛍️', 'Street Market', 'Soft Bustling Market', Color(0xFFFB8C00)),
      ('🥣', 'Temple Bowl', 'Zen Monastery Gong', Color(0xFFAB47BC)),
      ('🎍', 'Zen Garden', 'Raked Sand Fountain', Color(0xFF00ACC1)),
      ('⚓', 'Harbor', 'Gentle Boat Dock Lapping', Color(0xFF0288D1)),
      ('🚜', 'Farmyard', 'Rural Countryside', Color(0xFF8BC34A)),
    ],
    '🚆 Transport': [
      ('🚆', 'Train Track', 'Rhythmic Iron Rail Clicker', Color(0xFF546E7A)),
      ('✈️', 'Airplane Cabin', 'Soothing White Noise Cruise', Color(0xFF0288D1)),
      ('🚗', 'Driving Rain Car', 'Highway Windshield Rain', Color(0xFF455A64)),
      ('⛵', 'Boat Deck', 'Creaking Wooden Hull Waves', Color(0xFF0097A7)),
      ('🚇', 'Subway Train', 'Low Underground Metro', Color(0xFF37474F)),
      ('🚲', 'Bicycle Ride', 'Gentle Coasting Wind', Color(0xFF689F38)),
      ('⛵', 'Sailing Ship', 'Rigging Breeze & Swell', Color(0xFF00838F)),
      ('🛣️', 'Highway Traffic', 'Distant Asphalt Roll', Color(0xFF607D8B)),
    ],
    '⚙️ Things': [
      ('🕰️', 'Clock Ticking', 'Steady Rhythmic Pendulum', Color(0xFF78909C)),
      ('🌀', 'Fan Noise', 'Cooling Air Circulation', Color(0xFF00ACC1)),
      ('⌨️', 'Keyboard Typing', 'Soft Mechanical Keys', Color(0xFF546E7A)),
      ('🧺', 'Washing Machine', 'Gentle Laundry Rinsing', Color(0xFF0288D1)),
      ('📻', 'Vinyl Crackle', 'Warm Analog Nostalgia', Color(0xFF8D6E63)),
      ('🫖', 'Boiling Kettle', 'Cozy Teatime Whistle', Color(0xFFFF7043)),
      ('🎋', 'Bamboo Chimes', 'Pentatonic Wind Chimes', Color(0xFF26C6DA)),
      ('📖', 'Page Turning', 'Book Study Leaf', Color(0xFFA1887F)),
      ('⏱️', 'Pendulum', 'Hypnotic Second Beat', Color(0xFF455A64)),
      ('💨', 'Wind Generator', 'Constant Turbine Sweep', Color(0xFF90A4AE)),
    ],
    '🔊 Noise': [
      ('⚪', 'White Noise', 'Full Spectrum Flat Noise', Color(0xFFCFD8DC)),
      ('🌸', 'Pink Noise', 'Balanced Waterfall Spectrum', Color(0xFFF48FB1)),
      ('🤎', 'Brown Noise', 'Deep Low Frequency Rumble', Color(0xFF8D6E63)),
      ('🔵', 'Blue Noise', 'High Pitch Crisp Hiss', Color(0xFF64B5F6)),
      ('💜', 'Violet Noise', 'Ultra Crisp Shimmer', Color(0xFFBA68C8)),
      ('🩶', 'Grey Noise', 'Equal Perception Contour', Color(0xFF90A4AE)),
    ],
    '🔮 Solfeggio': [
      ('🧘', '432Hz Healing', 'Natural Harmony Tone', Color(0xFFAB47BC)),
      ('✨', '528Hz Transformation', 'Miracle Healing Frequency', Color(0xFF00E676)),
      ('💖', '639Hz Harmonics', 'Heart Relationship Harmony', Color(0xFFFF4081)),
      ('🧠', '108Hz Theta Drone', 'Deep Meditation State', Color(0xFF00ACC1)),
      ('💤', 'Delta Deep Sleep', 'Restful Subconscious Waves', Color(0xFF3F51B5)),
      ('⚡', 'Alpha Focus Flow', 'Peak Concentration Alpha Waves', Color(0xFFFFC107)),
      ('🔥', 'Beta Energy Boost', 'Active Consciousness', Color(0xFFFF5722)),
      ('🌌', 'Gamma Insight', 'High Cognitive Transcendence', Color(0xFF9C27B0)),
      ('🛡️', '174Hz Pain Relief', 'Physical Comfort Frequency', Color(0xFF4CAF50)),
      ('🌿', '285Hz Cellular', 'Vitality & Tissue Renewal', Color(0xFF8BC34A)),
      ('🕊️', '396Hz Liberation', 'Liberating Guilt & Fear', Color(0xFF00BCD4)),
      ('👁️', '741Hz Intuition', 'Awakening Inner Intuition', Color(0xFF7C4DFF)),
      ('✡️', '852Hz Awakening', 'Spiritual Order & Light', Color(0xFFE040FB)),
      ('👑', '963Hz Crown State', 'Divine Unity Consciousness', Color(0xFFFFD700)),
    ],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      final cached = state.cachedVolumes;
      if (cached.isNotEmpty) {
        setState(() {
          cached.forEach((k, v) {
            if (_volumes.containsKey(k)) {
              _volumes[k] = v;
            }
          });
          _isPlaying = _volumes.values.any((v) => v > 0);
        });
      }
    });
  }

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
    state.saveCachedVolumes(_volumes);
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

  void _showRenamePresetDialog(BuildContext context, String currentName, AppState state) {
    final displayName = state.getPresetDisplayName(currentName);
    final controller = TextEditingController(text: displayName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Rename Recommended Mix', style: TextStyle(color: textPrimary)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter custom name',
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
                state.renameCuratedPreset(currentName, controller.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Renamed to "${controller.text.trim()}" ✓')),
                );
              }
            },
            child: const Text('Save Name', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                          final displayName = state.getPresetDisplayName(e.key);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onLongPress: () => _showRenamePresetDialog(context, e.key, state),
                              child: GlassChip(
                                label: displayName,
                                onTap: () => _applyVolumes(e.value, state),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // MESSENGER-STYLE HORIZONTAL CATEGORY FILTER TRAY
                    Row(
                      children: [
                        const Icon(Icons.category_rounded, color: tealPrimary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'SOUND CATEGORY TRAY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: textSecondary,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: soundCategories.keys.map((catKey) {
                          final isSelected = _selectedCategory == catKey;
                          final soundCount = soundCategories[catKey]?.length ?? 0;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GlassChip(
                              label: '$catKey ($soundCount)',
                              isSelected: isSelected,
                              selectedColor: tealPrimary,
                              onTap: () {
                                setState(() {
                                  _selectedCategory = catKey;
                                });
                              },
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

            // LIST OF SOUND CARDS FOR SELECTED CATEGORY
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final currentList = soundCategories[_selectedCategory] ?? [];
                    if (i >= currentList.length) return const SizedBox.shrink();
                    return _buildTrackCard(currentList[i], state);
                  },
                  childCount: (soundCategories[_selectedCategory] ?? []).length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
