import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'error_view.dart';

class CryButton extends StatefulWidget {
  final String pokemonId;
  final Color typeColor;

  const CryButton({
    super.key,
    required this.pokemonId,
    required this.typeColor,
  });

  @override
  State<CryButton> createState() => _CryButtonState();
}

class _CryButtonState extends State<CryButton> {
  late final AudioPlayer _player;
  bool _playing = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final url =
          'https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/${widget.pokemonId}.ogg';
      await _player.setUrl(url).timeout(const Duration(seconds: 5));
      if (mounted) setState(() => _loaded = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playCry(BuildContext context) async {
    if (_playing) return;
    setState(() => _playing = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (!_loaded) {
        await _initPlayer();
        if (!_loaded) throw Exception('No se pudo cargar el audio.');
      }
      await _player.seek(Duration.zero);
      await _player.play();
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(friendlyErrorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _playing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _playCry(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _playing
              ? widget.typeColor.withValues(alpha: 0.85)
              : Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _playing ? Icons.volume_up : Icons.volume_up_outlined,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            const Text(
              'Cry',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
