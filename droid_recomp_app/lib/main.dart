import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B1220),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const DroidRecompApp());
}

// ============================================================================
// THEME & COLOR TOKENS (RecompLauncher Design System)
// ============================================================================
class RecompTheme {
  static const Color midnight = Color(0xFF0B1220);
  static const Color midnightAlt = Color(0xFF0E172A);
  static const Color cyan = Color(0xFF34F2E8);
  static const Color steelBlue = Color(0xFF377BB6);
  static const Color frost = Color(0xFFF4F8FC);
  static const Color muted = Color(0xFFA7B3C4);
  static const Color line = Color(0x24F4F8FC);
  static const Color glass = Color(0x14F4F8FC);
  static const Color turnipGold = Color(0xFFFBBF24);
  static const Color successGreen = Color(0xFF34D399);

  // Theme-aware dynamic helpers
  static bool isLight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light;

  static Color text(BuildContext context) =>
      isLight(context) ? const Color(0xFF0F172A) : frost;

  static Color textMuted(BuildContext context) =>
      isLight(context) ? const Color(0xFF475569) : muted;

  static Color cardBg(BuildContext context) =>
      isLight(context) ? Colors.white : glass;

  static Color cardFootBg(BuildContext context) =>
      isLight(context) ? const Color(0xFFF8FAFC) : midnightAlt;

  static Color border(BuildContext context) =>
      isLight(context) ? const Color(0x220F172A) : line;

  static Color primary(BuildContext context) =>
      isLight(context) ? const Color(0xFF0284C7) : cyan;

  static Color primaryText(BuildContext context) =>
      isLight(context) ? Colors.white : midnight;

  static Color btnSoftBg(BuildContext context) =>
      isLight(context) ? const Color(0xFFE0F2FE) : cyan.withOpacity(0.12);

  static Color btnSoftText(BuildContext context) =>
      isLight(context) ? const Color(0xFF0369A1) : cyan;

  static Color chipSelectedText(BuildContext context) =>
      isLight(context) ? Colors.white : midnight;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: midnight,
      primaryColor: cyan,
      colorScheme: const ColorScheme.dark(
        primary: cyan,
        secondary: steelBlue,
        surface: midnightAlt,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: midnight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: frost,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xF20B1220),
        selectedItemColor: cyan,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      primaryColor: const Color(0xFF0284C7),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0284C7),
        secondary: Color(0xFF2563EB),
        surface: Colors.white,
        onSurface: Color(0xFF0F172A),
      ),
      cardTheme: const CardTheme(
        color: Colors.white,
        elevation: 1,
        shadowColor: Color(0x140F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: Color(0x1F0F172A)),
        ),
      ),
      dialogBackgroundColor: Colors.white,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        titleTextStyle: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF0284C7),
        unselectedItemColor: Color(0xFF64748B),
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
      ),
    );
  }

  static ThemeData get oledTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      primaryColor: const Color(0xFF00FFCC),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00FFCC),
        secondary: Color(0xFF0099FF),
        surface: Color(0xFF080808),
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Color(0xFF00FFCC),
        unselectedItemColor: Color(0xFF8E9BAE),
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
      ),
    );
  }
}

// ============================================================================
// DATA MODELS
// ============================================================================
class RecompGame {
  final String id;
  final String name;
  final String game;
  final String origin;
  final String type;
  final String version;
  final String author;
  final String repo;
  final String repoUrl;
  final String apkUrl;
  final String obtainiumUrl;
  final String cover;
  final String hero;
  final String minAndroid;
  final List<String> architectures;
  final bool touchSupported;
  final bool controllerSupported;
  final bool controllerRecommended;
  final bool gyroSupported;
  final String graphicsBackend;
  final bool turnipRecommended;
  final int fpsTarget;
  final String needs;
  final String blurb;
  final List<String> features;
  final int downloads;
  final int stars;

  RecompGame({
    required this.id,
    required this.name,
    required this.game,
    required this.origin,
    required this.type,
    required this.version,
    required this.author,
    required this.repo,
    required this.repoUrl,
    required this.apkUrl,
    required this.obtainiumUrl,
    required this.cover,
    required this.hero,
    required this.minAndroid,
    required this.architectures,
    required this.touchSupported,
    required this.controllerSupported,
    required this.controllerRecommended,
    required this.gyroSupported,
    required this.graphicsBackend,
    required this.turnipRecommended,
    required this.fpsTarget,
    required this.needs,
    required this.blurb,
    required this.features,
    required this.downloads,
    required this.stars,
    this.customPackageName,
    this.isCustom = false,
  });

  final String? customPackageName;
  final bool isCustom;

  factory RecompGame.fromJson(Map<String, dynamic> json) {
    final input = json['input'] as Map<String, dynamic>? ?? {};
    final graphics = json['graphics'] as Map<String, dynamic>? ?? {};
    final feats = json['features'] as List<dynamic>? ?? [];

    return RecompGame(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      game: json['game'] ?? json['name'] ?? '',
      origin: json['origin'] ?? 'other',
      type: json['type'] ?? 'Static Recomp',
      version: json['version'] ?? 'v1.0.0',
      author: json['author'] ?? 'Community Porters',
      repo: json['repo'] ?? '',
      repoUrl: json['repo_url'] ?? '',
      apkUrl: json['apk_url'] ?? '',
      obtainiumUrl: json['obtainium_url'] ?? '',
      cover: json['cover'] ?? '',
      hero: json['hero'] ?? json['cover'] ?? '',
      minAndroid: json['min_android'] ?? 'Android 8.0+',
      architectures: List<String>.from(json['architectures'] ?? ['arm64-v8a']),
      touchSupported: input['touch'] ?? true,
      controllerSupported: input['controller'] ?? true,
      controllerRecommended: input['controller_recommended'] ?? false,
      gyroSupported: input['gyro'] ?? false,
      graphicsBackend: graphics['backend'] ?? 'Vulkan 1.3',
      turnipRecommended: graphics['turnip_recommended'] ?? false,
      fpsTarget: graphics['fps_target'] ?? 60,
      needs: json['needs'] ?? 'Original game ROM / data files required.',
      blurb: json['blurb'] ?? '',
      features: feats.map((e) => e.toString()).toList(),
      downloads: json['downloads'] ?? 10000,
      stars: json['stars'] ?? 1500,
      customPackageName: json['package_name'] ?? json['customPackageName'],
      isCustom: json['isCustom'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'game': game,
      'origin': origin,
      'type': type,
      'version': version,
      'author': author,
      'repo': repo,
      'repo_url': repoUrl,
      'apk_url': apkUrl,
      'obtainium_url': obtainiumUrl,
      'cover': cover,
      'hero': hero,
      'min_android': minAndroid,
      'architectures': architectures,
      'input': {
        'touch': touchSupported,
        'controller': controllerSupported,
        'controller_recommended': controllerRecommended,
        'gyro': gyroSupported,
      },
      'graphics': {
        'backend': graphicsBackend,
        'turnip_recommended': turnipRecommended,
        'fps_target': fpsTarget,
      },
      'needs': needs,
      'blurb': blurb,
      'features': features,
      'downloads': downloads,
      'stars': stars,
      'package_name': customPackageName,
      'isCustom': isCustom,
    };
  }

  String get originFormatted {
    switch (origin) {
      case 'n64': return 'Nintendo 64';
      case 'x360': return 'Xbox 360';
      case 'xbox': return 'Xbox';
      case 'gc': return 'GameCube';
      case 'wii': return 'Wii';
      case 'ps1': return 'PlayStation';
      case 'ps2': return 'PlayStation 2';
      case 'psp': return 'PSP';
      case 'pc_classic': return 'PC Classic';
      case 'snes': return 'SNES';
      case 'gba': return 'GBA';
      default: return origin.toUpperCase();
    }
  }
}

// ============================================================================
// EMULATOR MODEL
// ============================================================================
class EmulatorApp {
  final String id;
  final String name;
  final String system;
  final String systemName;
  final String developer;
  final String version;
  final String icon;
  final String description;
  final List<String> features;
  final String minAndroid;
  final String graphicsBackend;
  final bool turnipRecommended;
  final bool isPaid;
  final String price;
  final String license;
  final String apkUrl;
  final String repoUrl;
  final String obtainiumUrl;
  final String category;

