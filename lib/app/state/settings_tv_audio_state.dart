import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Playback gain is separate from both the application and TV master volume.
class TvAudioSettings {
  static const _gainKey = 'player_tv_loudness_gain_db';
  static final gainDb = ValueNotifier<double>(6);
  static Future<void>? _loading;

  static double normalizeGain(double value) =>
      value.isFinite ? value.clamp(0.0, 12.0).toDouble() : 0;

  static Future<void> ensureLoaded() => _loading ??= _load();

  static Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    gainDb.value = normalizeGain(prefs.getDouble(_gainKey) ?? 6);
  }

  static Future<void> setGainDb(double value) async {
    final normalized = normalizeGain(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_gainKey, normalized);
    gainDb.value = normalized;
  }

  @visibleForTesting
  static void resetForTest() {
    _loading = null;
    gainDb.value = 6;
  }
}
