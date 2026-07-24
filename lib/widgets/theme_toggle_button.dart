import 'package:flutter/material.dart';
import 'package:pokedex_flutter/widgets/theme_notifier.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = ThemeNotifier.of(context);
    return IconButton(
      icon: Icon(notifier.isDark ? Icons.light_mode : Icons.dark_mode),
      onPressed: notifier.toggle,
    );
  }
}
