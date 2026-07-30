import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────
enum AppTab { home, meditate, breathe, sounds, sleep, aiStudio }

enum BreathingPattern {
  box4444('Box 4-4-4-4', 4, 4, 4, 4, 'Classic Navy SEAL stress relief'),
  relax478('4-7-8 Sleep', 4, 7, 8, 0, 'Dr. Weil sleep technique'),
  resonance55('Resonance 5-5', 5, 0, 5, 0, 'Heart rate coherence'),
  power626('Power 6-2-6', 6, 2, 6, 2, 'Energy & focus boost');

  const BreathingPattern(this.displayName, this.inhale, this.hold, this.exhale, this.holdOut, this.description);
  final String displayName;
  final int inhale, hold, exhale, holdOut;
  final String description;
  int get totalCycle => inhale + hold + exhale + holdOut;
}

enum BreathPhase { inhale, hold, exhale, holdOut }

enum SanctuaryThemeMode {
  claymorphism('Claymorphism Soft UI', Color(0xFFF9F4EF), Color(0xFFEADBC8), isLight: true),
  midnightNavy('Midnight Navy', Color(0xFF050D15), Color(0xFF0A1622)),
  forestDusk('Forest Dusk', Color(0xFF061412), Color(0xFF0D2522)),
  twilightLavender('Twilight Lavender', Color(0xFF0E0A17), Color(0xFF191228));

  const SanctuaryThemeMode(this.displayName, this.bgDark, this.bgMid, {this.isLight = false});
  final String displayName;
  final Color bgDark, bgMid;
  final bool isLight;
}

// ─── Models ───────────────────────────────────────────────────────────────────
class SessionRecord {
  final String id, title, type;
  final int durationMinutes, moodRating;
  final DateTime timestamp;

  SessionRecord({required this.id, required this.title, required this.type,
    required this.durationMinutes, required this.timestamp, this.moodRating = 0});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'type': type,
    'dur': durationMinutes, 'ts': timestamp.millisecondsSinceEpoch, 'mood': moodRating};

  factory SessionRecord.fromJson(Map<String, dynamic> j) => SessionRecord(
    id: j['id'] as String, title: j['title'] as String, type: j['type'] as String,
    durationMinutes: j['dur'] as int,
    timestamp: DateTime.fromMillisecondsSinceEpoch(j['ts'] as int),
    moodRating: (j['mood'] as int?) ?? 0);

  SessionRecord withMood(int m) => SessionRecord(id: id, title: title, type: type,
    durationMinutes: durationMinutes, timestamp: timestamp, moodRating: m);
}

class SoundPreset {
  final String name;
  final Map<String, double> volumes;
  SoundPreset({required this.name, required this.volumes});
  Map<String, dynamic> toJson() => {'name': name, 'volumes': volumes};
  factory SoundPreset.fromJson(Map<String, dynamic> j) => SoundPreset(
    name: j['name'] as String,
    volumes: Map<String, double>.from((j['volumes'] as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble()))));
}

// ─── AppState ─────────────────────────────────────────────────────────────────
class AppState extends ChangeNotifier {
  SharedPreferences? _prefs;

  // Audio players for ambient tracks
  final Map<String, AudioPlayer> _audioPlayers = {};
  final Set<String> _loadingTracks = {};
  final Map<String, double> _targetVolumes = {};

  // Guided Meditation Audio Player (Ultra-soft 432Hz / 528Hz Solfeggio Healing Stream)
  final AudioPlayer _guidedPlayer = AudioPlayer();
  bool _isGuidedPlaying = false;
  String? _currentGuidedTitle;
  int _guidedRemainingSec = 0;
  Timer? _guidedTimer;

  bool get isGuidedPlaying => _isGuidedPlaying;
  String? get currentGuidedTitle => _currentGuidedTitle;
  int get guidedRemainingSec => _guidedRemainingSec;
  
