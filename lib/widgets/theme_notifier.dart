import 'package:flutter/material.dart';

class ThemeNotifier extends InheritedWidget {
  final bool isDark;
  final VoidCallback toggle;

  const ThemeNotifier({
    super.key,
    required this.isDark,
    required this.toggle,
    required super.child,
  });

  static ThemeNotifier of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeNotifier>()!;

  @override
  bool updateShouldNotify(ThemeNotifier oldWidget) => isDark != oldWidget.isDark;
}
