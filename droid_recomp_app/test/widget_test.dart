import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:droid_recomp_app/main.dart';

void main() {
  test('Check if catalog.json loads and parses', () {
    final file = File('assets/catalog.json');
    expect(file.existsSync(), isTrue);
    final jsonStr = file.readAsStringSync();
    final data = json.decode(jsonStr);
    final apps = data['apps'] as List<dynamic>;
    
    int success = 0;
    for (int i = 0; i < apps.length; i++) {
      try {
        final g = RecompGame.fromJson(apps[i]);
        expect(g.name.isNotEmpty, isTrue);
        success++;
      } catch (e, stack) {
        fail('Crash on app $i: ${apps[i]['name']} - $e\n$stack');
      }
    }
    expect(success, equals(apps.length));

    final emuFile = File('assets/emulators.json');
    expect(emuFile.existsSync(), isTrue);
    final emuData = json.decode(emuFile.readAsStringSync());
    final emus = emuData['emulators'] as List<dynamic>;
    for (int i = 0; i < emus.length; i++) {
      try {
        final e = EmulatorApp.fromJson(emus[i]);
        expect(e.name.isNotEmpty, isTrue);
      } catch (e, stack) {
        fail('Crash on emu $i: ${emus[i]['name']} - $e\n$stack');
      }
    }
  });

  test('Check AppL10n translations', () {
    expect(AppL10n.tr('Discover'), equals('Discover'));
    expect(AppL10n.tr('▶ LAUNCH GAME'), equals('▶ LAUNCH GAME'));
    appLanguageNotifier.value = 'ar';
    expect(AppL10n.tr('Discover'), equals('استكشاف'));
    expect(AppL10n.tr('▶ LAUNCH GAME'), equals('▶ تشغيل اللعبة'));
    appLanguageNotifier.value = 'en';
  });
}