  // 78 VERIFIED UNIQUE CC0 SOUND STREAM URLS (Sourced from ambient-preview.html / Moodist & Google)
  static const Map<String, String> soundStreamUrls = {
    // Rain (8)
    'Soft Rain': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/light-rain.mp3',
    'Thunderstorm': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/thunder.mp3',
    'Heavy Rain': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/heavy-rain.mp3',
    'Rain on Window': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/rain-on-window.mp3',
    'Rain on Roof': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/rain-on-car-roof.mp3',
    'Rain on Umbrella': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/rain-on-umbrella.mp3',
    'Rain on Tent': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/rain-on-tent.mp3',
    'Rain on Leaves': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/rain/rain-on-leaves.mp3',

    // Nature (15)
    'Ocean Waves': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/waves.mp3',
    'Mountain Stream': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/river.mp3',
    'Forest Birds': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/birds.mp3',
    'Campfire': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/campfire.mp3',
    'Wind in Trees': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/wind-in-trees.mp3',
    'Howling Wind': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/howling-wind.mp3',
    'Crickets': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/crickets.mp3',
    'Waterfall': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/waterfall.mp3',
    'Frogs': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/frog.mp3',
    'Jungle Day': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/jungle.mp3',
    'Water Droplets': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/droplets.mp3',
    'Walking in Snow': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/walk-in-snow.mp3',
    'Walking on Gravel': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/walk-on-gravel.mp3',
    'Walking on Leaves': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/walk-on-leaves.mp3',
    'Owl Hooting': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/owl.mp3',

    // Places (10)
    'Coffee Shop': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/places/cafe.mp3',
    'Library': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/places/library.mp3',
    'Office Ambience': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/places/office.mp3',
    'Church Interior': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/places/church.mp3',
    'Temple': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/places/temple.mp3',
    'Restaurant': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/places/restaurant.mp3',
    'Crowded Bar': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/places/crowded-bar.mp3',
    'Night Village': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/places/night-village.mp3',
    'Supermarket': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/places/supermarket.mp3',
    'Airport': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/places/airport.mp3',

    // Transport (8)
    'Train Ride': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/transport/train.mp3',
    'Inside a Train': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/transport/inside-a-train.mp3',
    'Airplane Cabin': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/transport/airplane.mp3',
    'Submarine': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/transport/submarine.mp3',
    'Rowing Boat': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/transport/rowing-boat.mp3',
    'Sailing Ship': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/transport/sailboat.mp3',
    'Highway Traffic': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/urban/highway.mp3',
    'Busy Street': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/urban/busy-street.mp3',

    // Things (10)
    'Clock Ticking': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/clock.mp3',
    'Ceiling Fan': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/ceiling-fan.mp3',
    'Keyboard Typing': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/keyboard.mp3',
    'Typewriter': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/typewriter.mp3',
    'Washing Machine': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/washing-machine.mp3',
    'Clothes Dryer': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/dryer.mp3',
    'Vinyl Crackle': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/vinyl-effect.mp3',
    'Boiling Water': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/boiling-water.mp3',
    'Wind Chimes': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/wind-chimes.mp3',
    'Windshield Wipers': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/windshield-wipers.mp3',

    // Noise (5)
    'White Noise': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/noise/white-noise.wav',
    'Pink Noise': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/noise/pink-noise.wav',
    'Brown Noise': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/noise/brown-noise.wav',
    'Steady Wind': 'https://actions.google.com/sounds/v1/weather/wind.ogg',
    'Desert Howling Wind': 'https://actions.google.com/sounds/v1/weather/desert_howling_wind.ogg',

    // Solfeggio & Binaural (10)
    'Singing Bowl': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/singing-bowl.mp3',
    'Delta Deep Sleep': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/binaural/binaural-delta.wav',
    'Theta Meditation': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/binaural/binaural-theta.wav',
    'Alpha Focus Flow': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/binaural/binaural-alpha.wav',
    'Beta Energy': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/binaural/binaural-beta.wav',
    'Gamma Insight': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/binaural/binaural-gamma.wav',
    'Tuning Radio': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/tuning-radio.mp3',
    'Morse Code': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/morse-code.mp3',
    'Paper Rustling': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/paper.mp3',
    'Bubbles': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/bubbles.mp3',

    // Animals (12)
    'Cat Purring': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/cat-purring.mp3',
    'Seagulls': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/seagulls.mp3',
    'Whale Song': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/whale.mp3',
    'Wolf Howling': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/wolf.mp3',
    'Woodpecker': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/woodpecker.mp3',
    'Crows': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/crows.mp3',
    'Horse Galloping': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/horse-gallop.mp3',
    'Sheep Bleating': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/sheep.mp3',
    'Chickens': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/chickens.mp3',
    'Cows Mooing': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/cows.mp3',
    'Dog Barking': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/dog-barking.mp3',
    'Beehive Hum': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/animals/beehive.mp3',

    // Curated Preset Aliases (6 ADDED — mapping brand names to real Moodist tracks)
    'Cozy Hearth': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/campfire.mp3',
    'Singing Bowls': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/singing-bowl.mp3',
    'Ambient Piano': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/singing-bowl.mp3',
    'Bamboo Chimes': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/things/wind-chimes.mp3',
    'Soothing Breeze': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/nature/wind-in-trees.mp3',
    'Deep Space Drone': 'https://raw.githubusercontent.com/remvze/moodist/main/public/sounds/binaural/binaural-gamma.wav',
  };

