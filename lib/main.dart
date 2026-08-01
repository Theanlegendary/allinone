import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      title: 'Relax & Mindfulness',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AppShell(),
    );
  }
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

            const GuidedPlayerOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildScreen(AppTab tab) {
    switch (tab) {
      case AppTab.home:
        return const HomeScreen();
      case AppTab.meditate:
        return const MeditationScreen();
      case AppTab.breathe:
        return const BreatheScreen();
      case AppTab.sounds:
        return const SoundsScreen();
      case AppTab.sleep:
        return const SleepScreen();
      case AppTab.aiStudio:
        return const AiStudioScreen();
      default:
        return const HomeScreen();
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

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        state.setTab(tab);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? activeColor.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected ? activeColor : Colors.white.withOpacity(0.5),
                size: 20,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : Colors.white.withOpacity(0.5),
              ),
              child: Text(label),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 4 : 0,
              height: isSelected ? 4 : 0,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