  EmulatorApp({
    required this.id,
    required this.name,
    required this.system,
    required this.systemName,
    required this.developer,
    required this.version,
    required this.icon,
    required this.description,
    required this.features,
    required this.minAndroid,
    required this.graphicsBackend,
    required this.turnipRecommended,
    required this.isPaid,
    required this.price,
    required this.license,
    required this.apkUrl,
    required this.repoUrl,
    required this.obtainiumUrl,
    required this.category,
  });

  factory EmulatorApp.fromJson(Map<String, dynamic> json) {
    return EmulatorApp(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      system: json['system'] ?? '',
      systemName: json['system_name'] ?? '',
      developer: json['developer'] ?? '',
      version: json['version'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'] ?? '',
      features: List<String>.from(json['features'] ?? []),
      minAndroid: json['min_android'] ?? 'Android 8.0+',
      graphicsBackend: json['graphics_backend'] ?? 'Vulkan 1.3',
      turnipRecommended: json['turnip_recommended'] ?? false,
      isPaid: json['is_paid'] ?? false,
      price: json['price'] ?? (json['is_paid'] == true ? 'Paid' : 'Free'),
      license: json['license'] ?? (json['is_paid'] == true ? 'Commercial' : 'Free / Open Source'),
      apkUrl: json['apk_url'] ?? '',
      repoUrl: json['repo_url'] ?? '',
      obtainiumUrl: json['obtainium_url'] ?? '',
      category: json['category'] ?? 'Modern 3D',
    );
  }
}

// ============================================================================
// MAIN APP ROOT & THEME STATE
// ============================================================================
final ValueNotifier<String> appThemeNotifier = ValueNotifier<String>('dark');

class DroidRecompApp extends StatelessWidget {
  const DroidRecompApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appThemeNotifier,
      builder: (context, themeName, _) {
        ThemeData activeTheme;
        if (themeName == 'light') {
          activeTheme = RecompTheme.lightTheme;
        } else if (themeName == 'oled') {
          activeTheme = RecompTheme.oledTheme;
        } else {
          activeTheme = RecompTheme.darkTheme;
        }

        return MaterialApp(
          title: 'DroidRecomp',
          debugShowCheckedModeBanner: false,
          theme: activeTheme,
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  List<RecompGame> _allGames = [];
  List<RecompGame> _customGames = [];
  List<EmulatorApp> _allEmulators = [];
  bool _isLoading = true;
  Set<String> _bookmarkedIds = {};
  Set<String> _installedIds = {};
  static const MethodChannel _launcherChannel = MethodChannel('com.droidrecomp/launcher');

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadCatalog();
    _loadEmulators();
    _loadBookmarks();
    _loadInstalled();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('app_theme') ?? 'dark';
    appThemeNotifier.value = savedTheme;
  }

  Future<void> _cycleTheme() async {
    final current = appThemeNotifier.value;
    String nextTheme;
    if (current == 'dark') {
      nextTheme = 'light';
    } else if (current == 'light') {
      nextTheme = 'oled';
    } else {
      nextTheme = 'dark';
    }
    appThemeNotifier.value = nextTheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', nextTheme);
  }

  Future<void> _loadCatalog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customJson = prefs.getString('custom_recomps_json');
      if (customJson != null && customJson.isNotEmpty) {
        try {
          final List<dynamic> decoded = json.decode(customJson);
          _customGames = decoded.map((c) => RecompGame.fromJson(c)).toList();
        } catch (_) {}
      }

      final jsonString = await rootBundle.loadString('assets/catalog.json');
      final data = json.decode(jsonString);
      final apps = data['apps'] as List<dynamic>? ?? [];
      final catalogList = apps.map((a) => RecompGame.fromJson(a)).toList();
      setState(() {
        _allGames = [..._customGames, ...catalogList];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading catalog asset: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addCustomGame(RecompGame game) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customGames.insert(0, game);
      _allGames.insert(0, game);
      _installedIds.add(game.id);
    });
    final encoded = json.encode(_customGames.map((g) => g.toJson()).toList());
    await prefs.setString('custom_recomps_json', encoded);
    await prefs.setStringList('installed_recomps', _installedIds.toList());
  }

  Future<void> _removeCustomGame(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customGames.removeWhere((g) => g.id == id);
      _allGames.removeWhere((g) => g.id == id);
      _installedIds.remove(id);
    });
    final encoded = json.encode(_customGames.map((g) => g.toJson()).toList());
    await prefs.setString('custom_recomps_json', encoded);
    await prefs.setStringList('installed_recomps', _installedIds.toList());
  }

  Future<void> _loadEmulators() async {
    try {
      final jsonString = await rootBundle.loadString('assets/emulators.json');
      final data = json.decode(jsonString);
      final list = data['emulators'] as List<dynamic>? ?? [];
      setState(() {
        _allEmulators = list.map((e) => EmulatorApp.fromJson(e)).toList();
      });
    } catch (e) {
      debugPrint('Error loading emulators asset: $e');
    }
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('saved_recomps') ?? [];
    setState(() {
      _bookmarkedIds = list.toSet();
    });
  }

