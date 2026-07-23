# 🎮 Pokédex Flutter

Una Pokédex mobile-first construida con Flutter, consumiendo la [PokéAPI](https://pokeapi.co/) pública.

---

## ✨ Funcionalidades

| Feature | Descripción |
|---|---|
| 📋 Listado | Grid de pokémons con carga paginada (infinite scroll) |
| 🔍 Búsqueda | Filtro en tiempo real por nombre |
| 📄 Detalle | Stats, habilidades, altura, peso y experiencia base |
| ✨ Shiny | Toggle para ver la versión shiny del pokémon |
| 🔗 Evoluciones | Cadena de evolución navegable desde el detalle |
| ❤️ Favoritos | Guardar y gestionar pokémons favoritos (persistente) |
| 🌙 Tema | Modo claro / oscuro con persistencia entre sesiones |

---

## 🏗️ Arquitectura

```
lib/
├── main.dart               # Entry point, estado global (tema + favoritos)
├── models/                 # Entidades: Pokemon, PokemonDetail, Stats, etc.
├── services/               # PokemonService — llamadas HTTP con Dio
├── router/                 # Navegación declarativa con go_router
├── screens/                # HomeScreen · DetailScreen · FavoritesScreen
├── widgets/                # Componentes reutilizables + InheritedWidgets
│   ├── theme_notifier.dart     # InheritedWidget para el tema
│   └── favorites_notifier.dart # InheritedWidget para favoritos
├── theme/                  # AppTheme (light / dark)
└── assets/                 # Iconos SVG por tipo de pokémon
```

El estado se maneja con **InheritedWidget** nativo — sin librerías externas de state management. Los favoritos se persisten con `shared_preferences`.

---

## 📦 Stack

- **Flutter** · **Dart**
- [`go_router`](https://pub.dev/packages/go_router) — navegación
- [`dio`](https://pub.dev/packages/dio) — cliente HTTP
- [`flutter_svg`](https://pub.dev/packages/flutter_svg) — iconos de tipo
- [`shared_preferences`](https://pub.dev/packages/shared_preferences) — persistencia local

---

## 🚀 Correr en local

**Requisitos:** Flutter SDK ≥ 3.12 · Dart SDK ≥ 3.12

```bash
# 1. Clonar el repo
git clone <repo-url>
cd pokedex-flutter

# 2. Instalar dependencias
flutter pub get

# 3. Correr en el dispositivo/emulador conectado
flutter run

# Plataformas soportadas
flutter run -d android
flutter run -d ios
flutter run -d chrome     # web
flutter run -d macos
```

> No requiere configuración de API keys ni variables de entorno. La PokéAPI es pública y gratuita.
