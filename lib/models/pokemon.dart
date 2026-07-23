class Pokemon {
  final String id;
  final String name;
  final String type;
  final List<String> types;
  final String imagenUrl;

  const Pokemon({
    required this.id,
    required this.name,
    required this.type,
    this.types = const [],
    required this.imagenUrl,
  });

  factory Pokemon.fromListItem(Map<String, dynamic> json) {
    final segments = Uri.parse(json['url'] as String).pathSegments;
    final id = segments[segments.length - 2];
    final name = json['name'] as String;
    return Pokemon(
      id: id,
      name: name[0].toUpperCase() + name.substring(1),
      type: '',
      imagenUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
    );
  }
}

class PokemonStat {
  final String name;
  final int value;

  const PokemonStat({required this.name, required this.value});
}

class PokemonAbility {
  final String name;
  final bool isHidden;

  const PokemonAbility({required this.name, required this.isHidden});
}

class EvolutionStep {
  final String id;
  final String name;
  final String imageUrl;

  const EvolutionStep({required this.id, required this.name, required this.imageUrl});
}

class PokemonDetail extends Pokemon {
  final String? shinyUrl;
  final double height;
  final double weight;
  final int? baseExperience;
  final List<PokemonStat> stats;
  final List<PokemonAbility> abilities;
  final String? speciesUrl;

  const PokemonDetail({
    required super.id,
    required super.name,
    required super.type,
    super.types,
    required super.imagenUrl,
    this.shinyUrl,
    required this.height,
    required this.weight,
    this.baseExperience,
    this.stats = const [],
    this.abilities = const [],
    this.speciesUrl,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final typesList = (json['types'] as List).map<String>((t) => t['type']['name'] as String).toList();
    return PokemonDetail(
      id: json['id'].toString(),
      name: name[0].toUpperCase() + name.substring(1),
      type: typesList.first,
      types: typesList,
      imagenUrl: json['sprites']['other']['official-artwork']['front_default'] ?? '',
      shinyUrl: json['sprites']['other']['official-artwork']['front_shiny'],
      height: (json['height'] as int) / 10,
      weight: (json['weight'] as int) / 10,
      baseExperience: json['base_experience'],
      stats: (json['stats'] as List)
          .map((s) => PokemonStat(name: s['stat']['name'], value: s['base_stat']))
          .toList(),
      abilities: (json['abilities'] as List)
          .map((a) => PokemonAbility(name: a['ability']['name'], isHidden: a['is_hidden']))
          .toList(),
      speciesUrl: json['species']?['url'] as String?,
    );
  }
}
