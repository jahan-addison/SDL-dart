# SDLang-Dart [![Build Status](https://travis-ci.org/jahan-addison/SDL-dart.svg?branch=master)](https://travis-ci.org/jahan-addison/SDL-dart)
Simple Declarative Language ([SDL](https://sdlang.org/)) for Dart

> SDLang is a simple and concise way to textually represent data. It has an XML-like structure – tags, values and attributes – which makes it a versatile choice for data serialization, configuration files, or declarative languages. Its syntax was inspired by the C family of languages (C/C++, C#, D, Java, …).

#### Details

`sdl-dart` is built with highly-efficient parser combinators - easy to read, very fluid, and LL(infinity).


## How to use

```dart
import 'package:sdl_dart/sdl_dart.dart';

void main() {
    // ...

    final sdl = new SDLangParser();
    final result = sdl.parse(source);

    print(result.value);
}
```

## Example

```
    // This is a node with a single string value
    title "Hello, World"

    // Multiple values are supported, too
    bookmarks 12 15 188 1234

    // Nodes can have attributes
    author "Peter Parker" email="peter@example.org" active=true

    // Nodes can be arbitrarily nested
    contents {
        section "First section" {
            paragraph "This is the first paragraph"
            paragraph "This is the second paragraph"
        }
    }

    // Anonymous nodes are supported
    "This text is the value of an anonymous node!"

    // This makes things like matrix definitions very convenient
    matrix {
        1 0 0
        0 1 0
        0 0 1
    }
```

Produces [this metadata tree](https://gist.github.com/jahan-addison/894832429b583d23f4f07203faf630c5).

## Not implemented

    * 128 bit decimal
    * utf8 support

## License
Apache License 2.0.
