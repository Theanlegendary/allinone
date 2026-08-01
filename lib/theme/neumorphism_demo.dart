import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';

// ─── Neumorphic Theme Demo & Showcase Screen ──────────────────────────────────
class NeumorphismDemoScreen extends StatefulWidget {
  const NeumorphismDemoScreen({super.key});

  @override
  State<NeumorphismDemoScreen> createState() => _NeumorphismDemoScreenState();
}

class _NeumorphismDemoScreenState extends State<NeumorphismDemoScreen> {
  bool _isButtonPressed = false;
  bool _isSwitchOn = true;
  double _sliderValue = 0.65;
  int _selectedChip = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final isNeumorphicActive = state.themeMode == SanctuaryThemeMode.neumorphism;

        return Scaffold(
          backgroundColor: neuSurface,
          appBar: AppBar(
            backgroundColor: neuSurface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: neuText),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Neumorphism (Soft UI)',
              style: TextStyle(color: neuText, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TextButton.icon(
                  onPressed: () {
                    if (isNeumorphicActive) {
                      state.setThemeMode(SanctuaryThemeMode.midnightNavy);
                    } else {
                      state.setThemeMode(SanctuaryThemeMode.neumorphism);
                    }
                  },
                  icon: Icon(
                    isNeumorphicActive ? Icons.check_circle_rounded : Icons.palette_outlined,
                    color: neuAccent,
                    size: 18,
                  ),
                  label: Text(
                    isNeumorphicActive ? 'Applied ✓' : 'Apply Theme',
                    style: const TextStyle(color: neuAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Theme Header Card
                _buildNeuCard(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: neuSurface,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(color: neuDarkShadow, offset: Offset(8, 8), blurRadius: 16),
                            BoxShadow(color: neuLightShadow, offset: Offset(-8, -8), blurRadius: 16),
                          ],
                        ),
                        child: const Center(
                          child: Text('🎨', style: TextStyle(fontSize: 36)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Neumorphism (Soft UI)',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: neuText,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Extruded dual shadows • Soft monochromatic surface • Subtle depth (Era: 2019–2020)',
                        style: TextStyle(fontSize: 13, color: neuSubtext, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildColorTag('Surface #E0E5EC', neuSurface),
                          const SizedBox(width: 8),
                          _buildColorTag('Accent #6C757D', neuAccent, isDark: true),
                          const SizedBox(width: 8),
                          _buildColorTag('Text #3D3D3D', neuText, isDark: true),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                const Text(
                  'INTERACTIVE NEUMORPHIC COMPONENTS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: neuAccent,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Buttons (Extruded vs Inset)
                _buildNeuCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1. Buttons & Controls',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: neuText),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tap the button to toggle between Extruded (Outward) and Inset (Pressed) states:',
                        style: TextStyle(fontSize: 12, color: neuSubtext),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Extruded / Inset Toggle Button
                          Expanded(
                            child: GestureDetector(
                              onTapDown: (_) => setState(() => _isButtonPressed = true),
                              onTapUp: (_) => setState(() => _isButtonPressed = false),
                              onTapCancel: () => setState(() => _isButtonPressed = false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                height: 54,
                                decoration: BoxDecoration(
                                  color: neuSurface,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: _isButtonPressed
                                      ? [
                                          // Inset simulation
                                          BoxShadow(
                                            color: neuDarkShadow.withOpacity(0.8),
                                            offset: const Offset(2, 2),
                                            blurRadius: 4,
                                          ),
                                        ]
                                      : const [
                                          BoxShadow(
                                            color: neuDarkShadow,
                                            offset: Offset(6, 6),
                                            blurRadius: 12,
                                          ),
                                          BoxShadow(
                                            color: neuLightShadow,
                                            offset: Offset(-6, -6),
                                            blurRadius: 12,
                                          ),
                                        ],
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _isButtonPressed ? Icons.touch_app_rounded : Icons.play_arrow_rounded,
                                        color: neuAccent,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isButtonPressed ? 'PRESSED (INSET)' : 'EXTRUDED BUTTON',
                                        style: TextStyle(
                                          color: neuText,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Neumorphic Toggle Switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Soft UI Toggle Switch', style: TextStyle(color: neuText, fontWeight: FontWeight.w600, fontSize: 14)),
                              Text('Monochromatic state transition', style: TextStyle(color: neuSubtext, fontSize: 12)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _isSwitchOn = !_isSwitchOn),
                            child: Container(
                              width: 60,
                              height: 32,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: neuSurface,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(color: neuDarkShadow, offset: Offset(3, 3), blurRadius: 6),
                                  BoxShadow(color: neuLightShadow, offset: Offset(-3, -3), blurRadius: 6),
                                ],
                              ),
                              child: AnimatedAlign(
                                duration: const Duration(milliseconds: 200),
                                alignment: _isSwitchOn ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: _isSwitchOn ? neuAccent : neuSurface,
                                    shape: BoxShape.circle,
                                    boxShadow: _isSwitchOn
                                        ? [BoxShadow(color: neuAccent.withOpacity(0.4), blurRadius: 8)]
                                        : const [
                                            BoxShadow(color: neuDarkShadow, offset: Offset(2, 2), blurRadius: 4),
                                            BoxShadow(color: neuLightShadow, offset: Offset(-2, -2), blurRadius: 4),
                                          ],
                                  ),
                                  child: Icon(
                                    _isSwitchOn ? Icons.check_rounded : Icons.close_rounded,
                                    size: 14,
                                    color: _isSwitchOn ? Colors.white : neuSubtext,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 3. Neumorphic Breathing Orb
                _buildNeuCard(
                  child: Column(
                    children: [
                      const Text(
                        '2. Soft UI Breathing Orb',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: neuText),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: neuSurface,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(color: neuDarkShadow, offset: Offset(12, 12), blurRadius: 24),
                            BoxShadow(color: neuLightShadow, offset: Offset(-12, -12), blurRadius: 24),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: neuSurface,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(color: neuDarkShadow, offset: Offset(6, 6), blurRadius: 12),
                                BoxShadow(color: neuLightShadow, offset: Offset(-6, -6), blurRadius: 12),
                              ],
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('💨', style: TextStyle(fontSize: 28)),
                                  SizedBox(height: 2),
                                  Text(
                                    'INHALE',
                                    style: TextStyle(
                                      color: neuAccent,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Concentric Neumorphic depth layers create a tactile 3D orb feeling',
                        style: TextStyle(fontSize: 12, color: neuSubtext),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 4. Neumorphic Chips & Slider
                _buildNeuCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '3. Chips & Slider',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: neuText),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(3, (i) {
                          final labels = ['😌 Calm', '😴 Sleep', '🧠 Focus'];
                          final isSelected = _selectedChip == i;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedChip = i),
                              child: Container(
                                margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: neuSurface,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: neuDarkShadow.withOpacity(0.6),
                                            offset: const Offset(2, 2),
                                            blurRadius: 4,
                                          ),
                                        ]
                                      : const [
                                          BoxShadow(color: neuDarkShadow, offset: Offset(4, 4), blurRadius: 8),
                                          BoxShadow(color: neuLightShadow, offset: Offset(-4, -4), blurRadius: 8),
                                        ],
                                ),
                                child: Center(
                                  child: Text(
                                    labels[i],
                                    style: TextStyle(
                                      color: isSelected ? neuAccent : neuText,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Volume Level', style: TextStyle(color: neuText, fontWeight: FontWeight.w600, fontSize: 13)),
                          Text('${(_sliderValue * 100).toInt()}%', style: const TextStyle(color: neuAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: neuAccent,
                          inactiveTrackColor: neuDarkShadow.withOpacity(0.4),
                          thumbColor: neuSurface,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 4),
                          overlayColor: neuAccent.withOpacity(0.15),
                        ),
                        child: Slider(
                          value: _sliderValue,
                          onChanged: (v) => setState(() => _sliderValue = v),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 5. Verdict & Comparison Card
                _buildNeuCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('⚖️', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 8),
                          Text(
                            'Design Evaluation: Is Neumorphism Cool?',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: neuText),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildBullet('PRO', 'Clean, soft, tactile feel — very relaxing for eye strain.', true),
                      _buildBullet('PRO', 'Creates a unique physical hardware/instrument panel aesthetic.', true),
                      _buildBullet('CON', 'Low contrast outdoors — harder to read in bright sunlight.', false),
                      _buildBullet('CON', 'Requires light background (`#E0E5EC`), losing dark mode vibe.', false),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: neuSurface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: neuDarkShadow, offset: Offset(3, 3), blurRadius: 6),
                            BoxShadow(color: neuLightShadow, offset: Offset(-3, -3), blurRadius: 6),
                          ],
                        ),
                        child: Text(
                          isNeumorphicActive
                              ? '✅ Neumorphism theme is currently ACTIVE across Sanctuary!'
                              : '💡 Tap "Apply Theme" at the top right to try Neumorphism on all screens.',
                          style: const TextStyle(fontSize: 12, color: neuAccent, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNeuCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: neuSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: neuDarkShadow, offset: Offset(9, 9), blurRadius: 18),
          BoxShadow(color: neuLightShadow, offset: Offset(-9, -9), blurRadius: 18),
        ],
      ),
      child: child,
    );
  }

  Widget _buildColorTag(String label, Color color, {bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: neuDarkShadow.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : neuText,
        ),
      ),
    );
  }

  Widget _buildBullet(String tag, String text, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isPositive ? const Color(0xFF52B788) : const Color(0xFFE29578),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              tag,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 9),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: neuText, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