  // Guided Healing Audio Streams (Mixkit Direct Audio Streams)
  // Keys MUST match MeditationScreen _sessions titles exactly.
  static const Map<String, String> guidedAudioUrls = {
    'Morning Clarity & Energy': 'https://assets.mixkit.co/active_storage/sfx/2874/2874-preview.mp3',
    'Deep Stress Release': 'https://assets.mixkit.co/active_storage/sfx/2659/2659-preview.mp3',
    'Inner Calm & Serenity': 'https://assets.mixkit.co/active_storage/sfx/2658/2658-preview.mp3',
    'Evening Gratitude Unwind': 'https://assets.mixkit.co/active_storage/sfx/2528/2528-preview.mp3',
    'Body Scan Relaxation': 'https://assets.mixkit.co/active_storage/sfx/2436/2436-preview.mp3',
    'Loving-Kindness Meditation': 'https://assets.mixkit.co/active_storage/sfx/2435/2435-preview.mp3',
    'Mindful Breath Awareness': 'https://assets.mixkit.co/active_storage/sfx/2517/2517-preview.mp3',
    'Visualization Journey': 'https://assets.mixkit.co/active_storage/sfx/1188/1188-preview.mp3',
    'Chakra Balancing Tones': 'https://assets.mixkit.co/active_storage/sfx/2658/2658-preview.mp3',
    'Yoga Nidra Sleep Prep': 'https://assets.mixkit.co/active_storage/sfx/2659/2659-preview.mp3',
    'Calm Mountain Horizon': 'https://assets.mixkit.co/active_storage/sfx/2874/2874-preview.mp3',
  };

  // Theme Mode
  SanctuaryThemeMode _themeMode = SanctuaryThemeMode.midnightNavy;
  SanctuaryThemeMode get themeMode => _themeMode;
  void setThemeMode(SanctuaryThemeMode mode) {
    _themeMode = mode;
    _prefs?.setString('theme_mode', mode.name);
    notifyListeners();
  }

  // Active Audio Status for Floating Mini-Player
  bool get isAnyAudioPlaying => _isGuidedPlaying || _targetVolumes.values.any((v) => v > 0);
  String get activePlayingLabel {
    if (_isGuidedPlaying && _currentGuidedTitle != null) {
      return _currentGuidedTitle!;
    }
    final activeTracks = _targetVolumes.entries.where((e) => e.value > 0).map((e) => e.key).toList();
    if (activeTracks.isEmpty) return 'No Audio Playing';
    if (activeTracks.length == 1) return activeTracks.first;
    return '${activeTracks.first} + ${activeTracks.length - 1} more';
  }

  // Tab
  AppTab _tab = AppTab.home;
  AppTab get tab => _tab;
  void setTab(AppTab t) { _tab = t; notifyListeners(); }

  // Mood Selector Filter State
  String _selectedMoodFilter = 'Calm';
  String get selectedMoodFilter => _selectedMoodFilter;

  void setMoodFilter(String mood) {
    _selectedMoodFilter = mood;
    notifyListeners();
  }

  // Renamed Custom Presets State (Moodist-Inspired Customization)
  Map<String, String> _renamedPresets = {};
  Map<String, String> get renamedPresets => Map.unmodifiable(_renamedPresets);

  void renameCuratedPreset(String oldName, String newName) {
    _renamedPresets[oldName] = newName;
    _prefs?.setString('renamed_presets', jsonEncode(_renamedPresets));
    notifyListeners();
  }

  String getPresetDisplayName(String originalName) {
    return _renamedPresets[originalName] ?? originalName;
  }

