import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ble_controller.dart';
import 'screens/finder_screen.dart';
import 'screens/scan_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Zy.bg,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const ZipwatchApp());
}

class ZipwatchApp extends StatefulWidget {
  const ZipwatchApp({super.key});

  @override
  State<ZipwatchApp> createState() => _ZipwatchAppState();
}

class _ZipwatchAppState extends State<ZipwatchApp> {
  final BleController ctrl = BleController();

  @override
  void initState() {
    super.initState();
    ctrl.init();
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zyvro',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: ListenableBuilder(
        listenable: ctrl,
        builder: (context, _) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          child: ctrl.link == LinkState.connected
              ? FinderScreen(key: const ValueKey('finder'), c: ctrl)
              : ScanScreen(key: const ValueKey('scan'), c: ctrl),
        ),
      ),
    );
  }
}
