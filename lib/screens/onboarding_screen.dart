import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';
import 'package:relax_mindfulness/components/glass_components.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _ctrl = PageController();
  int _page = 0;

  static const _backgroundGradients = [
    [Color(0xFF09141D), Color(0xFF0F2634), Color(0xFF081017)],
    [Color(0xFF0A121A), Color(0xFF142431), Color(0xFF081119)],
    [Color(0xFF0F1A24), Color(0xFF1A2E3D), Color(0xFF0A131C)],
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 2) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background ambient gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _backgroundGradients[_page],
              ),
            ),
          ),

          // Subtle background ambient light glow
          Positioned(
            top: -60,
            right: -40,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _page == 0
                    ? tealPrimary.withOpacity(0.12)
                    : _page == 1
                        ? mintAccent.withOpacity(0.12)
                        : coralAccent.withOpacity(0.12),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _ctrl,
                    onPageChanged: (p) => setState(() => _page = p),
                    children: const [_Slide1(), _Slide2(), _Slide3()],
                  ),
                ),

                // Navigation Footer
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  child: Column(
                    children: [
                      // Smooth Page Indicator Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (i) {
                          final isSelected = i == _page;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: isSelected ? 28 : 7,
                            height: 7,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? tealPrimary : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),

                      // Navigation Buttons
                      if (_page < 2)
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => context.read<AppState>().completeOnboarding(),
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.45),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Spacer(),
                            GlassPillButton(
                              text: 'Continue →',
                              onTap: _next,
                            ),
                          ],
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () => context.read<AppState>().completeOnboarding(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [tealPrimary, mintAccent],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: tealPrimary.withOpacity(0.35),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'Begin Your Practice',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
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
    );
  }
}

// ── Slide 1 ──────────────────────────────────────────────────────────────────
class _Slide1 extends StatelessWidget {
  const _Slide1();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hero Glowing Lotus Badge
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tealPrimary.withOpacity(0.12),
              border: Border.all(color: tealPrimary.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: tealPrimary.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.spa_rounded,
              color: tealPrimary,
              size: 54,
            ),
          ),
          const SizedBox(height: 36),

          const Text(
            'Relax & Mindfulness',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'A quiet space to restore focus, calm your mind, and prepare for deep, restful sleep.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.65),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_rounded, color: tealPrimary, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Designed for daily serenity',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slide 2 ──────────────────────────────────────────────────────────────────
class _Slide2 extends StatelessWidget {
  const _Slide2();

  static const _features = [
    (Icons.self_improvement_rounded, 'Guided Meditation', 'Sessions for stress relief, focus & clarity', tealPrimary),
    (Icons.air_rounded, 'Breathing Exercises', 'Box, 4-7-8, and resonance breathing patterns', mintAccent),
    (Icons.equalizer_rounded, 'Ambient Sound Mixer', '11 customizable continuous audio tracks', coralAccent),
    (Icons.nightlight_round, 'Bedtime Sleep Stories', 'Narrated journeys with auto-fade sleep timer', purpleAccent),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Everything You Need',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Simple, effective tools crafted for daily peace.',
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.55)),
          ),
          const SizedBox(height: 28),

          ..._features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GlassCard(
                  cornerRadius: 18,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: f.$4.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(f.$1, color: f.$4, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f.$2,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              f.$3,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// ── Slide 3 ──────────────────────────────────────────────────────────────────
class _Slide3 extends StatelessWidget {
  const _Slide3();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hero Frosted Glass Checkmark Badge (Replaces generic green box emoji)
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: mintAccent.withOpacity(0.12),
              border: Border.all(color: mintAccent.withOpacity(0.35), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: mintAccent.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: mintAccent,
              size: 48,
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            'Ready to Begin',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Build consistency, track your mindful minutes, and find your quiet center every day.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.65),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 32),

          // Apple-style Glass Highlights Card
          GlassCard(
            cornerRadius: 20,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            child: Row(
              children: const [
                Expanded(
                  child: _HighlightTile(
                    icon: Icons.local_fire_department_rounded,
                    color: coralAccent,
                    title: 'Streaks',
                    subtitle: 'Daily habit',
                  ),
                ),
                Expanded(
                  child: _HighlightTile(
                    icon: Icons.insights_rounded,
                    color: tealPrimary,
                    title: 'Insights',
                    subtitle: 'Weekly stats',
                  ),
                ),
                Expanded(
                  child: _HighlightTile(
                    icon: Icons.spa_rounded,
                    color: mintAccent,
                    title: 'Calm',
                    subtitle: 'On demand',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _HighlightTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