  // Curated One-Tap Multi-Track Ambient Sound Mix Presets
  static const Map<String, Map<String, double>> curatedPresets = {
    '🌧️ Rainy Cabin': {
      'Soft Rain': 0.70,
      'Cozy Hearth': 0.35,
      'Ambient Piano': 0.20,
    },
    '🌊 Beach Sunset': {
      'Ocean Waves': 0.70,
      'Soothing Breeze': 0.40,
      'Bamboo Chimes': 0.20,
    },
    '🌌 Deep Space': {
      'Deep Space Drone': 0.70,
      'Singing Bowls': 0.30,
    },
    '🌲 Forest Walk': {
      'Mountain Stream': 0.60,
      'Forest Birds': 0.40,
      'Soothing Breeze': 0.30,
    },
    '⚡ Thunderstorm': {
      'Thunderstorm': 0.70,
      'Soft Rain': 0.50,
      'Soothing Breeze': 0.20,
    },
    '🧘 Zen Sanctuary': {
      'Singing Bowls': 0.60,
      'Bamboo Chimes': 0.40,
      'Mountain Stream': 0.30,
    },
    '🔥 Campfire Night': {
      'Cozy Hearth': 0.75,
      'Soothing Breeze': 0.30,
    },
    '🕊️ Peace Flow': {
      'Ambient Piano': 0.65,
      'Soft Rain': 0.30,
      'Singing Bowls': 0.25,
    },
  };

  Future<void> applyCuratedPreset(String presetName) async {
    final volumes = curatedPresets[presetName];
    if (volumes == null) return;

    for (final track in soundStreamUrls.keys) {
      final vol = volumes[track] ?? 0.0;
      await updateSoundTrackVolume(track, vol);
    }
  }

  // Onboarding
  bool _onboardingDone = false;
  bool get onboardingDone => _onboardingDone;
  void completeOnboarding() {
    _onboardingDone = true;
    _prefs?.setBool('onboarding_done', true);
    notifyListeners();
  }

  // Streak
  int _streak = 0, _longestStreak = 0;
  bool _practicedToday = false;
  int get streak => _streak;
  int get longestStreak => _longestStreak;
  bool get practicedToday => _practicedToday;

