import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';
import 'package:relax_mindfulness/screens/home_screen.dart';
import 'package:relax_mindfulness/screens/onboarding_screen.dart';
import 'package:relax_mindfulness/screens/meditation_screen.dart';
import 'package:relax_mindfulness/screens/breathe_screen.dart';
import 'package:relax_mindfulness/screens/sounds_screen.dart';
import 'package:relax_mindfulness/screens/sleep_screen.dart';
import 'package:relax_mindfulness/screens/mindfulness_screen.dart';
import 'package:relax_mindfulness/screens/ai_studio_screen.dart';
import 'package:relax_mindfulness/screens/admin_dashboard_screen.dart';
import 'package:relax_mindfulness/screens/premium_screen.dart';
import 'package:relax_mindfulness/components/glass_components.dart';
import 'package:relax_mindfulness/theme/responsive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode for a clean app experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Make status bar transparent for edge-to-edge design
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
  ));

  final appState = AppState();
  await appState.init();

  // ── GPU & Image Cache tuning for maximum FPS ──
  // Doubles the default image cache so images don't re-decode on every scroll
  PaintingBinding.instance.imageCache.maximumSizeBytes = 200 << 20; // 200 MB
  PaintingBinding.instance.imageCache.maximumSize = 200; // max 200 images
  // Use Skia rendering pipeline (CanvasKit) — already default in release
  // Enable all platform optimizations
  debugPaintSizeEnabled = false;

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const RelaxApp(),
    ),
  );
}

class RelaxApp extends StatelessWidget {
  const RelaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sanctuary – Relax & Meditate',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // ── iOS-native scroll physics globally ──
      // This gives the elastic bounce and momentum feel of native iOS
      scrollBehavior: const _IOSScrollBehavior(),
      home: const AppShell(),
    );
  }
}

// ── Global iOS Bouncing Scroll Behavior ──────────────────────────────────────
// Makes EVERY ScrollView in the whole app behave like native iOS:
// elastic overscroll bounce + momentum fling with proper deceleration
class _IOSScrollBehavior extends ScrollBehavior {
  const _IOSScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) =>
      child; // No scrollbars — pure app feel

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (!state.onboardingDone) {
          return const OnboardingScreen();
        }

        return Stack(
          children: [
            Scaffold(
              extendBody: true,
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: KeyedSubtree(
                  key: ValueKey(state.tab),
                  child: _buildScreen(state.tab),
                ),
              ),
              bottomNavigationBar: const _BottomNavBar(),
            ),

            if (state.isAnyAudioPlaying)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 68,
                child: SanctuaryMiniPlayer(),
              ),

            if (state.showMoodDialog)
              MoodCheckInDialog(
                onMoodSelected: (rating) => state.submitMood(rating),
                onSkip: () => state.dismissMood(),
              ),

            if (state.isGuidedPlaying)
              const GuidedPlayerOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildScreen(AppTab tab) {
    // ── RepaintBoundary isolates each screen in its own GPU layer ──
    // This prevents tab switches and animations from causing full-tree repaints
    // = dramatically fewer dropped frames = native 60fps feel
    switch (tab) {
      case AppTab.home:
        return const RepaintBoundary(key: ValueKey('home'), child: HomeScreen());
      case AppTab.meditate:
        return const RepaintBoundary(key: ValueKey('meditate'), child: MeditationScreen());
      case AppTab.breathe:
        return const RepaintBoundary(key: ValueKey('breathe'), child: BreatheScreen());
      case AppTab.sounds:
        return const RepaintBoundary(key: ValueKey('sounds'), child: SoundsScreen());
      case AppTab.sleep:
        return const RepaintBoundary(key: ValueKey('sleep'), child: SleepScreen());
      case AppTab.aiStudio:
        return const RepaintBoundary(key: ValueKey('ai'), child: AiStudioScreen());
      default:
        return const RepaintBoundary(key: ValueKey('home'), child: HomeScreen());
    }
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: EdgeInsets.only(
            top: 6,
            bottom: MediaQuery.of(context).padding.bottom > 0
                ? MediaQuery.of(context).padding.bottom
                : 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xF00A151E),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(tab: AppTab.home, icon: Icons.home_rounded, label: 'Home', state: state),
              _NavItem(tab: AppTab.meditate, icon: Icons.self_improvement_rounded, label: 'Meditate', state: state),
              _NavItem(tab: AppTab.breathe, icon: Icons.air_rounded, label: 'Breathe', state: state),
              _NavItem(tab: AppTab.sounds, icon: Icons.equalizer_rounded, label: 'Sounds', state: state),
              _NavItem(tab: AppTab.sleep, icon: Icons.nightlight_round, label: 'Sleep', state: state),
              // Premium crown button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => const PremiumScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: state.isPremium
                              ? const LinearGradient(
                                  colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                                )
                              : null,
                          color: state.isPremium ? null : Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: state.isPremium
                              ? [BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 10)]
                              : [],
                        ),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          color: state.isPremium
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.isPremium ? 'Premium' : 'Upgrade',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.normal,
                          color: state.isPremium
                              ? const Color(0xFFFFD700)
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final AppTab tab;
  final IconData icon;
  final String label;
  final AppState state;

  const _NavItem({
    required this.tab,
    required this.icon,
    required this.label,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = state.tab == tab;
    final activeColor = tab == AppTab.sleep ? purpleAccent : tealPrimary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          state.setTab(tab);
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── 🍎 iPhone Liquid Nav Rule: Active = Filled Circle with Pure White Icon, Inactive = Dark/Gray No Fill ──
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? activeColor : Colors.transparent,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: activeColor.withOpacity(0.45),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.white38,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              // ── Crisp Readable Label ──
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? activeColor : Colors.white60,
                  letterSpacing: -0.2,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

