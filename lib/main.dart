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
import 'package:relax_mindfulness/components/glass_components.dart';

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
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom > 0
                ? MediaQuery.of(context).padding.bottom
                : 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xD90E1B22),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: glassBorder, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(tab: AppTab.home, icon: Icons.home_rounded, label: 'Home', state: state),
              _NavItem(tab: AppTab.meditate, icon: Icons.self_improvement, label: 'Meditate', state: state),
              _NavItem(tab: AppTab.breathe, icon: Icons.air, label: 'Breathe', state: state),
              _NavItem(tab: AppTab.sounds, icon: Icons.equalizer_rounded, label: 'Sounds', state: state),
              _NavItem(tab: AppTab.sleep, icon: Icons.nightlight_round, label: 'Sleep', state: state),
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        state.setTab(tab);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? tealPrimary.withOpacity(0.25) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? tealPrimary : Colors.white.withOpacity(0.6),
                size: 20,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? tealPrimary : Colors.white.withOpacity(0.6),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
