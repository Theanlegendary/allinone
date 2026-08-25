import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090C),
      body: Stack(
        children: [
          // ── Atmospheric Background Photography & Vignette Glow ──
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?auto=format&fit=crop&w=1200&q=80',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF08090C)),
            ),
          ),

          // Deep Dark Obsidian Vignette Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF08090C).withOpacity(0.75),
                    const Color(0xFF08090C).withOpacity(0.60),
                    const Color(0xFF08090C).withOpacity(0.92),
                    const Color(0xFF08090C),
                  ],
                  stops: const [0.0, 0.35, 0.70, 1.0],
                ),
              ),
            ),
          ),

          // ── Main Content Area ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // 🌸 Top Brand Logo with 1-Tap Skip/Explore for Zero Friction
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 48), // Balance for center alignment
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.sparkles,
                            color: Color(0xFFFFFFFF),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Serenly',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 32,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.read<AppState>().completeOnboarding();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.8),
                          ),
                          child: Text(
                            'Skip',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // ── Hero Headline & Subtitle ──
                  Text(
                    'Step Into Stillness',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Create your account to discover guided experiences crafted for rest, focus, and renewal.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF94A3B8),
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Social & Email Auth Pill Buttons (Serenly Clean Frosted Glass) ──
                  _AuthPillButton(
                    icon: CupertinoIcons.mail_solid,
                    label: 'Continue with Email',
                    onTap: () => context.read<AppState>().completeOnboarding(),
                  ),
                  const SizedBox(height: 12),

                  _AuthPillButton(
                    icon: Icons.apple,
                    iconSize: 22,
                    label: 'Continue with Apple',
                    onTap: () => context.read<AppState>().completeOnboarding(),
                  ),
                  const SizedBox(height: 12),

                  _AuthPillButton(
                    customIcon: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'G',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    label: 'Continue with Google',
                    onTap: () => context.read<AppState>().completeOnboarding(),
                  ),

                  const SizedBox(height: 28),

                  // ── Legal Disclaimer & Login Prompt ──
                  Text(
                    'By continuing, you agree to our Terms and Privacy Policy,\nincluding how to opt out of promotions.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 18),

                  GestureDetector(
                    onTap: () => context.read<AppState>().completeOnboarding(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: const Color(0xFF94A3B8),
                          ),
                          children: const [
                            TextSpan(text: 'Have an account? '),
                            TextSpan(
                              text: 'Log In',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Translucent Glass Auth Button ─────────────────────────────────────────────
class _AuthPillButton extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final double iconSize;
  final String label;
  final VoidCallback onTap;

  const _AuthPillButton({
    this.icon,
    this.customIcon,
    this.iconSize = 19,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF1E212B).withOpacity(0.70),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.14),
          width: 0.8,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (customIcon != null) customIcon!,
                if (icon != null)
                  Icon(
                    icon,
                    color: Colors.white,
                    size: iconSize,
                  ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
