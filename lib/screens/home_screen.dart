import 'package:flutter/material.dart';
import 'package:pokedex_flutter/models/pokemon.dart';
import 'package:pokedex_flutter/services/pokemon_service.dart';
import 'package:pokedex_flutter/widgets/error_view.dart';
import 'package:pokedex_flutter/widgets/pockemon_card.dart';
import 'package:pokedex_flutter/widgets/pokemon_card_skeleton.dart';
import 'package:pokedex_flutter/widgets/theme_notifier.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = PokemonService();
  final _scrollController = ScrollController();

  late Future<List<Pokemon>> _pokemonsFuture;
  List<Pokemon> _pokemons = [];
  bool _loadingMore = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _pokemonsFuture = _loadFirstPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Pokemon>> _loadFirstPage() async {
    final data = await _service.fetchPokemons();
    _pokemons = data;
    return data;
  }

  void _retry() {
    setState(() => _pokemonsFuture = _loadFirstPage());
  }

  void _onScroll() {
    final nearBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300;
    if (nearBottom && !_loadingMore && _searchQuery.isEmpty) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final more = await _service.fetchPokemons(offset: _pokemons.length);
      setState(() {
        _pokemons = [..._pokemons, ...more];
        _loadingMore = false;
      });
    } catch (_) {
      setState(() => _loadingMore = false);
    }
  }

  void _filterPokemons(String value) {
    setState(() => _searchQuery = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pokédex',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => ThemeNotifier.of(context).toggle(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar Pokémon',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: _filterPokemons,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Pokemon>>(
              future: _pokemonsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: 6,
                    itemBuilder: (_, _) => const PokemonCardSkeleton(),
                  );
                }
                if (snapshot.hasError) {
                  return ErrorView(error: snapshot.error, onRetry: _retry);
                }
                return _buildList();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    final filtered = _searchQuery.isEmpty
        ? _pokemons
        : _pokemons
            .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No se encontraron pokémons'));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
      ),
      itemCount: filtered.length + (_loadingMore ? 2 : 0),
      itemBuilder: (_, i) {
        if (i >= filtered.length) return const PokemonCardSkeleton();
        return PokemonCard(pokemon: filtered[i]);
      },
    );
  }
}