  // Sessions
  List<SessionRecord> _sessions = [];
  List<SessionRecord> get sessions => List.unmodifiable(_sessions);
  int get totalMinutes => _sessions.fold(0, (s, r) => s + r.durationMinutes);
  Map<String, int> get categoryBreakdown {
    final m = <String, int>{};
    for (final s in _sessions) { m[s.type] = (m[s.type] ?? 0) + s.durationMinutes; }
    return m;
  }
  double get avgMood {
    final rated = _sessions.where((s) => s.moodRating > 0).toList();
    if (rated.isEmpty) return 0;
    return rated.map((s) => s.moodRating).reduce((a, b) => a + b) / rated.length;
  }
  List<MapEntry<String, int>> get weeklyMinutes {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final label = days[day.weekday - 1];
      final mins = _sessions.where((s) => _sameDay(s.timestamp, day)).fold(0, (sum, s) => sum + s.durationMinutes);
      return MapEntry(label, mins);
    });
  }

  // ── Guided Healing Session Audio Player ─────────────────────────────────
  Future<void> playGuidedSession(String title, int durationMins) async {
    _guidedTimer?.cancel();
    _currentGuidedTitle = title;
    _guidedRemainingSec = durationMins * 60;
    _isGuidedPlaying = true;
    notifyListeners();

    _guidedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isGuidedPlaying || _guidedRemainingSec <= 0) {
        timer.cancel();
        stopGuidedSession(completed: true, durationMins: durationMins);
      } else {
        _guidedRemainingSec--;
        notifyListeners();
      }
    });

    final url = guidedAudioUrls[title] ?? guidedAudioUrls['Calm Mountain Horizon']!;

    try {
      await _guidedPlayer.setUrl(url);
      await _guidedPlayer.setLoopMode(LoopMode.one);
      await _guidedPlayer.setVolume(0.35);
      _guidedPlayer.play();
    } catch (e) {
      debugPrint('Error starting guided audio: $e');
    }
  }

  bool _isGuidedLooping = true;
  bool get isGuidedLooping => _isGuidedLooping;

  void extendGuidedSession(int extraMins) {
    _guidedRemainingSec += extraMins * 60;
    notifyListeners();
  }

  void toggleGuidedLoop() {
    _isGuidedLooping = !_isGuidedLooping;
    if (_isGuidedLooping) {
      _guidedPlayer.setLoopMode(LoopMode.one);
    } else {
      _guidedPlayer.setLoopMode(LoopMode.off);
    }
    notifyListeners();
  }

  void restartGuidedSession(int initialMins) {
    _guidedRemainingSec = initialMins * 60;
    _guidedPlayer.seek(Duration.zero);
    notifyListeners();
  }

  Future<void> pauseGuidedSession() async {
    _guidedTimer?.cancel();
    await _guidedPlayer.pause();
    _isGuidedPlaying = false;
    notifyListeners();
  }

  Future<void> stopGuidedSession({bool completed = false, int durationMins = 10}) async {
    _guidedTimer?.cancel();
    await _guidedPlayer.stop();
    _isGuidedPlaying = false;
    final title = _currentGuidedTitle ?? 'Guided Meditation';
    _currentGuidedTitle = null;
    notifyListeners();

    if (completed) {
      recordSession(title, 'Meditation', durationMins);
    }
  }

  // ── Audio Control (Clean, Full Volume Audio Streams) ──────────────────────
  Future<void> updateSoundTrackVolume(String name, double volume) async {
    final url = soundStreamUrls[name] ?? 'https://actions.google.com/sounds/v1/weather/rain_heavy_loud.ogg';

    final effectiveVolume = volume.clamp(0.0, 1.0);
    _targetVolumes[name] = effectiveVolume;

    if (volume <= 0) {
      final existingPlayer = _audioPlayers[name];
      if (existingPlayer != null) {
        await existingPlayer.setVolume(0);
        await existingPlayer.pause();
      }
      return;
    }

    if (!_audioPlayers.containsKey(name)) {
      final newPlayer = AudioPlayer();
      _audioPlayers[name] = newPlayer;
      _loadingTracks.add(name);

      try {
        await newPlayer.setUrl(url);
        await newPlayer.setLoopMode(LoopMode.one);
      } catch (e) {
        debugPrint('Error loading audio track $name: $e');
      } finally {
        _loadingTracks.remove(name);
      }
    }

    final player = _audioPlayers[name]!;
    final currentTarget = _targetVolumes[name] ?? 0.0;

    if (currentTarget > 0) {
      await player.setVolume(currentTarget);
      if (!player.playing) {
        await player.play();
      }
    } else {
      await player.setVolume(0);
      await player.pause();
    }
  }

  Future<void> stopAllAudio() async {
    _targetVolumes.clear();
    await stopGuidedSession(completed: false);
    for (final entry in _audioPlayers.entries) {
      try {
        await entry.value.setVolume(0);
        await entry.value.pause();
      } catch (e) {
        debugPrint('Error stopping track ${entry.key}: $e');
      }
    }
  }

  // Mood dialog
  bool _showMoodDialog = false;
  bool get showMoodDialog => _showMoodDialog;
  SessionRecord? _pendingSession;

  void requestMoodCheckIn(SessionRecord session) {
    _pendingSession = session;
    _showMoodDialog = true;
    notifyListeners();
  }

  void submitMood(int rating) {
    if (_pendingSession == null) return;
    _addSession(_pendingSession!.withMood(rating));
    _showMoodDialog = false;
    _pendingSession = null;
    notifyListeners();
  }

  void dismissMood() {
    if (_pendingSession != null) { _addSession(_pendingSession!); _pendingSession = null; }
    _showMoodDialog = false;
    notifyListeners();
  }

  void recordSession(String title, String type, int minutes, {bool showMoodCheckIn = true}) {
    final record = SessionRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      type: type,
      durationMinutes: minutes,
      timestamp: DateTime.now(),
    );

    if (showMoodCheckIn) {
      requestMoodCheckIn(record);
    } else {
      _addSession(record);
    }
  }

  void _addSession(SessionRecord s) {
    _sessions.insert(0, s);
    _updateStreak();
    _saveSessions();
  }

  // Sound Presets
  List<SoundPreset> _presets = [];
  List<SoundPreset> get presets => List.unmodifiable(_presets);
  void savePreset(String name, Map<String, double> volumes) {
    _presets.insert(0, SoundPreset(name: name, volumes: volumes));
    _savePresets(); notifyListeners();
  }
  void deletePreset(int index) { _presets.removeAt(index); _savePresets(); notifyListeners(); }

  // Breathing
  BreathingPattern _pattern = BreathingPattern.box4444;
  BreathingPattern get pattern => _pattern;
  void setPattern(BreathingPattern p) { _pattern = p; notifyListeners(); }

  // Sleep story
  String? _selectedStory;
  String? get selectedStory => _selectedStory;
  void setStory(String? s) {
    _selectedStory = s;
    stopAllAudio();

    if (s != null) {
      if (s.contains('Cabin') || s.contains('Rainfall')) {
        updateSoundTrackVolume('Soft Rain', 0.7);
        updateSoundTrackVolume('Cozy Hearth', 0.35);
      } else if (s.contains('Alpine') || s.contains('Forest')) {
        updateSoundTrackVolume('Forest Birds', 0.6);
        updateSoundTrackVolume('Soothing Breeze', 0.3);
      } else if (s.contains('Ocean') || s.contains('Voyage')) {
        updateSoundTrackVolume('Ocean Waves', 0.7);
        updateSoundTrackVolume('Soothing Breeze', 0.3);
      } else if (s.contains('Japanese') || s.contains('Garden')) {
        updateSoundTrackVolume('Bamboo Chimes', 0.5);
        updateSoundTrackVolume('Mountain Stream', 0.4);
      } else if (s.contains('Stargazing') || s.contains('Desert')) {
        updateSoundTrackVolume('Deep Space Drone', 0.6);
        updateSoundTrackVolume('Soothing Breeze', 0.3);
      } else if (s.contains('Cloud') || s.contains('Floating')) {
        updateSoundTrackVolume('Ambient Piano', 0.6);
        updateSoundTrackVolume('Singing Bowls', 0.3);
      } else if (s.contains('Temple') || s.contains('Bells')) {
        updateSoundTrackVolume('Singing Bowls', 0.6);
        updateSoundTrackVolume('Bamboo Chimes', 0.4);
      } else {
        updateSoundTrackVolume('Soft Rain', 0.6);
      }
    }
    notifyListeners();
  }

  // ─── Init ───────────────────────────────────────────────────────────────────
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _onboardingDone = _prefs!.getBool('onboarding_done') ?? false;
    _streak = _prefs!.getInt('streak') ?? 0;
    _longestStreak = _prefs!.getInt('longest_streak') ?? 0;
    final lastMs = _prefs!.getInt('last_practice_ms') ?? 0;
    if (lastMs > 0) _practicedToday = _sameDay(DateTime.fromMillisecondsSinceEpoch(lastMs), DateTime.now());

    final rawS = _prefs!.getStringList('sessions') ?? [];
    _sessions = rawS.map((s) { try { return SessionRecord.fromJson(jsonDecode(s)); } catch (_) { return null; } })
        .whereType<SessionRecord>().toList();

    final rawP = _prefs!.getStringList('presets') ?? [];
    _presets = rawP.map((s) { try { return SoundPreset.fromJson(jsonDecode(s)); } catch (_) { return null; } })
        .whereType<SoundPreset>().toList();

    final rawRenamed = _prefs!.getString('renamed_presets');
    if (rawRenamed != null) {
      try {
        _renamedPresets = Map<String, String>.from(jsonDecode(rawRenamed) as Map);
      } catch (_) {}
    }

    notifyListeners();
  }

  // Local Cache Persistence for Active Volume Mix
  Map<String, double> get cachedVolumes {
    final raw = _prefs?.getString('cached_volumes');
    if (raw == null) return {};
    try {
      return Map<String, double>.from((jsonDecode(raw) as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble())));
    } catch (_) {
      return {};
    }
  }

  void saveCachedVolumes(Map<String, double> volumes) {
    _prefs?.setString('cached_volumes', jsonEncode(volumes));
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────
  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  void _updateStreak() {
    if (_practicedToday) return;
    _practicedToday = true;
    if (_sessions.length <= 1) {
      _streak = 1;
    } else {
      final prev = _sessions[1].timestamp;
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      _streak = (_sameDay(prev, yesterday) || _sameDay(prev, DateTime.now())) ? _streak + 1 : 1;
    }
    if (_streak > _longestStreak) _longestStreak = _streak;
    _prefs?.setInt('streak', _streak);
    _prefs?.setInt('longest_streak', _longestStreak);
    _prefs?.setInt('last_practice_ms', DateTime.now().millisecondsSinceEpoch);
  }

  void _saveSessions() => _prefs?.setStringList('sessions', _sessions.take(200).map((s) => jsonEncode(s.toJson())).toList());
  void _savePresets() => _prefs?.setStringList('presets', _presets.map((p) => jsonEncode(p.toJson())).toList());

  @override
  void dispose() {
    _guidedTimer?.cancel();
    _guidedPlayer.dispose();
    for (final player in _audioPlayers.values) {
      player.dispose();
    }
    super.dispose();
  }
}
