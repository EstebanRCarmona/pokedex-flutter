import 'package:dio/dio.dart';
import 'package:pokedex_flutter/models/pokemon.dart';

class PokemonService {
  static const _baseUrl = 'https://pokeapi.co/api/v2';
  static const _pageSize = 20;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<Pokemon>> fetchPokemons({int offset = 0}) async {
    final res = await _dio.get(
      '/pokemon',
      queryParameters: {'limit': _pageSize, 'offset': offset},
    );
    final results = res.data['results'] as List;
    final basics = results
        .map((item) => Pokemon.fromListItem(item as Map<String, dynamic>))
        .toList();
    final details = await Future.wait(basics.map((p) => fetchPokemonDetail(p.id)));
    return details;
  }

  Future<PokemonDetail> fetchPokemonDetail(String id) async {
    final res = await _dio.get('/pokemon/$id');
    return PokemonDetail.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<EvolutionStep>> fetchEvolutionChain(String speciesUrl) async {
    final speciesRes = await _dio.get(speciesUrl);
    final chainUrl = speciesRes.data['evolution_chain']['url'] as String;
    final chainRes = await _dio.get(chainUrl);

    final steps = <EvolutionStep>[];
    _collectChain(chainRes.data['chain'], steps);
    return steps;
  }

  void _collectChain(Map<String, dynamic> node, List<EvolutionStep> steps) {
    final url = node['species']['url'] as String;
    final segments = Uri.parse(url).pathSegments;
    final id = segments[segments.length - 2];
    final name = node['species']['name'] as String;
    steps.add(EvolutionStep(
      id: id,
      name: name[0].toUpperCase() + name.substring(1),
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
    ));
    for (final next in node['evolves_to'] as List) {
      _collectChain(next as Map<String, dynamic>, steps);
    }
  }
}
