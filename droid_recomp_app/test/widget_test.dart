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

    final dusklightJson = apps.firstWhere((a) => a['id'] == 'zelda-twilight-princess-ds-dusklight-ds');
    expect(dusklightJson['origin'], equals('nds'));
    expect(dusklightJson['status'], equals('Active Alpha'));
    final duskGame = RecompGame.fromJson(dusklightJson);
    expect(duskGame.origin, equals('nds'));
    expect(duskGame.isAlpha, isTrue);
    expect(duskGame.updatedAt.isNotEmpty, isTrue);

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
    expect(AppL10n.tr('Android Recomp Setup Guide'), equals('Android Recomp Setup Guide'));
    expect(AppL10n.tr('Download Native ARM64 APK'), equals('Download Native ARM64 APK'));
    expect(AppL10n.tr('Extract Your Original Game ROM'), equals('Extract Your Original Game ROM'));
    expect(AppL10n.tr('Scoped Storage & Asset Placement'), equals('Scoped Storage & Asset Placement'));

    appLanguageNotifier.value = 'ar';
    expect(AppL10n.tr('Discover'), equals('استكشاف'));
    expect(AppL10n.tr('▶ LAUNCH GAME'), equals('▶ تشغيل اللعبة'));
    expect(AppL10n.tr('Setup & ROM Guide'), equals('دليل التثبيت والملفات'));
    expect(AppL10n.tr('Android Recomp Setup Guide'), equals('دليل إعداد مشاريع إعادة البناء للأندرويد'));
    expect(AppL10n.tr('Download Native ARM64 APK'), equals('تحميل حزمة APK الأصلية لمعمارية ARM64'));
    expect(AppL10n.tr('Extract Your Original Game ROM'), equals('استخراج ملفات اللعبة الأصلية (ROM)'));
    expect(AppL10n.tr('Scoped Storage & Asset Placement'), equals('التخزين المعزول ونقل الملفات'));
    expect(AppL10n.tr('Obtainium Integration'), equals('مزامنة تطبيق Obtainium'));
    expect(AppL10n.tr('Get Obtainium App'), equals('الحصول على تطبيق Obtainium'));
    expect(AppL10n.tr('Touch Ready'), equals('جاهز للمس'));
    appLanguageNotifier.value = 'en';
  });
}
