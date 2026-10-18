import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feiniu_music/app/state/settings_tv_audio_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TvAudioSettings.resetForTest();
  });

  tearDown(TvAudioSettings.resetForTest);

  test('turning compensation off survives a restart', () async {
    await TvAudioSettings.ensureLoaded();
    await TvAudioSettings.setGainDb(0);
    TvAudioSettings.resetForTest();
    await TvAudioSettings.ensureLoaded();
    expect(TvAudioSettings.gainDb.value, 0);
  });

  test('gain never exceeds the supported range', () async {
    await TvAudioSettings.setGainDb(100);
    expect(TvAudioSettings.gainDb.value, 12);
    await TvAudioSettings.setGainDb(-20);
    expect(TvAudioSettings.gainDb.value, 0);
    await TvAudioSettings.setGainDb(double.nan);
    expect(TvAudioSettings.gainDb.value, 0);
  });

  test('volume preferences remain independent of compensation', () async {
    SharedPreferences.setMockInitialValues({'player_app_volume': 0.7});
    await TvAudioSettings.setGainDb(8);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('player_app_volume'), 0.7);
    expect(TvAudioSettings.gainDb.value, 8);
  });
}
