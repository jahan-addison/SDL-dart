library sdl_dart;
/// This package contains an implementation of [SDLang](https://sdlang.org/).
///
/// [SDLangParser] creates nested Dart objects from a given source string. For
/// example:
///     final sdl = new SDLangParser();
///     final result = sdl.parse(source);
///     print(result.value);
export 'src/grammar.dart';
export 'src/parser.dart';
