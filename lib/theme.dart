import 'package:flutter/material.dart';

/// Palette pulled from the Zyvro logo: electric cyan into deep cobalt on black.
class Zy {
  static const bg = Color(0xFF04060A);
  static const surface = Color(0xFF0C121B);
  static const surfaceHi = Color(0xFF141C29);
  static const cyan = Color(0xFF00CFFF);
  static const blue = Color(0xFF2B63FF);
  static const text = Color(0xFFF2F6FB);
  static const muted = Color(0xFF8593A8);
  static const danger = Color(0xFFFF5C72);
  static const ok = Color(0xFF3DE0A0);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyan, blue],
  );

  static BoxDecoration card({Color? border}) => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border ?? Colors.white.withAlpha(18)),
      );
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Zy.cyan,
      secondary: Zy.blue,
      surface: Zy.surface,
      error: Zy.danger,
    ),
    scaffoldBackgroundColor: Zy.bg,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: Zy.text, displayColor: Zy.text),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        foregroundColor: Zy.text,
        side: BorderSide(color: Colors.white.withAlpha(36)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
