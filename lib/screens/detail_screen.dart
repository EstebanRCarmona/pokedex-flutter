import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../widgets/error_view.dart';
import '../widgets/favorites_notifier.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/type_icon.dart';

class DetailScreen extends StatefulWidget {
  final String id;

  const DetailScreen({super.key, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _service = PokemonService();
  late Future<PokemonDetail> _detailFuture;
  Future<List<EvolutionStep>>? _evolutionFuture;
  bool _showShiny = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = _service.fetchPokemonDetail(widget.id).then((detail) {
      if (detail.speciesUrl != null) {
        setState(() {
          _evolutionFuture = _service.fetchEvolutionChain(detail.speciesUrl!);
        });
      }
      return detail;
    });
  }

  void _retry() {
    setState(() {
      _evolutionFuture = null;
      _detailFuture = _service.fetchPokemonDetail(widget.id).then((detail) {
        if (detail.speciesUrl != null) {
          setState(() {
            _evolutionFuture = _service.fetchEvolutionChain(detail.speciesUrl!);
          });
        }
        return detail;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          FutureBuilder<PokemonDetail>(
            future: _detailFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              return _DetailFavoriteButton(pokemonId: snapshot.data!.id);
            },
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: FutureBuilder<PokemonDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorView(error: snapshot.error, onRetry: _retry);
          }
          return _buildContent(context, snapshot.data!);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PokemonDetail pokemon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = TypeIcon.colorFor(pokemon.type);
    final imageUrl = _showShiny && pokemon.shinyUrl != null
        ? pokemon.shinyUrl!
        : pokemon.imagenUrl;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailHeader(
            pokemon: pokemon,
            imageUrl: imageUrl,
            typeColor: typeColor,
            isDark: isDark,
            onToggleShiny: () => setState(() => _showShiny = !_showShiny),
            showShiny: _showShiny,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailInfoRow(
                  pokemon: pokemon,
                  typeColor: typeColor,
                  isDark: isDark,
                ),
                const SizedBox(height: 24),
                if (pokemon.stats.isNotEmpty) ...[
                  const _SectionTitle(title: 'Stats base'),
                  const SizedBox(height: 12),
                  ...pokemon.stats.map(
                    (s) => _StatBar(stat: s, typeColor: typeColor),
                  ),
                ],
                const SizedBox(height: 24),
                if (pokemon.abilities.isNotEmpty) ...[
                  const _SectionTitle(title: 'Habilidades'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: pokemon.abilities
                        .map(
                          (a) => _AbilityChip(
                            ability: a,
                            typeColor: typeColor,
                            isDark: isDark,
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 24),
                if (_evolutionFuture != null) ...[
                  const _SectionTitle(title: 'Evoluciones'),
                  const SizedBox(height: 12),
                  _EvolutionChain(
                    future: _evolutionFuture!,
                    currentId: widget.id,
                    typeColor: typeColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailFavoriteButton extends StatelessWidget {
  final String pokemonId;

  const _DetailFavoriteButton({required this.pokemonId});

  @override
  Widget build(BuildContext context) {
    final favNotifier = FavoritesNotifier.of(context);
    final isFav = favNotifier.isFavorite(pokemonId);
    return IconButton(
      icon: Icon(
        isFav ? Icons.favorite : Icons.favorite_border,
        color: isFav ? Colors.redAccent : null,
      ),
      onPressed: () => favNotifier.toggleFavorite(pokemonId),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final PokemonDetail pokemon;
  final String imageUrl;
  final Color typeColor;
  final bool isDark;
  final bool showShiny;
  final VoidCallback onToggleShiny;

  const _DetailHeader({
    required this.pokemon,
    required this.imageUrl,
    required this.typeColor,
    required this.isDark,
    required this.showShiny,
    required this.onToggleShiny,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            typeColor.withValues(alpha: isDark ? 0.35 : 0.2),
            Colors.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Hero(
            tag: 'pokemon-${pokemon.id}',
            child: Image.network(
              imageUrl,
              height: 220,
              width: 220,
              fit: BoxFit.contain,
              errorBuilder: (_, e, st) =>
                  const Icon(Icons.catching_pokemon, size: 120),
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const SizedBox(
                      height: 220,
                      width: 220,
                      child: Center(child: CircularProgressIndicator()),
                    ),
            ),
          ),
          if (pokemon.shinyUrl != null)
            Positioned(
              top: 0,
              right: 16,
              child: GestureDetector(
                onTap: onToggleShiny,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: showShiny
                        ? Colors.amber.withValues(alpha: 0.9)
                        : Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: showShiny ? Colors.black : Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Shiny',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: showShiny ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final Widget child;
  final Color typeColor;
  final bool isDark;

  const _InfoChip({
    required this.child,
    required this.typeColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: typeColor.withValues(alpha: 0.3)),
      ),
      child: Center(child: child),
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  final PokemonDetail pokemon;
  final Color typeColor;
  final bool isDark;

  const _DetailInfoRow({
    required this.pokemon,
    required this.typeColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final types = pokemon.types;
    return Row(
      children: [
        Expanded(
          child: _InfoChip(
            typeColor: typeColor,
            isDark: isDark,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TypeIcon(type: pokemon.type, size: 20),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  alignment: WrapAlignment.center,
                  children: types
                      .map(
                        (t) => Text(
                          t.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: TypeIcon.colorFor(t),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _InfoChip(
            typeColor: typeColor,
            isDark: isDark,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${pokemon.height.toStringAsFixed(1)} m',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text('Altura', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _InfoChip(
            typeColor: typeColor,
            isDark: isDark,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${pokemon.weight.toStringAsFixed(1)} kg',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text('Peso', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        ),
        if (pokemon.baseExperience != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _InfoChip(
              typeColor: typeColor,
              isDark: isDark,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${pokemon.baseExperience}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Exp base',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _StatBar extends StatelessWidget {
  final PokemonStat stat;
  final Color typeColor;

  const _StatBar({required this.stat, required this.typeColor});

  static const _names = {
    'hp': 'HP',
    'attack': 'Ataque',
    'defense': 'Defensa',
    'special-attack': 'Sp. Ataque',
    'special-defense': 'Sp. Defensa',
    'speed': 'Velocidad',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              _names[stat.name] ?? stat.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${stat.value}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: typeColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: stat.value / 255.0,
                minHeight: 8,
                backgroundColor: typeColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(typeColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AbilityChip extends StatelessWidget {
  final PokemonAbility ability;
  final Color typeColor;
  final bool isDark;

  const _AbilityChip({
    required this.ability,
    required this.typeColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: typeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ability.isHidden) ...[
            Icon(
              Icons.visibility_off,
              size: 14,
              color: typeColor.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            ability.name[0].toUpperCase() + ability.name.substring(1),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: ability.isHidden
                  ? typeColor.withValues(alpha: 0.7)
                  : theme.colorScheme.onSurface,
            ),
          ),
          if (ability.isHidden) ...[
            const SizedBox(width: 4),
            Text(
              '(oculta)',
              style: theme.textTheme.labelSmall?.copyWith(
                color: typeColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EvolutionChain extends StatelessWidget {
  final Future<List<EvolutionStep>> future;
  final String currentId;
  final Color typeColor;
  final bool isDark;

  const _EvolutionChain({
    required this.future,
    required this.currentId,
    required this.typeColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EvolutionStep>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: typeColor));
        }
        if (!snapshot.hasData || snapshot.data!.length <= 1) {
          return Text(
            'No tiene evoluciones.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          );
        }
        final steps = snapshot.data!;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                _EvolutionItem(
                  step: steps[i],
                  currentId: currentId,
                  typeColor: typeColor,
                  isDark: isDark,
                ),
                if (i < steps.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: typeColor.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _EvolutionItem extends StatelessWidget {
  final EvolutionStep step;
  final String currentId;
  final Color typeColor;
  final bool isDark;

  const _EvolutionItem({
    required this.step,
    required this.currentId,
    required this.typeColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = step.id == currentId;
    return GestureDetector(
      onTap: isCurrent
          ? null
          : () => context.pushReplacementNamed(
              'details',
              pathParameters: {'id': step.id},
            ),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isCurrent
              ? typeColor.withValues(alpha: isDark ? 0.25 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isCurrent
              ? Border.all(color: typeColor.withValues(alpha: 0.5))
              : null,
        ),
        child: Column(
          children: [
            Image.network(
              step.imageUrl,
              height: 64,
              width: 64,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 4),
            Text(
              step.name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                color: isCurrent
                    ? typeColor
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
