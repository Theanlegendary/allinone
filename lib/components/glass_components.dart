import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relax_mindfulness/providers/app_state.dart';
import 'package:relax_mindfulness/theme/app_theme.dart';

// ─── GlassCard ───────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final double cornerRadius;
  final Color? backgroundColor;
  final EdgeInsets padding;

  const GlassCard({
    super.key,
    required this.child,
    this.cornerRadius = 28,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isClay = state.themeMode.isLight;

    if (isClay) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? clayCardBg,
          borderRadius: BorderRadius.circular(cornerRadius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33B89679),
              offset: Offset(8, 8),
              blurRadius: 16,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(-6, -6),
              blurRadius: 12,
            ),
          ],
        ),
        child: child,
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF0C1924).withOpacity(0.92),
        borderRadius: BorderRadius.circular(cornerRadius),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            offset: const Offset(6, 6),
            blurRadius: 18,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.04),
            offset: const Offset(-4, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── GlassPillButton (Soft & Relaxing Cloud Pill) ───────────────────────────
class GlassPillButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final IconData? icon;
  final Color containerColor;
  final Color contentColor;
  final double? width;

  const GlassPillButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.containerColor = tealPrimary,
    this.contentColor = Colors.black,
    this.width,
  });

  @override
  State<GlassPillButton> createState() => _GlassPillButtonState();
}

class _GlassPillButtonState extends State<GlassPillButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    // Generate soft dual-tint gradient from containerColor
    final isTeal = widget.containerColor == tealPrimary;
    final gradientColors = isTeal
        ? [const Color(0xFF64DFDF), const Color(0xFF48CAE4)]
        : [widget.containerColor.withOpacity(0.9), widget.containerColor.withOpacity(0.7)];

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.width,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: widget.containerColor.withOpacity(0.35),
                blurRadius: 16,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: widget.contentColor, size: 17),
                const SizedBox(width: 7),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  color: widget.contentColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── GlassChip (Soft Relaxing Floating Chip) ─────────────────────────────────
class GlassChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;

  const GlassChip({
    super.key,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.selectedColor = tealPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isClay = state.themeMode.isLight;

    if (isClay) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? clayAccent : clayDarkCardBg,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isSelected
                ? const [
                    BoxShadow(color: Color(0x40D4A574), blurRadius: 10, offset: Offset(3, 3)),
                    BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-3, -3)),
                  ]
                : const [
                    BoxShadow(color: Color(0x20B89679), blurRadius: 6, offset: Offset(4, 4)),
                    BoxShadow(color: Colors.white, blurRadius: 6, offset: Offset(-3, -3)),
                  ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : clayText,
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: -0.2,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(26),
          border: isSelected ? Border.all(color: selectedColor.withOpacity(0.4), width: 1) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white.withOpacity(0.9),
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}

// ─── AnimatedSoundWave ────────────────────────────────────────────────────────
class AnimatedSoundWave extends StatefulWidget {
  final Color accentColor;
  // Optional 0..1 — bar amplitude scales with this (e.g. the master volume
  // or the dominant track's volume). Falls back to a constant envelope
  // when null.
  final double? amplitude;
  const AnimatedSoundWave({super.key, required this.accentColor, this.amplitude});

  @override
  State<AnimatedSoundWave> createState() => _AnimatedSoundWaveState();
}

