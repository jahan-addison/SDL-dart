# SDLang-Dart
Simple Declarative Language ([SDL](https://sdlang.org/)) for Dart

> SDLang is a simple and concise way to textually represent data. It has an XML-like structure – tags, values and attributes – which makes it a versatile choice for data serialization, configuration files, or declarative languages. Its syntax was inspired by the C family of languages (C/C++, C#, D, Java, …).

## Example usage

```dart
final sdl = new SDLangParser();
final result = sdl.parse(source);

print(result.value);
```

Not implemented:

    * 128 bit decimal
    * utf8 support

## License
Apache License 2.0.
