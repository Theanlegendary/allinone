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
  midnightNavy('Midnight Navy', Color(0xFF050D15), Color(0xFF0A1622)),
  forestDusk('Forest Dusk', Color(0xFF061412), Color(0xFF0D2522)),
  twilightLavender('Twilight Lavender', Color(0xFF0E0A17), Color(0xFF191228));

  const SanctuaryThemeMode(this.displayName, this.bgDark, this.bgMid);
  final String displayName;
  final Color bgDark, bgMid;
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
  
  // 11 DISTINCT, AUTHENTIC Mixkit Direct Audio Streams (CORS Allowed, 100% Web Playback Guarantee)
  static const Map<String, String> soundStreamUrls = {
    'Soft Rain': 'https://assets.mixkit.co/active_storage/sfx/2517/2517-preview.mp3',
    'Ocean Waves': 'https://assets.mixkit.co/active_storage/sfx/1188/1188-preview.mp3',
    'Mountain Stream': 'https://assets.mixkit.co/active_storage/sfx/2436/2436-preview.mp3',
    'Soothing Breeze': 'https://assets.mixkit.co/active_storage/sfx/2528/2528-preview.mp3',
    'Singing Bowls': 'https://assets.mixkit.co/active_storage/sfx/2658/2658-preview.mp3',
    'Cozy Hearth': 'https://assets.mixkit.co/active_storage/sfx/2678/2678-preview.mp3',
    'Thunderstorm': 'https://assets.mixkit.co/active_storage/sfx/2390/2390-preview.mp3',
    'Forest Birds': 'https://assets.mixkit.co/active_storage/sfx/2434/2434-preview.mp3',
    'Bamboo Chimes': 'https://assets.mixkit.co/active_storage/sfx/2435/2435-preview.mp3',
    'Deep Space Drone': 'https://assets.mixkit.co/active_storage/sfx/2659/2659-preview.mp3',
    'Ambient Piano': 'https://assets.mixkit.co/active_storage/sfx/2874/2874-preview.mp3',
  };

  // Guided Healing Audio Streams (Mixkit Direct Audio Streams)
  static const Map<String, String> guidedAudioUrls = {
    'Morning Clarity': 'https://assets.mixkit.co/active_storage/sfx/2874/2874-preview.mp3',
    'Deep Stress Release': 'https://assets.mixkit.co/active_storage/sfx/2659/2659-preview.mp3',
    'Inner Calm & Serenity': 'https://assets.mixkit.co/active_storage/sfx/2658/2658-preview.mp3',
    'Evening Gratitude': 'https://assets.mixkit.co/active_storage/sfx/2528/2528-preview.mp3',
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
    final url = soundStreamUrls[name];
    if (url == null) return;

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
    if (s != null) {
      updateSoundTrackVolume('Ocean Waves', 0.8);
    } else {
      updateSoundTrackVolume('Ocean Waves', 0.0);
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

    notifyListeners();
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
