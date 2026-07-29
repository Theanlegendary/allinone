import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';
import 'package:relax_mindfulness/components/glass_components.dart';

class AiStudioScreen extends StatefulWidget {
  const AiStudioScreen({super.key});

  @override
  State<AiStudioScreen> createState() => _AiStudioScreenState();
}

class _AiStudioScreenState extends State<AiStudioScreen> {
  final TextEditingController _promptCtrl = TextEditingController();
  bool _isProModel = false;
  bool _isGenerating = false;

  static const _presetChips = [
    '🌊 Ocean Sunset & Piano',
    '🌧️ Rainy Window Lo-Fi',
    '🧘 Solfeggio 432Hz Healing',
    '🌌 Cosmic Deep Space Pad',
    '🌲 Alpine Forest Wind',
    '☕ Cozy Coffee Shop',
    '🌙 Moonlit Piano Lullaby',
    '🔥 Fireplace & Thunderstorm',
    '💚 Healing Nature Tones',
    '🛐 Tibetan Singing Bowls',
    '🌿 Zen Garden Bamboo',
    '✨ Ethereal Choir Pads',
  ];

  static const _curatedPlaylists = [
    ('432Hz Chakra Solfeggio', 'Healing Tones', '20', [Color(0xFF1B5E20), Color(0xFF4CAF50)]),
    ('Ocean Horizon Slumber', 'Deep Delta Waves', '30', [Color(0xFF0D47A1), Color(0xFF29B6F6)]),
    ('Rainy Windows Lo-Fi', 'Calm Focus Beats', '25', [Color(0xFF4A148C), Color(0xFFAB47BC)]),
    ('Alpine Whispering Winds', 'Nature Ambient', '15', [Color(0xFF004D40), Color(0xFF26A69A)]),
    ('Tibetan Monastery Bells', 'Meditation Sound Bath', '40', [Color(0xFF3E2723), Color(0xFF8D6E63)]),
    ('Cosmic Star Meditation', 'Theta Wave Drift', '35', [Color(0xFF1A237E), Color(0xFF7E57C2)]),
    ('Forest Bathing Therapy', 'Organic Nature Sounds', '22', [Color(0xFF33691E), Color(0xFF9CCC65)]),
    ('Delta Wave Deep Sleep', 'Deep Uninterrupted Sleep', '45', [Color(0xFF01579B), Color(0xFF0288D1)]),
    ('Japanese Zen Garden', 'Peaceful Koto & Bamboo', '28', [Color(0xFF827717), Color(0xFFD4E157)]),
    ('Binaural Focus Flow', 'Gamma Concentration', '18', [Color(0xFF263238), Color(0xFF78909C)]),
  ];

  void _generateMusic() {
    if (_promptCtrl.text.trim().isEmpty) return;
    setState(() => _isGenerating = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚡ Lyria AI preview generated! (Gemini API Key required for full live generation)'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _promptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bgDark, Color(0xFF0B1F1C), bgDark],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CURATED MOOD COLLECTIONS',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: tealPrimary,
                                letterSpacing: 1.8)),
                        Text('Intentional Playlists',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: textPrimary)),
                      ],
                    ),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DB954).withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF1DB954), size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Generate infinite custom ambient tracks using Google Lyria AI',
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6))),
              const SizedBox(height: 20),

              // Generator Card
              GlassCard(
                cornerRadius: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('GENERATE AMBIENT TRACK',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1DB954),
                                letterSpacing: 1.5)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1DB954).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('LYRIA 3 PRO', style: TextStyle(fontSize: 10, color: Color(0xFF1DB954), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _promptCtrl,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Describe your ambient mood... (e.g., Deep space drone with gentle piano)',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF1DB954)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Preset Chips
                    const Text('QUICK PROMPT IDEAS',
                        style: TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _presetChips.map((chip) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _promptCtrl.text = chip.substring(3);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.15)),
                            ),
                            child: Text(chip, style: const TextStyle(fontSize: 11, color: Colors.white)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Options & Generate Button
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ChoiceChip(
                              label: const Text('30s Clip'),
                              selected: !_isProModel,
                              selectedColor: tealPrimary,
                              onSelected: (val) => setState(() => _isProModel = !val),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('Full Track (Pro)'),
                              selected: _isProModel,
                              selectedColor: tealPrimary,
                              onSelected: (val) => setState(() => _isProModel = val),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1DB954),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          onPressed: _isGenerating ? null : _generateMusic,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : const Icon(Icons.auto_awesome_rounded, size: 18),
                          label: Text(_isGenerating ? 'Generating...' : 'Generate'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Curated Playlists Carousel
              const Text('CURATED AI SOUNDSCAPES',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1DB954),
                      letterSpacing: 1.5)),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _curatedPlaylists.length,
                  itemBuilder: (ctx, i) {
                    final item = _curatedPlaylists[i];
                    return Container(
                      width: 220,
                      margin: const EdgeInsets.only(right: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: item.$4 as List<Color>,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: (item.$4 as List<Color>)[0].withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('${item.$3} min',
                                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              const Spacer(),
                              const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 28),
                            ],
                          ),
                          const Spacer(),
                          Text(item.$1,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 2),
                          Text(item.$2,
                              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Saved Tracks Library
              const Text('YOUR SAVED AI SOUNDSCAPES',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1DB954),
                      letterSpacing: 1.5)),
              const SizedBox(height: 12),
              GlassCard(
                cornerRadius: 18,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text('🎧', style: TextStyle(fontSize: 36)),
                        const SizedBox(height: 8),
                        const Text('No generated tracks saved yet',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Generate your first ambient track above to save it here',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
