import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pokedex_flutter/models/pokemon.dart';
import 'package:pokedex_flutter/services/pokemon_service.dart';
import 'package:pokedex_flutter/widgets/error_view.dart';
import 'package:pokedex_flutter/widgets/pockemon_card.dart';
import 'package:pokedex_flutter/widgets/pokemon_card_skeleton.dart';
import 'package:pokedex_flutter/widgets/theme_toggle_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = PokemonService();
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  late Future<List<Pokemon>> _pokemonsFuture;
  List<Pokemon> _pokemons = [];
  bool _loadingMore = false;
  String _searchQuery = '';

  List<Pokemon> _searchResults = [];
  bool _searching = false;
  bool _searchNotFound = false;

  @override
  void initState() {
    super.initState();
    _pokemonsFuture = _loadFirstPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
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
    final nearBottom =
        _scrollController.position.pixels >=
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

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    setState(() {
      _searchQuery = value;
      _searchNotFound = false;
    });

    if (value.length < 3) {
      setState(() {
        _searchResults = [];
        _searching = false;
      });
      return;
    }

    final localMatch = _pokemons
        .where((p) => p.name.toLowerCase().contains(value.toLowerCase()))
        .toList();

    setState(() => _searchResults = localMatch);

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _searchByApi(value),
    );
  }

  Future<void> _searchByApi(String query) async {
    setState(() => _searching = true);
    try {
      final result = await _service.searchPokemon(query);
      if (!mounted) return;
      if (result == null) {
        setState(() {
          _searchNotFound = _searchResults.isEmpty;
          _searching = false;
        });
      } else {
        final alreadyIn = _searchResults.any((p) => p.id == result.id);
        setState(() {
          if (!alreadyIn) _searchResults = [result, ..._searchResults];
          _searching = false;
          _searchNotFound = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pokédex',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1),
        ),
        actions: const [ThemeToggleButton()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar Pokémon',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Pokemon>>(
              future: _pokemonsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
    if (_searchQuery.length >= 3) {
      if (_searching && _searchResults.isEmpty) {
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.82,
          ),
          itemCount: 2,
          itemBuilder: (_, _) => const PokemonCardSkeleton(),
        );
      }
      if (_searchNotFound) {
        return const Center(child: Text('No se encontró ningún pokémon'));
      }
      return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.82,
        ),
        itemCount: _searchResults.length + (_searching ? 1 : 0),
        itemBuilder: (_, i) {
          if (i >= _searchResults.length) return const PokemonCardSkeleton();
          return PokemonCard(pokemon: _searchResults[i]);
        },
      );
    }

    final filtered = _searchQuery.isEmpty
        ? _pokemons
        : _pokemons
              .where(
                (p) =>
                    p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
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
