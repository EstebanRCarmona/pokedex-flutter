import 'package:flutter/material.dart';

class PokemonCardSkeleton extends StatefulWidget {
  const PokemonCardSkeleton({super.key});

  @override
  State<PokemonCardSkeleton> createState() => _PokemonCardSkeletonState();
}

class _PokemonCardSkeletonState extends State<PokemonCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.white : Colors.black;

    return AnimatedBuilder(
      animation: _animation,
      builder: (_, _) {
        final color = base.withValues(alpha: _animation.value * (isDark ? 0.12 : 0.07));
        return Card(
          margin: const EdgeInsets.all(6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _box(color, width: 36, height: 10),
                    _box(color, width: 18, height: 18, radius: 9),
                  ],
                ),
                const SizedBox(height: 10),
                _box(color, width: 80, height: 80, radius: 40),
                const SizedBox(height: 12),
                _box(color, width: 90, height: 12, radius: 6),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _box(color, width: 56, height: 20, radius: 10),
                    const SizedBox(width: 6),
                    _box(color, width: 56, height: 20, radius: 10),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _box(Color color,
      {required double width, required double height, double radius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
