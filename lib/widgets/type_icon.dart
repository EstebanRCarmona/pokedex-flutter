import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TypeIcon extends StatelessWidget {
  final String type;
  final double size;

  const TypeIcon({super.key, required this.type, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _assetFor(type),
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(colorFor(type), BlendMode.srcIn),
    );
  }

  static String _assetFor(String type) {
    const map = {
      // inglés (PokeAPI)
      'fire': 'lib/assets/fire.svg',
      'water': 'lib/assets/water.svg',
      'grass': 'lib/assets/grass.svg',
      'electric': 'lib/assets/electric.svg',
      'psychic': 'lib/assets/psychic.svg',
      'ice': 'lib/assets/ice.svg',
      'fighting': 'lib/assets/fighting.svg',
      'poison': 'lib/assets/poison.svg',
      'ground': 'lib/assets/ground.svg',
      'flying': 'lib/assets/flying.svg',
      'bug': 'lib/assets/bug.svg',
      'rock': 'lib/assets/rock.svg',
      'ghost': 'lib/assets/ghost.svg',
      'dragon': 'lib/assets/dragon.svg',
      'dark': 'lib/assets/dark.svg',
      'steel': 'lib/assets/steel.svg',
      'fairy': 'lib/assets/fairy.svg',
      'normal': 'lib/assets/normal.svg',
      // español (datos locales)
      'fuego': 'lib/assets/fire.svg',
      'agua': 'lib/assets/water.svg',
      'planta': 'lib/assets/grass.svg',
      'eléctrico': 'lib/assets/electric.svg',
      'electrico': 'lib/assets/electric.svg',
      'psíquico': 'lib/assets/psychic.svg',
      'psiquico': 'lib/assets/psychic.svg',
      'hielo': 'lib/assets/ice.svg',
      'lucha': 'lib/assets/fighting.svg',
      'veneno': 'lib/assets/poison.svg',
      'tierra': 'lib/assets/ground.svg',
      'volador': 'lib/assets/flying.svg',
      'bicho': 'lib/assets/bug.svg',
      'roca': 'lib/assets/rock.svg',
      'fantasma': 'lib/assets/ghost.svg',
      'dragón': 'lib/assets/dragon.svg',
      'siniestro': 'lib/assets/dark.svg',
      'acero': 'lib/assets/steel.svg',
      'hada': 'lib/assets/fairy.svg',
    };
    return map[type.toLowerCase()] ?? 'lib/assets/normal.svg';
  }

  static Color colorFor(String type) {
    const map = {
      // inglés (PokeAPI)
      'fire': Color(0xFFFF6B35),
      'water': Color(0xFF4FC3F7),
      'grass': Color(0xFF66BB6A),
      'electric': Color(0xFFFFD600),
      'psychic': Color(0xFFEC407A),
      'ice': Color(0xFF80DEEA),
      'fighting': Color(0xFFEF5350),
      'poison': Color(0xFFAB47BC),
      'ground': Color(0xFFD4A574),
      'flying': Color(0xFF90CAF9),
      'bug': Color(0xFF9CCC65),
      'rock': Color(0xFFBCAAA4),
      'ghost': Color(0xFF7E57C2),
      'dragon': Color(0xFF5C6BC0),
      'dark': Color(0xFF546E7A),
      'steel': Color(0xFF90A4AE),
      'fairy': Color(0xFFF48FB1),
      'normal': Color(0xFF9E9E9E),
      // español (datos locales)
      'fuego': Color(0xFFFF6B35),
      'agua': Color(0xFF4FC3F7),
      'planta': Color(0xFF66BB6A),
      'eléctrico': Color(0xFFFFD600),
      'electrico': Color(0xFFFFD600),
      'psíquico': Color(0xFFEC407A),
      'psiquico': Color(0xFFEC407A),
      'hielo': Color(0xFF80DEEA),
      'lucha': Color(0xFFEF5350),
      'veneno': Color(0xFFAB47BC),
      'tierra': Color(0xFFD4A574),
      'volador': Color(0xFF90CAF9),
      'bicho': Color(0xFF9CCC65),
      'roca': Color(0xFFBCAAA4),
      'fantasma': Color(0xFF7E57C2),
      'dragón': Color(0xFF5C6BC0),
      'siniestro': Color(0xFF546E7A),
      'acero': Color(0xFF90A4AE),
      'hada': Color(0xFFF48FB1),
    };
    return map[type.toLowerCase()] ?? const Color(0xFF9E9E9E);
  }
}