  Future<void> _toggleBookmark(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_bookmarkedIds.contains(id)) {
        _bookmarkedIds.remove(id);
      } else {
        _bookmarkedIds.add(id);
      }
    });
    await prefs.setStringList('saved_recomps', _bookmarkedIds.toList());
  }

  Future<void> _loadInstalled() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? list = prefs.getStringList('installed_recomps');
    if (list == null) {
      list = ['super-mario-64-ghostship', 'zelda-ocarina-of-time-shipwright', 'another-metroid-2-remake-am2r'];
      await prefs.setStringList('installed_recomps', list);
    }
    setState(() {
      _installedIds = list!.toSet();
    });

    try {
      final List<dynamic>? devicePkgs = await _launcherChannel.invokeMethod('getInstalledPackages');
      if (devicePkgs != null) {
        final deviceSet = devicePkgs.map((e) => e.toString().toLowerCase()).toSet();
        bool changed = false;
        for (final g in _allGames) {
          final pkg = _getPackageName(g).toLowerCase();
          if (deviceSet.contains(pkg) && !_installedIds.contains(g.id)) {
            _installedIds.add(g.id);
            changed = true;
          }
        }
        if (changed) {
          setState(() {});
          await prefs.setStringList('installed_recomps', _installedIds.toList());
        }
      }
    } catch (_) {}
  }

  Future<void> _toggleInstalled(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_installedIds.contains(id)) {
        _installedIds.remove(id);
      } else {
        _installedIds.add(id);
      }
    });
    await prefs.setStringList('installed_recomps', _installedIds.toList());
  }

  static const Map<String, String> _knownPackages = {
    'super-mario-64-ghostship': 'com.n64.sm64',
    'zelda-ocarina-of-time-shipwright': 'com.soh.android',
    '2-ship-2-harkinian-2s2h': 'com.soh.twoship',
    'another-metroid-2-remake-am2r': 'com.am2r.android',
    'morrowind-openmw': 'org.libsdl.app',
    'diablo-1-devilutionx': 'org.diasurgical.devilutionx',
    'sonic-mania-decompilation-android': 'org.sonicteam.sonicmania',
    'sonic-1-forever': 'com.sonic1.forever',
    'half-life-amp-goldsrc-games': 'in.celest.xash3d.hl',
    'half-life-2-amp-portal': 'org.srceng.source',
    'fallout-1': 'com.alexander.fo1',
    'fallout-2': 'com.alexander.fo2',
    'celeste-classic-android': 'com.celeste.android',
    'hollow-knight-mobile': 'com.teamcherry.hollowknight',
    'balatro-mobile': 'com.localthunk.balatro',
    'pizza-tower-android': 'com.tourdepizza.pizzatower',
    'crash-team-racing': 'com.recomp.ctr',
    'silent-hill': 'com.recomp.silenthill',
    'halo-combat-evolved': 'com.recomp.halo',
    'resident-evil-4': 'com.recomp.re4',
    'metroid-prime': 'com.recomp.metroidprime',
    'banjo-kazooie-recomp': 'com.recomp.bk',
    'perfect-dark-recomp': 'com.recomp.perfectdark',
  };

  String _getPackageName(RecompGame game) {
    if (game.customPackageName != null && game.customPackageName!.isNotEmpty) {
      return game.customPackageName!;
    }
    if (_knownPackages.containsKey(game.id)) {
      return _knownPackages[game.id]!;
    }
    return 'com.recomp.${game.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
  }

  Future<void> _launchGame(RecompGame game) async {
    final pkg = _getPackageName(game);
    try {
      final bool? launched = await _launcherChannel.invokeMethod('launchApp', {'packageName': pkg});
      if (launched == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Launching ${game.name}...'),
              backgroundColor: const Color(0xFF0B1220),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: RecompTheme.cyan),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          _showInstallOrLaunchDialog(game, pkg);
        }
      }
    } catch (_) {
      if (mounted) {
        _showInstallOrLaunchDialog(game, pkg);
      }
    }
  }

  void _showInstallOrLaunchDialog(RecompGame game, String pkg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: RecompTheme.midnightAlt,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: RecompTheme.line),
        ),
        title: Row(
          children: [
            const Icon(Icons.sports_esports, color: RecompTheme.cyan),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                game.name,
                style: const TextStyle(color: RecompTheme.frost, fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Package "$pkg" was not found on this device.',
              style: const TextStyle(color: RecompTheme.muted, fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Text(
              'To play, download and install the native Android APK from the official release page.',
              style: TextStyle(color: RecompTheme.frost, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: RecompTheme.muted)),
          ),
          if (game.apkUrl.isNotEmpty)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: RecompTheme.cyan,
                foregroundColor: RecompTheme.midnight,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                launchUrl(Uri.parse(game.apkUrl), mode: LaunchMode.externalApplication);
              },
              child: const Text('Download APK', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: RecompTheme.cyan),
        ),
      );
    }

    final screens = [
      DiscoverTab(games: _allGames, onOpenDetail: _openGameDetail),
      BrowseTab(games: _allGames, onOpenDetail: _openGameDetail),
      EmulatorsTab(emulators: _allEmulators),
      LibraryTab(
        allGames: _allGames,
        installedIds: _installedIds,
        bookmarkedIds: _bookmarkedIds,
        onOpenDetail: _openGameDetail,
        onToggleInstalled: _toggleInstalled,
        onToggleBookmark: _toggleBookmark,
        onLaunchGame: _launchGame,
        onAddCustomGame: _addCustomGame,
        onRemoveCustomGame: _removeCustomGame,
        launcherChannel: _launcherChannel,
      ),
      const GuideTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: RecompTheme.cardBg(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: RecompTheme.border(context)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  'assets/logo.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.videogame_asset,
                    color: RecompTheme.cyan,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 19, fontFamily: 'Roboto', color: RecompTheme.text(context)),
                children: const [
                  TextSpan(text: 'Droid', style: TextStyle(fontWeight: FontWeight.w500)),
                  TextSpan(text: 'Recomp', style: TextStyle(fontWeight: FontWeight.w900, color: RecompTheme.cyan)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: RecompTheme.cyan.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: RecompTheme.cyan.withOpacity(0.3)),
              ),
              child: const Text(
                'ARM64',
                style: TextStyle(color: RecompTheme.cyan, fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        actions: [
          ValueListenableBuilder<String>(
            valueListenable: appThemeNotifier,
            builder: (context, themeName, _) {
              IconData icon;
              Color iconColor;
              String label;
              if (themeName == 'light') {
                icon = Icons.light_mode;
                iconColor = const Color(0xFFF59E0B);
                label = 'Light';
              } else if (themeName == 'oled') {
                icon = Icons.bolt;
                iconColor = const Color(0xFF00FFCC);
                label = 'OLED';
              } else {
                icon = Icons.dark_mode;
                iconColor = RecompTheme.cyan;
                label = 'Midnight';
              }
              return IconButton(
                icon: Icon(icon, color: iconColor),
                tooltip: 'Theme: $label (Tap to switch)',
                onPressed: _cycleTheme,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: GameSearchDelegate(games: _allGames, onSelect: _openGameDetail),
              );
            },
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view), label: 'Browse'),
          BottomNavigationBarItem(icon: Icon(Icons.memory_outlined), activeIcon: Icon(Icons.memory), label: 'Emulators'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_esports_outlined), activeIcon: Icon(Icons.sports_esports), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'Guide'),
        ],
      ),
    );
  }

  void _openGameDetail(RecompGame game) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameDetailScreen(
          game: game,
          isBookmarked: _bookmarkedIds.contains(game.id),
          isInstalled: _installedIds.contains(game.id),
          onToggleBookmark: () => _toggleBookmark(game.id),
          onToggleInstalled: () => _toggleInstalled(game.id),
          onLaunchGame: () => _launchGame(game),
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 1: DISCOVER
// ============================================================================
class DiscoverTab extends StatelessWidget {
  final List<RecompGame> games;
  final Function(RecompGame) onOpenDetail;

  const DiscoverTab({super.key, required this.games, required this.onOpenDetail});

  @override
  Widget build(BuildContext context) {
    final featured = games.take(5).toList();
    final topRanked = [...games]..sort((a, b) => b.downloads.compareTo(a.downloads));
    final n64Games = games.where((g) => g.origin == 'n64').toList();
    final x360Games = games.where((g) => g.origin == 'x360').toList();
    final pcPorts = games.where((g) => g.origin == 'pc_classic').toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // Featured Hero Card
        if (featured.isNotEmpty)
          SizedBox(
            height: 220,
            child: PageView.builder(
              itemCount: featured.length,
              itemBuilder: (context, idx) {
                final g = featured[idx];
                return GestureDetector(
                  onTap: () => onOpenDetail(g),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(g.hero, headers: const {'User-Agent': 'Mozilla/5.0 (Linux; Android 14)'}),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.55), BlendMode.darken),
                      ),
                      border: Border.all(color: RecompTheme.line),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: RecompTheme.cyan,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                g.originFormatted,
                                style: const TextStyle(color: RecompTheme.midnight, fontSize: 11, fontWeight: FontWeight.w800),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (g.turnipRecommended)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: RecompTheme.turnipGold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: RecompTheme.turnipGold),
                                ),
                                child: const Text(
                                  '⚡ Turnip Tested',
                                  style: TextStyle(color: RecompTheme.turnipGold, fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          g.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          g.blurb,
                          style: const TextStyle(fontSize: 12, color: RecompTheme.muted),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 28),

        // Section: Top Ranked
        _buildSectionHeader('Top Ranked Recomps'),
        _buildHorizontalRow(topRanked.take(10).toList(), showRank: true),

        const SizedBox(height: 24),

        // Section: N64 Recomps
        _buildSectionHeader('Nintendo 64 Recompiled'),
        _buildHorizontalRow(n64Games.take(10).toList()),

        const SizedBox(height: 24),

        // Section: Xbox 360 Static Recomps
        _buildSectionHeader('Xbox 360 Recompilations'),
        _buildHorizontalRow(x360Games.take(10).toList()),

        const SizedBox(height: 24),

        // Section: Classic PC Source Ports
        _buildSectionHeader('Classic PC & Engine Ports'),
        _buildHorizontalRow(pcPorts.take(10).toList()),

        const SizedBox(height: 20),

        // BYOR Legal Callout
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RecompTheme.glass,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: RecompTheme.line),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NO GAME FILES DISTRIBUTED',
                style: TextStyle(color: RecompTheme.cyan, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8),
              ),
              SizedBox(height: 6),
              Text(
                'DroidRecomp indexes only open-source native Android game recompilations. Zero copyrighted ROMs or disc images are hosted. Users must supply their own legally owned backups.',
                style: TextStyle(color: RecompTheme.muted, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: RecompTheme.frost),
      ),
    );
  }

  Widget _buildHorizontalRow(List<RecompGame> list, {bool showRank = false}) {
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: list.length,
        itemBuilder: (context, i) {
          final g = list[i];
          return GestureDetector(
            onTap: () => onOpenDetail(g),
            child: Container(
              width: 130,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: RecompTheme.glass,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: RecompTheme.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                        child: Image.network(
                          g.cover,
                          headers: const {'User-Agent': 'Mozilla/5.0 (Linux; Android 14)'},
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 140,
                            color: RecompTheme.midnightAlt,
                            child: const Icon(Icons.videogame_asset, color: RecompTheme.muted),
                          ),
                        ),
                      ),
                      if (showRank)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: RecompTheme.midnight.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: RecompTheme.cyan.withOpacity(0.4)),
                            ),
                            child: Text(
                              '#${i + 1}',
                              style: const TextStyle(color: RecompTheme.cyan, fontSize: 10, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            g.origin.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: RecompTheme.frost),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          g.type,
                          style: const TextStyle(fontSize: 10, color: RecompTheme.muted),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// TAB 2: BROWSE & QUAD-FILTER
// ============================================================================
class BrowseTab extends StatefulWidget {
  final List<RecompGame> games;
  final Function(RecompGame) onOpenDetail;

  const BrowseTab({super.key, required this.games, required this.onOpenDetail});

  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab> {
  String _selectedOrigin = 'all';
  final String _selectedType = 'all';
  bool _turnipOnly = false;
  bool _touchOnly = false;

  final origins = [
    {'id': 'all', 'name': 'All Consoles'},
    {'id': 'n64', 'name': 'N64'},
    {'id': 'x360', 'name': 'Xbox 360'},
    {'id': 'xbox', 'name': 'Xbox'},
    {'id': 'gc', 'name': 'GameCube'},
    {'id': 'wii', 'name': 'Wii'},
    {'id': 'ps1', 'name': 'PS1'},
    {'id': 'ps2', 'name': 'PS2'},
    {'id': 'pc_classic', 'name': 'PC Ports'},
  ];

  @override
  Widget build(BuildContext context) {
    var filtered = widget.games;

    if (_selectedOrigin != 'all') {
      filtered = filtered.where((g) => g.origin == _selectedOrigin).toList();
    }
    if (_selectedType != 'all') {
      filtered = filtered.where((g) => g.type == _selectedType).toList();
    }
    if (_turnipOnly) {
      filtered = filtered.where((g) => g.turnipRecommended).toList();
    }
    if (_touchOnly) {
      filtered = filtered.where((g) => g.touchSupported).toList();
    }

    return Column(
      children: [
        // Horizontal Origin Pills
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: origins.length,
            itemBuilder: (context, idx) {
              final o = origins[idx];
              final isSelected = _selectedOrigin == o['id'];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(o['name']!),
                  selected: isSelected,
                  selectedColor: RecompTheme.cyan.withOpacity(0.2),
                  backgroundColor: RecompTheme.glass,
                  labelStyle: TextStyle(
                    color: isSelected ? RecompTheme.cyan : RecompTheme.muted,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected ? RecompTheme.cyan : RecompTheme.line,
                  ),
                  onSelected: (val) {
                    setState(() => _selectedOrigin = o['id']!);
                  },
                ),
              );
            },
          ),
        ),

        // Quick Toggle Row (Turnip & Touch)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              FilterChip(
                label: const Text('⚡ Turnip Tested', style: TextStyle(fontSize: 11)),
                selected: _turnipOnly,
                onSelected: (val) => setState(() => _turnipOnly = val),
                selectedColor: RecompTheme.turnipGold.withOpacity(0.2),
                labelStyle: TextStyle(color: _turnipOnly ? RecompTheme.turnipGold : RecompTheme.muted),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Touch Ready', style: TextStyle(fontSize: 11)),
                selected: _touchOnly,
                onSelected: (val) => setState(() => _touchOnly = val),
                selectedColor: RecompTheme.successGreen.withOpacity(0.2),
                labelStyle: TextStyle(color: _touchOnly ? RecompTheme.successGreen : RecompTheme.muted),
              ),
              const Spacer(),
              Text(
                '${filtered.length} Recomps',
                style: const TextStyle(fontSize: 12, color: RecompTheme.muted, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        const Divider(color: RecompTheme.line),

        // Games Grid
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text('No recomps match your filters', style: TextStyle(color: RecompTheme.muted)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, idx) {
                    final game = filtered[idx];
                    return Card(
                      color: RecompTheme.glass,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: RecompTheme.line),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            game.cover,
                            headers: const {'User-Agent': 'Mozilla/5.0 (Linux; Android 14)'},
                            width: 50,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 50,
                              height: 70,
                              color: RecompTheme.midnightAlt,
                              child: const Icon(Icons.videogame_asset, color: RecompTheme.muted),
                            ),
                          ),
                        ),
                        title: Text(
                          game.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: RecompTheme.frost),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${game.originFormatted} • ${game.type}',
                              style: const TextStyle(fontSize: 11, color: RecompTheme.muted),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                if (game.turnipRecommended)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: BoxDecoration(
                                      color: RecompTheme.turnipGold.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('Turnip ⚡', style: TextStyle(color: RecompTheme.turnipGold, fontSize: 9)),
                                  ),
                                if (game.touchSupported)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: RecompTheme.successGreen.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('Touch', style: TextStyle(color: RecompTheme.successGreen, fontSize: 9)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right, color: RecompTheme.cyan),
                        onTap: () => widget.onOpenDetail(game),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ============================================================================
// TAB: ANDROID EMULATORS HUB
// ============================================================================
class EmulatorsTab extends StatefulWidget {
  final List<EmulatorApp> emulators;

  const EmulatorsTab({super.key, required this.emulators});

  @override
  State<EmulatorsTab> createState() => _EmulatorsTabState();
}

class _EmulatorsTabState extends State<EmulatorsTab> {
  String _selectedSystem = 'all';
  String _searchQuery = '';

  final List<Map<String, String>> _categories = const [
    {'id': 'all', 'label': 'All Emulators'},
    {'id': 'free', 'label': '🎁 Free Only'},
    {'id': 'paid', 'label': '💎 Paid / Pro'},
    {'id': 'ps2', 'label': 'PlayStation 2'},
    {'id': 'switch', 'label': 'Nintendo Switch'},
    {'id': 'pc_win', 'label': 'PC & Translation'},
    {'id': 'engines_mobile', 'label': 'Engines & Mobile'},
    {'id': 'gc_wii', 'label': 'GameCube & Wii'},
    {'id': '3ds', 'label': 'Nintendo 3DS'},
    {'id': 'nds', 'label': 'Nintendo DS'},
    {'id': 'psp_vita', 'label': 'PSP & PS Vita'},
    {'id': 'ps1', 'label': 'PlayStation 1'},
    {'id': 'dc_saturn', 'label': 'Dreamcast & Saturn'},
    {'id': 'classic_2d', 'label': 'GBA / SNES / N64'},
    {'id': 'multi', 'label': 'Multi-System'},
    {'id': 'drivers', 'label': '⚡ Turnip Drivers'},
  ];

  void _showEmulatorDetailSheet(EmulatorApp emu) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: RecompTheme.midnightAlt,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: RecompTheme.muted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    emu.icon,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    headers: const {'User-Agent': 'Mozilla/5.0 (Linux; Android 14)'},
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: RecompTheme.midnight,
                      child: const Icon(Icons.memory, color: RecompTheme.cyan, size: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emu.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: RecompTheme.frost),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        emu.systemName,
                        style: const TextStyle(fontSize: 13, color: RecompTheme.cyan, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'by ${emu.developer} • ${emu.version}',
                        style: const TextStyle(fontSize: 12, color: RecompTheme.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Chip(
                  label: Text(emu.isPaid ? emu.price : 'Free', style: TextStyle(fontSize: 11, color: emu.isPaid ? const Color(0xFFB45309) : const Color(0xFF047857), fontWeight: FontWeight.w800)),
                  backgroundColor: emu.isPaid ? const Color(0x33F59E0B) : const Color(0x3310B981),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Chip(
                  label: Text(emu.license, style: const TextStyle(fontSize: 11, color: RecompTheme.frost)),
                  backgroundColor: RecompTheme.glass,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Chip(
                  label: Text(emu.category, style: const TextStyle(fontSize: 11, color: RecompTheme.midnight, fontWeight: FontWeight.w800)),
                  backgroundColor: RecompTheme.cyan,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Chip(
                  label: Text(emu.graphicsBackend, style: const TextStyle(fontSize: 11, color: RecompTheme.frost)),
                  backgroundColor: RecompTheme.glass,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                if (emu.turnipRecommended)
                  const Chip(
                    label: Text('⚡ Turnip Rec.', style: TextStyle(fontSize: 11, color: RecompTheme.turnipGold, fontWeight: FontWeight.w700)),
                    backgroundColor: Color(0x22F59E0B),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Overview', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: RecompTheme.frost)),
            const SizedBox(height: 6),
            Text(
              emu.description,
              style: const TextStyle(fontSize: 13, color: RecompTheme.muted, height: 1.45),
            ),
            const SizedBox(height: 18),
            const Text('Key Features', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: RecompTheme.frost)),
            const SizedBox(height: 8),
            ...emu.features.map(
              (f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline, color: RecompTheme.cyan, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(f, style: const TextStyle(fontSize: 12, color: RecompTheme.frost)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: RecompTheme.glass,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: RecompTheme.line),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Minimum Android', style: TextStyle(color: RecompTheme.muted, fontSize: 12)),
                      Text(emu.minAndroid, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: RecompTheme.frost)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Graphics Backend', style: TextStyle(color: RecompTheme.muted, fontSize: 12)),
                      Text(emu.graphicsBackend, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: RecompTheme.frost)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (emu.apkUrl.isNotEmpty)
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: emu.isPaid ? const Color(0xFFF59E0B) : RecompTheme.cyan,
                        foregroundColor: emu.isPaid ? const Color(0xFF0B1220) : RecompTheme.midnight,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: Icon(emu.isPaid ? Icons.shopping_bag : Icons.download, size: 18),
                      label: Text(
                        emu.isPaid ? (emu.apkUrl.contains('google.com') ? 'Google Play' : 'Get App') : 'Download APK',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      onPressed: () => launchUrl(Uri.parse(emu.apkUrl), mode: LaunchMode.externalApplication),
                    ),
                  ),
                if (emu.obtainiumUrl.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: RecompTheme.btnSoftText(context),
                      backgroundColor: RecompTheme.btnSoftBg(context),
                      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
                      side: BorderSide(color: RecompTheme.primary(context).withOpacity(0.35)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: Icon(Icons.sync, color: RecompTheme.primary(context), size: 18),
                    label: const Text('Obtainium', style: TextStyle(fontWeight: FontWeight.w700)),
                    onPressed: () => launchUrl(Uri.parse(emu.obtainiumUrl), mode: LaunchMode.externalApplication),
                  ),
                ],
                if (emu.repoUrl.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.open_in_browser, color: RecompTheme.muted),
                    tooltip: 'Official Releases / Repo',
                    onPressed: () => launchUrl(Uri.parse(emu.repoUrl), mode: LaunchMode.externalApplication),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var filtered = widget.emulators.where((e) {
      if (_selectedSystem != 'all') {
        if (_selectedSystem == 'free') {
          if (e.isPaid) return false;
        } else if (_selectedSystem == 'paid') {
          if (!e.isPaid) return false;
        } else if (_selectedSystem == 'psp_vita') {
          if (e.system != 'psp' && e.system != 'ps_vita') return false;
        } else if (_selectedSystem == 'classic_2d') {
          if (e.system != 'classic_2d') return false;
        } else if (_selectedSystem == 'dc_saturn') {
          if (e.system != 'dc_saturn') return false;
        } else if (_selectedSystem == 'engines_mobile') {
          if (e.system != 'engines_mobile') return false;
        } else if (e.system != _selectedSystem) {
          return false;
        }
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesName = e.name.toLowerCase().contains(q);
        final matchesSys = e.systemName.toLowerCase().contains(q);
        final matchesDev = e.developer.toLowerCase().contains(q);
        final matchesDesc = e.description.toLowerCase().contains(q);
        final matchesLicense = e.license.toLowerCase().contains(q);
        final matchesPrice = e.price.toLowerCase().contains(q);
        if (!matchesName && !matchesSys && !matchesDev && !matchesDesc && !matchesLicense && !matchesPrice) {
          return false;
        }
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Header & Search
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: RecompTheme.midnightAlt,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search emulators, systems, drivers...',
                  prefixIcon: const Icon(Icons.search, color: RecompTheme.muted),
                  filled: true,
                  fillColor: RecompTheme.glass,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: RecompTheme.line),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, idx) {
                    final cat = _categories[idx];
                    final isSelected = _selectedSystem == cat['id'];
                    return ChoiceChip(
                      label: Text(
                        cat['label']!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? RecompTheme.midnight : RecompTheme.frost,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: RecompTheme.cyan,
                      backgroundColor: RecompTheme.glass,
                      side: BorderSide(color: isSelected ? RecompTheme.cyan : RecompTheme.line),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      onSelected: (_) => setState(() => _selectedSystem = cat['id']!),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Emulators List
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text('No emulators match your filter', style: TextStyle(color: RecompTheme.muted)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  itemCount: filtered.length,
                  itemBuilder: (context, idx) {
                    final emu = filtered[idx];
                    return Card(
                      color: RecompTheme.glass,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: RecompTheme.cyan.withOpacity(0.2)),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showEmulatorDetailSheet(emu),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      emu.icon,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      headers: const {'User-Agent': 'Mozilla/5.0 (Linux; Android 14)'},
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 48,
                                        height: 48,
                                        color: RecompTheme.midnightAlt,
                                        child: const Icon(Icons.memory, color: RecompTheme.cyan),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                emu.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15,
                                                  color: RecompTheme.frost,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: emu.isPaid ? const Color(0x33F59E0B) : const Color(0x3310B981),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: emu.isPaid ? const Color(0x66F59E0B) : const Color(0x6610B981)),
                                              ),
                                              child: Text(
                                                emu.isPaid ? emu.price : 'Free',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  color: emu.isPaid ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.08),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                emu.version,
                                                style: const TextStyle(fontSize: 10, color: RecompTheme.muted),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          emu.systemName,
                                          style: const TextStyle(
                                            color: RecompTheme.cyan,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          'by ${emu.developer}',
                                          style: const TextStyle(color: RecompTheme.muted, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                emu.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: RecompTheme.muted, height: 1.4),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  if (emu.apkUrl.isNotEmpty)
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: emu.isPaid ? const Color(0xFFF59E0B) : RecompTheme.cyan,
                                          foregroundColor: emu.isPaid ? const Color(0xFF0B1220) : RecompTheme.midnight,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          elevation: 2,
                                        ),
                                        icon: Icon(emu.isPaid ? Icons.shopping_bag : Icons.download, size: 16),
                                        label: Text(
                                          emu.isPaid ? (emu.apkUrl.contains('google.com') ? 'Google Play' : 'Get App') : 'Download APK',
                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                                        ),
                                        onPressed: () => launchUrl(Uri.parse(emu.apkUrl), mode: LaunchMode.externalApplication),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  if (emu.obtainiumUrl.isNotEmpty)
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: RecompTheme.btnSoftText(context),
                                        backgroundColor: RecompTheme.btnSoftBg(context),
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                        side: BorderSide(color: RecompTheme.primary(context).withOpacity(0.35)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      icon: Icon(Icons.sync, color: RecompTheme.primary(context), size: 15),
                                      label: const Text('Obtainium', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                                      onPressed: () => launchUrl(Uri.parse(emu.obtainiumUrl), mode: LaunchMode.externalApplication),
                                    ),
                                  IconButton(
                                    icon: Icon(Icons.info_outline, color: RecompTheme.text(context), size: 20),
                                    tooltip: 'Details',
                                    onPressed: () => _showEmulatorDetailSheet(emu),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ============================================================================
// TAB 3: LIBRARY & LAUNCHER (INSTALLED & BOOKMARKS)
// ============================================================================
class LibraryTab extends StatefulWidget {
  final List<RecompGame> allGames;
  final Set<String> installedIds;
  final Set<String> bookmarkedIds;
  final Function(RecompGame) onOpenDetail;
  final Function(String) onToggleInstalled;
  final Function(String) onToggleBookmark;
  final Function(RecompGame) onLaunchGame;
  final Function(RecompGame) onAddCustomGame;
  final Function(String) onRemoveCustomGame;
  final MethodChannel launcherChannel;

  const LibraryTab({
    super.key,
    required this.allGames,
    required this.installedIds,
    required this.bookmarkedIds,
    required this.onOpenDetail,
    required this.onToggleInstalled,
    required this.onToggleBookmark,
    required this.onLaunchGame,
    required this.onAddCustomGame,
    required this.onRemoveCustomGame,
    required this.launcherChannel,
  });

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  int _selectedSubTab = 0; // 0 = Installed, 1 = Bookmarks

  void _showAddInstalledSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: RecompTheme.midnightAlt,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        int sheetTab = 0; // 0 = Phone Apps, 1 = Manual Port, 2 = Catalog
        String filter = '';
        List<Map<dynamic, dynamic>> deviceApps = [];
        bool loadingApps = true;

        // Fetch installed apps on device
        widget.launcherChannel.invokeMethod('getInstalledApps').then((res) {
          if (res != null && res is List) {
            deviceApps = res.cast<Map<dynamic, dynamic>>();
          }
          loadingApps = false;
        }).catchError((_) {
          loadingApps = false;
        });

        // Form controllers for manual entry
        final nameCtrl = TextEditingController();
        final pkgCtrl = TextEditingController();
        final coverCtrl = TextEditingController();
        String selectedOrigin = 'pc_classic';

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.add_circle_outline, color: RecompTheme.cyan),
                          SizedBox(width: 8),
                          Text(
                            'Add Game to Library',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: RecompTheme.frost),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: RecompTheme.muted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Sub-tabs in modal
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('📱 Phone Apps', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          selected: sheetTab == 0,
                          selectedColor: RecompTheme.cyan,
                          backgroundColor: RecompTheme.glass,
                          labelStyle: TextStyle(color: sheetTab == 0 ? RecompTheme.midnight : RecompTheme.frost),
                          onSelected: (_) => setModalState(() => sheetTab = 0),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('✍️ Manual', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          selected: sheetTab == 1,
                          selectedColor: RecompTheme.cyan,
                          backgroundColor: RecompTheme.glass,
                          labelStyle: TextStyle(color: sheetTab == 1 ? RecompTheme.midnight : RecompTheme.frost),
                          onSelected: (_) => setModalState(() => sheetTab = 1),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('📋 Catalog', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          selected: sheetTab == 2,
                          selectedColor: RecompTheme.cyan,
                          backgroundColor: RecompTheme.glass,
                          labelStyle: TextStyle(color: sheetTab == 2 ? RecompTheme.midnight : RecompTheme.frost),
                          onSelected: (_) => setModalState(() => sheetTab = 2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // TAB CONTENT
                  Expanded(
                    child: sheetTab == 0
                        ? _buildPhoneAppsPicker(deviceApps, loadingApps, setModalState, ctx)
                        : sheetTab == 1
                            ? _buildManualEntryForm(nameCtrl, pkgCtrl, coverCtrl, selectedOrigin, (orig) => setModalState(() => selectedOrigin = orig), ctx)
                            : _buildCatalogPicker(filter, (f) => setModalState(() => filter = f), ctx),
                  ),

                  // Global submission promo footer
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: RecompTheme.midnight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: RecompTheme.line),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.public, color: RecompTheme.cyan, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Want to submit this game to the official catalog?',
                            style: TextStyle(fontSize: 11, color: RecompTheme.muted),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            launchUrl(
                              Uri.parse('https://github.com/MooPuu/droid-recomp/issues/new?title=%5BRecomp+Submission%5D'),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                          child: const Text('Submit via GitHub', style: TextStyle(color: RecompTheme.cyan, fontSize: 11, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPhoneAppsPicker(List<Map<dynamic, dynamic>> apps, bool loading, StateSetter setModalState, BuildContext sheetCtx) {
    if (loading && apps.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: RecompTheme.cyan));
    }
    if (apps.isEmpty) {
      return const Center(child: Text('No launchable applications found on device', style: TextStyle(color: RecompTheme.muted)));
    }

    return ListView.builder(
      itemCount: apps.length,
      itemBuilder: (ctx, idx) {
        final item = apps[idx];
        final label = item['label']?.toString() ?? 'App';
        final pkg = item['packageName']?.toString() ?? '';

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: RecompTheme.glass,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: RecompTheme.line),
            ),
            child: const Icon(Icons.android, color: RecompTheme.cyan),
          ),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          subtitle: Text(pkg, style: const TextStyle(fontSize: 11, color: RecompTheme.muted)),
          trailing: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: RecompTheme.cyan,
              foregroundColor: RecompTheme.midnight,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.add, size: 15),
            label: const Text('Add', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
            onPressed: () {
              final newGame = RecompGame(
                id: 'custom_\${pkg.replaceAll(RegExp(r"[^a-zA-Z0-9]"), "_")}_\${DateTime.now().millisecondsSinceEpoch}',
                name: label,
                game: label,
                origin: 'pc_classic',
                type: 'Custom Sideload',
                version: 'v1.0',
                author: 'User Sideload',
                repo: '',
                repoUrl: '',
                apkUrl: '',
                obtainiumUrl: '',
                cover: 'https://images.igdb.com/igdb/image/upload/t_cover_big/co1x4n.jpg',
                hero: '',
                minAndroid: 'Android 8.0+',
                architectures: ['arm64-v8a'],
                touchSupported: true,
                controllerSupported: true,
                controllerRecommended: true,
                gyroSupported: false,
                graphicsBackend: 'Vulkan / OpenGL',
                turnipRecommended: false,
                fpsTarget: 60,
                needs: 'Installed from device application',
                blurb: 'Sideloaded custom game.',
                features: ['Device Sideloaded App', '1-Tap Launcher'],
                downloads: 1,
                stars: 5,
                customPackageName: pkg,
                isCustom: true,
              );
              widget.onAddCustomGame(newGame);
              Navigator.pop(sheetCtx);
            },
          ),
        );
      },
    );
  }

  Widget _buildManualEntryForm(
    TextEditingController nameCtrl,
    TextEditingController pkgCtrl,
    TextEditingController coverCtrl,
    String selectedOrigin,
    Function(String) onOriginChange,
    BuildContext sheetCtx,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Game Title *',
            hintText: 'e.g. Portal (Source Engine), AM2R',
            filled: true,
            fillColor: RecompTheme.glass,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: pkgCtrl,
          decoration: const InputDecoration(
            labelText: 'Android Package Name *',
            hintText: 'e.g. org.srceng.source, com.am2r.android',
            filled: true,
            fillColor: RecompTheme.glass,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedOrigin,
          decoration: const InputDecoration(
            labelText: 'Original Platform *',
            filled: true,
            fillColor: RecompTheme.glass,
          ),
          dropdownColor: RecompTheme.midnightAlt,
          items: const [
            DropdownMenuItem(value: 'n64', child: Text('Nintendo 64')),
            DropdownMenuItem(value: 'x360', child: Text('Xbox 360')),
            DropdownMenuItem(value: 'xbox', child: Text('Xbox')),
            DropdownMenuItem(value: 'gc', child: Text('GameCube')),
            DropdownMenuItem(value: 'wii', child: Text('Wii')),
            DropdownMenuItem(value: 'ps1', child: Text('PlayStation 1')),
            DropdownMenuItem(value: 'ps2', child: Text('PlayStation 2')),
            DropdownMenuItem(value: 'psp', child: Text('PSP')),
            DropdownMenuItem(value: 'pc_classic', child: Text('Classic PC / Source Port')),
          ],
          onChanged: (val) {
            if (val != null) onOriginChange(val);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: coverCtrl,
          decoration: const InputDecoration(
            labelText: 'Cover Box Art URL (Optional)',
            hintText: 'https://... (Leave blank for default art)',
            filled: true,
            fillColor: RecompTheme.glass,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: RecompTheme.cyan,
            foregroundColor: RecompTheme.midnight,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            final name = nameCtrl.text.trim();
            final pkg = pkgCtrl.text.trim();
            if (name.isEmpty || pkg.isEmpty) return;

            final newGame = RecompGame(
              id: 'custom_\${pkg.replaceAll(RegExp(r"[^a-zA-Z0-9]"), "_")}_\${DateTime.now().millisecondsSinceEpoch}',
              name: name,
              game: name,
              origin: selectedOrigin,
              type: 'Custom Sideload',
              version: 'v1.0',
              author: 'User Sideload',
              repo: '',
              repoUrl: '',
              apkUrl: '',
              obtainiumUrl: '',
              cover: coverCtrl.text.trim().isNotEmpty
                  ? coverCtrl.text.trim()
                  : 'https://images.igdb.com/igdb/image/upload/t_cover_big/co1x4n.jpg',
              hero: coverCtrl.text.trim(),
              minAndroid: 'Android 8.0+',
              architectures: ['arm64-v8a'],
              touchSupported: true,
              controllerSupported: true,
              controllerRecommended: true,
              gyroSupported: false,
              graphicsBackend: 'Vulkan / OpenGL',
              turnipRecommended: false,
              fpsTarget: 60,
              needs: 'Custom sideloaded files',
              blurb: 'User-added personal recompilation.',
              features: ['Custom Personal Game', '1-Tap Launcher'],
              downloads: 1,
              stars: 5,
              customPackageName: pkg,
              isCustom: true,
            );
            widget.onAddCustomGame(newGame);
            Navigator.pop(sheetCtx);
          },
          child: const Text('Save to My Launcher', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildCatalogPicker(String filter, Function(String) onFilterChange, BuildContext sheetCtx) {
    final uninstalled = widget.allGames.where((g) {
      final isNotInstalled = !widget.installedIds.contains(g.id);
      if (!isNotInstalled) return false;
      if (filter.isEmpty) return true;
      return g.name.toLowerCase().contains(filter.toLowerCase()) ||
          g.originFormatted.toLowerCase().contains(filter.toLowerCase());
    }).toList();

    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search 371+ catalog recomps...',
            prefixIcon: const Icon(Icons.search, color: RecompTheme.muted),
            filled: true,
            fillColor: RecompTheme.glass,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (val) => onFilterChange(val),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: uninstalled.isEmpty
              ? const Center(child: Text('No catalog games found', style: TextStyle(color: RecompTheme.muted)))
              : ListView.builder(
                  itemCount: uninstalled.length,
                  itemBuilder: (ctx, idx) {
                    final game = uninstalled[idx];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          game.cover,
                          width: 44,
                          height: 60,
                          fit: BoxFit.cover,
                          headers: const {'User-Agent': 'Mozilla/5.0 (Linux; Android 14)'},
                          errorBuilder: (_, __, ___) => Container(
                            width: 44,
                            height: 60,
                            color: RecompTheme.midnight,
                            child: const Icon(Icons.videogame_asset, color: RecompTheme.muted),
                          ),
                        ),
                      ),
                      title: Text(game.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: Text('${game.originFormatted} • ${game.type}', style: const TextStyle(color: RecompTheme.muted, fontSize: 12)),
                      trailing: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RecompTheme.cyan,
                          foregroundColor: RecompTheme.midnight,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                        onPressed: () {
                          widget.onToggleInstalled(game.id);
                          Navigator.pop(sheetCtx);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final installedGames = widget.allGames.where((g) => widget.installedIds.contains(g.id)).toList();
    final bookmarkedGames = widget.allGames.where((g) => widget.bookmarkedIds.contains(g.id)).toList();

    return Column(
      children: [
        // Top Sub-tabs Switcher
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: RecompTheme.midnightAlt,
            border: Border(bottom: BorderSide(color: RecompTheme.line)),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSubTab = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedSubTab == 0 ? RecompTheme.cyan : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selectedSubTab == 0 ? RecompTheme.cyan : RecompTheme.line,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_esports,
                          size: 18,
                          color: _selectedSubTab == 0 ? RecompTheme.midnight : RecompTheme.frost,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Installed (${installedGames.length})',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: _selectedSubTab == 0 ? RecompTheme.midnight : RecompTheme.frost,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSubTab = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedSubTab == 1 ? RecompTheme.cyan : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selectedSubTab == 1 ? RecompTheme.cyan : RecompTheme.line,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark,
                          size: 18,
                          color: _selectedSubTab == 1 ? RecompTheme.midnight : RecompTheme.frost,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Bookmarks (${bookmarkedGames.length})',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: _selectedSubTab == 1 ? RecompTheme.midnight : RecompTheme.frost,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Subtab View
        Expanded(
          child: _selectedSubTab == 0
              ? _buildInstalledView(installedGames)
              : _buildBookmarksView(bookmarkedGames),
        ),
      ],
    );
  }

  Widget _buildInstalledView(List<RecompGame> installedGames) {
    if (installedGames.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_esports, size: 64, color: RecompTheme.cyan.withOpacity(0.5)),
              const SizedBox(height: 16),
              const Text(
                'No Installed Games Marked Yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: RecompTheme.frost),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add the recompilations you have installed to launch them with 1 tap right from DroidRecomp.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: RecompTheme.muted, height: 1.4),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: RecompTheme.cyan,
                  foregroundColor: RecompTheme.midnight,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add Installed Game', style: TextStyle(fontWeight: FontWeight.w800)),
                onPressed: _showAddInstalledSheet,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        // Sub-header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${installedGames.length} Recomps Ready to Launch',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: RecompTheme.muted),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: RecompTheme.cyan,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('+ Add Game', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                onPressed: _showAddInstalledSheet,
              ),
            ],
          ),
        ),

        // List of Installed Games
        ...installedGames.map((game) {
          return Card(
            color: RecompTheme.glass,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: RecompTheme.cyan.withOpacity(0.25)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => widget.onOpenDetail(game),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Cover Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        game.cover,
                        width: 65,
                        height: 90,
                        fit: BoxFit.cover,
                        headers: const {'User-Agent': 'Mozilla/5.0 (Linux; Android 14)'},
                        errorBuilder: (_, __, ___) => Container(
                          width: 65,
                          height: 90,
                          color: RecompTheme.midnightAlt,
                          child: const Icon(Icons.sports_esports, color: RecompTheme.cyan),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Game Info & Actions
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: RecompTheme.cyan.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  game.originFormatted,
                                  style: const TextStyle(color: RecompTheme.cyan, fontSize: 10, fontWeight: FontWeight.w800),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                tooltip: 'Remove from installed',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => widget.onToggleInstalled(game.id),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            game.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: RecompTheme.frost),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            game.type,
                            style: const TextStyle(fontSize: 11, color: RecompTheme.muted),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: RecompTheme.cyan,
                                foregroundColor: RecompTheme.midnight,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 3,
                              ),
                              icon: const Icon(Icons.play_arrow, size: 20),
                              label: const Text(
                                '▶ LAUNCH',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8),
                              ),
                              onPressed: () => widget.onLaunchGame(game),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBookmarksView(List<RecompGame> bookmarkedGames) {
    if (bookmarkedGames.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: RecompTheme.muted.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'No Bookmarks Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: RecompTheme.frost),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bookmark recompilations to track releases\nand quick-access their links.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: RecompTheme.muted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookmarkedGames.length,
      itemBuilder: (context, idx) {
        final g = bookmarkedGames[idx];
        return Card(
          color: RecompTheme.glass,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: RecompTheme.line),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                g.cover,
                width: 50,
                height: 70,
                fit: BoxFit.cover,
                headers: const {'User-Agent': 'Mozilla/5.0 (Linux; Android 14)'},
                errorBuilder: (_, __, ___) => Container(
                  width: 50,
                  height: 70,
                  color: RecompTheme.midnightAlt,
                  child: const Icon(Icons.videogame_asset, color: RecompTheme.muted),
                ),
              ),
            ),
            title: Text(g.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            subtitle: Text('${g.originFormatted} • ${g.version}'),
            trailing: IconButton(
              icon: const Icon(Icons.bookmark_remove, color: RecompTheme.cyan),
              onPressed: () => widget.onToggleBookmark(g.id),
            ),
            onTap: () => widget.onOpenDetail(g),
          ),
        );
      },
    );
  }
}

// ============================================================================
// TAB 4: SETUP GUIDE & LEGAL
// ============================================================================
class GuideTab extends StatelessWidget {
  const GuideTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Android Recomp Setup Guide',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: RecompTheme.frost),
        ),
        const SizedBox(height: 8),
        const Text(
          'Learn how static recompilations work on mobile devices and how to supply your own game assets legally.',
          style: TextStyle(fontSize: 13, color: RecompTheme.muted, height: 1.4),
        ),
        const SizedBox(height: 24),

        _buildStepCard(
          '1',
          'Download Native ARM64 APK',
          'Each recomp compiles to a clean, native Android APK. Download the build directly from the developer’s GitHub release or sync it using Obtainium.',
        ),
        _buildStepCard(
          '2',
          'Extract Your Original Game ROM',
          'Because recompilations distribute zero copyrighted game assets, you must dump your own retail ROM or disc image (e.g. .z64, .iso, PC data files).',
        ),
        _buildStepCard(
          '3',
          'Scoped Storage & Asset Placement',
          'Place your extracted assets in your internal storage directory at /Android/data/{package_name}/files/ or use the app’s built-in Storage Access Framework (SAF) folder selector.',
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: RecompTheme.midnightAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: RecompTheme.cyan.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.sync, color: RecompTheme.cyan),
                  SizedBox(width: 8),
                  Text('Obtainium Integration', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Obtainium allows you to track and auto-update your installed recompilations straight from GitHub releases in the background without Google Play.',
                style: TextStyle(fontSize: 12, color: RecompTheme.muted, height: 1.4),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: RecompTheme.cyan,
                  foregroundColor: RecompTheme.midnight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => launchUrl(Uri.parse('https://github.com/ImranR98/Obtainium')),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Get Obtainium App', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard(String number, String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RecompTheme.glass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RecompTheme.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: RecompTheme.cyan.withOpacity(0.2),
            child: Text(number, style: const TextStyle(color: RecompTheme.cyan, fontWeight: FontWeight.w800, fontSize: 12)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: RecompTheme.frost)),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(color: RecompTheme.muted, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// GAME DETAIL SCREEN
// ============================================================================
class GameDetailScreen extends StatelessWidget {
  final RecompGame game;
  final bool isBookmarked;
  final bool isInstalled;
  final VoidCallback onToggleBookmark;
  final VoidCallback onToggleInstalled;
  final VoidCallback onLaunchGame;

  const GameDetailScreen({
    super.key,
    required this.game,
    required this.isBookmarked,
    required this.isInstalled,
    required this.onToggleBookmark,
    required this.onToggleInstalled,
    required this.onLaunchGame,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    game.hero,
                    headers: const {'User-Agent': 'Mozilla/5.0 (Linux; Android 14)'},
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: RecompTheme.midnightAlt),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          RecompTheme.midnight.withOpacity(0.9),
                          RecompTheme.midnight,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isInstalled ? Icons.sports_esports : Icons.sports_esports_outlined,
                  color: isInstalled ? RecompTheme.cyan : Colors.white,
                ),
                tooltip: isInstalled ? 'Installed' : 'Mark Installed',
                onPressed: onToggleInstalled,
              ),
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? RecompTheme.cyan : Colors.white,
                ),
                tooltip: isBookmarked ? 'Bookmarked' : 'Bookmark',
                onPressed: onToggleBookmark,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: RecompTheme.cyan,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          game.originFormatted,
                          style: const TextStyle(color: RecompTheme.midnight, fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: RecompTheme.glass,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: RecompTheme.line),
                        ),
                        child: Text(
                          game.type,
                          style: const TextStyle(color: RecompTheme.frost, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (game.turnipRecommended)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: RecompTheme.turnipGold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: RecompTheme.turnipGold),
                          ),
                          child: const Text(
                            '⚡ Turnip Rec.',
                            style: TextStyle(color: RecompTheme.turnipGold, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Title
                  Text(
                    game.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Maintained by ${game.author}',
                    style: const TextStyle(fontSize: 13, color: RecompTheme.muted),
                  ),

                  const SizedBox(height: 20),

                  // Installed / Launcher Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isInstalled ? RecompTheme.cyan.withOpacity(0.12) : RecompTheme.glass,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isInstalled ? RecompTheme.cyan : RecompTheme.line,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isInstalled ? Icons.check_circle : Icons.sports_esports,
                              color: isInstalled ? RecompTheme.cyan : RecompTheme.muted,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isInstalled ? 'Installed on This Device' : 'Not marked as installed',
                                style: TextStyle(
                                  color: isInstalled ? RecompTheme.cyan : RecompTheme.muted,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: onToggleInstalled,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                              ),
                              child: Text(
                                isInstalled ? 'Remove' : '+ Mark Installed',
                                style: TextStyle(
                                  color: isInstalled ? Colors.redAccent : RecompTheme.cyan,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isInstalled) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: RecompTheme.cyan,
                                foregroundColor: RecompTheme.midnight,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.play_arrow, size: 22),
                              label: const Text(
                                '▶ LAUNCH GAME',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
                              ),
                              onPressed: onLaunchGame,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons (APK & Obtainium)
                  Row(
                    children: [
                      if (game.apkUrl.isNotEmpty)
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: RecompTheme.cyan,
                              foregroundColor: RecompTheme.midnight,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            onPressed: () => launchUrl(Uri.parse(game.apkUrl), mode: LaunchMode.externalApplication),
                            icon: const Icon(Icons.download, size: 18),
                            label: const Text('Download APK', style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ),
                      const SizedBox(width: 10),
                      if (game.obtainiumUrl.isNotEmpty)
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: RecompTheme.btnSoftText(context),
                              backgroundColor: RecompTheme.btnSoftBg(context),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: RecompTheme.primary(context).withOpacity(0.35)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            onPressed: () => launchUrl(Uri.parse(game.obtainiumUrl), mode: LaunchMode.externalApplication),
                            icon: Icon(Icons.sync, size: 18, color: RecompTheme.primary(context)),
                            label: const Text('Add to Obtainium', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Overview / Blurb
                  const Text('Overview', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    game.blurb,
                    style: const TextStyle(fontSize: 14, color: RecompTheme.muted, height: 1.5),
                  ),

                  const SizedBox(height: 24),

                  // Features List
                  const Text('Key Enhancements', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  ...game.features.map(
                    (f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: RecompTheme.cyan, size: 18),
                          const SizedBox(width: 10),
                          Expanded(child: Text(f, style: const TextStyle(fontSize: 13, color: RecompTheme.frost))),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Required Assets Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: RecompTheme.glass,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: RecompTheme.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Required Original Files:',
                          style: TextStyle(color: RecompTheme.cyan, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(game.needs, style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Technical Facts Table
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: RecompTheme.midnightAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: RecompTheme.line),
                    ),
                    child: Column(
                      children: [
                        _buildFactRow('Target System', game.originFormatted),
                        _buildFactRow('Port Architecture', game.type),
                        _buildFactRow('Min Android', game.minAndroid),
                        _buildFactRow('Input Scheme', game.touchSupported ? 'Touch + Physical Gamepad' : 'Physical Gamepad Only'),
                        _buildFactRow('Graphics Renderer', game.graphicsBackend),
                        _buildFactRow('Target Framerate', '${game.fpsTarget} FPS'),
                        _buildFactRow('Version', game.version),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: const TextStyle(color: RecompTheme.muted, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

// ============================================================================
// SEARCH DELEGATE
// ============================================================================
class GameSearchDelegate extends SearchDelegate<RecompGame?> {
  final List<RecompGame> games;
  final Function(RecompGame) onSelect;

  GameSearchDelegate({required this.games, required this.onSelect});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: RecompTheme.midnight,
      appBarTheme: const AppBarTheme(
        backgroundColor: RecompTheme.midnightAlt,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: RecompTheme.muted),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final q = query.trim().toLowerCase();
    final results = q.isEmpty
        ? []
        : games.where((g) {
            return g.name.toLowerCase().contains(q) ||
                g.game.toLowerCase().contains(q) ||
                g.origin.toLowerCase().contains(q) ||
                g.author.toLowerCase().contains(q);
          }).toList();

    if (q.isEmpty) {
      return const Center(child: Text('Search 133+ Android recompilations...', style: TextStyle(color: RecompTheme.muted)));
    }

    if (results.isEmpty) {
      return Center(child: Text('No results for "$query"', style: const TextStyle(color: RecompTheme.muted)));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, idx) {
        final g = results[idx] as RecompGame;
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(g.cover, width: 40, height: 55, fit: BoxFit.cover, headers: const {'User-Agent': 'Mozilla/5.0 (Linux; Android 14)'}),
          ),
          title: Text(g.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('${g.originFormatted} • ${g.type}'),
          onTap: () {
            close(context, g);
            onSelect(g);
          },
        );
      },
    );
  }
}