class _AnimatedSoundWaveState extends State<AnimatedSoundWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final amp = (widget.amplitude ?? 0.7).clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value * 2 * pi;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [1.0, 1.8, 0.6].asMap().entries.map((e) {
            // Amplitude is now driven by the actual track volume, so a quiet
            // mix shows small bars and a loud mix shows tall ones.
            final h = 3 + 12 * amp * (0.5 + 0.5 * sin(t + e.key * 1.2)) * e.value;
            return Container(
              width: 3,
              height: h,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: widget.accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ─── StreakBadge ──────────────────────────────────────────────────────────────
class StreakBadge extends StatelessWidget {
  final int streakCount;
  const StreakBadge({super.key, required this.streakCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFF6B35), Color(0xFFFFB74D)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text('$streakCount day${streakCount == 1 ? '' : 's'}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── MoodCheckInDialog ────────────────────────────────────────────────────────
class MoodCheckInDialog extends StatefulWidget {
  final void Function(int) onMoodSelected;
  final VoidCallback onSkip;

  const MoodCheckInDialog({
    super.key,
    required this.onMoodSelected,
    required this.onSkip,
  });

  @override
  State<MoodCheckInDialog> createState() => _MoodCheckInDialogState();
}

class _MoodCheckInDialogState extends State<MoodCheckInDialog>
    with SingleTickerProviderStateMixin {
  int? _selected;
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  static const _emojis = ['😔', '😕', '😐', '🙂', '😊'];
  static const _labels = ['Rough', 'Okay', 'Neutral', 'Good', 'Great'];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: Colors.black.withOpacity(0.65),
          child: SlideTransition(
            position: _slide,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GlassCard(
                    cornerRadius: 28,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'How Do You Feel?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rate your session experience',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (i) {
                            final rating = i + 1;
                            final isSelected = _selected == rating;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selected = rating),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? tealPrimary.withOpacity(0.25)
                                        : Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? tealPrimary : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _emojis[i],
                                        style: TextStyle(fontSize: isSelected ? 24 : 20),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _labels[i],
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? tealPrimary : Colors.white.withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: widget.onSkip,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Skip',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: _selected != null ? () => widget.onMoodSelected(_selected!) : null,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _selected != null ? tealPrimary : tealPrimary.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _selected != null ? 'Save Rating ✓' : 'Select Mood',
                                      style: TextStyle(
                                        color: _selected != null ? Colors.black : Colors.white38,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── GuidedPlayerOverlay (Soft 432Hz Healing Audio Player) ────────────────────
class GuidedPlayerOverlay extends StatefulWidget {
  const GuidedPlayerOverlay({super.key});

  @override
  State<GuidedPlayerOverlay> createState() => _GuidedPlayerOverlayState();
}

class _GuidedPlayerOverlayState extends State<GuidedPlayerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (!state.isGuidedPlaying) return const SizedBox();

        final mins = state.guidedRemainingSec ~/ 60;
        final secs = state.guidedRemainingSec % 60;

        return Material(
          color: Colors.transparent,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF071118), Color(0xFF0E2230), Color(0xFF060E15)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: tealPrimary.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: tealPrimary.withOpacity(0.4)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.graphic_eq_rounded, color: tealPrimary, size: 16),
                              SizedBox(width: 6),
                              Text(
                                '432Hz Healing Tone Active',
                                style: TextStyle(
                                  color: tealPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 28),
                          onPressed: () => state.stopGuidedSession(completed: false),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Animated Glowing Lotus Pulse Circle
                    AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, __) {
                        final size = 180 + (30 * _pulseCtrl.value);
                        return Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                tealPrimary.withOpacity(0.5),
                                mintAccent.withOpacity(0.2),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: tealPrimary.withOpacity(0.3 * _pulseCtrl.value),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.spa_rounded,
                              color: Colors.white,
                              size: 64,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 36),

                    Text(
                      state.currentGuidedTitle ?? 'Guided Healing Practice',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Soft continuous Solfeggio soundscape • Deep stress relief',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Interactive Live Playback Controls (+10m, Loop ♾️, Restart 🔄)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GlassChip(
                          label: '+10 Min',
                          isSelected: false,
                          onTap: () => state.extendGuidedSession(10),
                        ),
                        const SizedBox(width: 10),
                        GlassChip(
                          label: state.isGuidedLooping ? 'Loop ♾️ On' : 'Loop Off',
                          isSelected: state.isGuidedLooping,
                          selectedColor: tealPrimary,
                          onTap: () => state.toggleGuidedLoop(),
                        ),
                        const SizedBox(width: 10),
                        GlassChip(
                          label: 'Restart 🔄',
                          isSelected: false,
                          onTap: () => state.restartGuidedSession(10),
                        ),
                      ],
                    ),

                    const Spacer(),

                    GlassPillButton(
                      text: 'Complete & End Session',
                      icon: Icons.check_circle_outline_rounded,
                      containerColor: tealPrimary,
                      contentColor: Colors.black,
                      onTap: () => state.stopGuidedSession(completed: true),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── SanctuaryMiniPlayer (Floating Bottom Mini-Player with Equalizer Waveform) ──
class SanctuaryMiniPlayer extends StatelessWidget {
  const SanctuaryMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (!state.isAnyAudioPlaying) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: GestureDetector(
            onTap: () => state.setTab(AppTab.sounds),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF0C1924).withOpacity(0.96),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: tealPrimary.withOpacity(0.6), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: tealPrimary.withOpacity(0.32),
                    blurRadius: 22,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: tealPrimary.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: tealPrimary.withOpacity(0.4)),
                    ),
                    child: AnimatedSoundWave(
                      accentColor: tealPrimary,
                      amplitude: state.guidanceGuidedAmplitude > 0
                          ? state.guidanceGuidedAmplitude
                          : state.activeMixAmplitude,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NOW PLAYING SANCTUARY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: tealPrimary,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          state.activePlayingLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => state.stopAllAudio(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: tealPrimary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: tealPrimary.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.pause_rounded, color: Colors.black, size: 18),
                          SizedBox(width: 4),
                          Text(
                            'Pause',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
        );
      },
    );
  }
}
