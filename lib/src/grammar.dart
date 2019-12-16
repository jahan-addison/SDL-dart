library sdl_dart.grammar;

import 'package:petitparser/petitparser.dart';

/// SDLang Grammar
class SDLangGrammar extends GrammarParser {
  SDLangGrammar() : super(const SDLangGrammarDefinition());
}

/// SDLang grammar definition
class SDLangGrammarDefinition extends GrammarDefinition {
  const SDLangGrammarDefinition();

  Parser start() => ref(document).end();

  Parser token(Object source, [String name]) {
    Parser parser;
    String expected;
    if (source is String) {
      if (source.length == 1) {
        parser = char(source);
      } else {
        parser = string(source);
      }
      expected = name ?? source;
    } else if (source is Parser) {
      parser = source;
      expected = name;
    } else {
      throw ArgumentError('Unknown token type: $source.');
    }
    if (expected == null) {
      throw ArgumentError('Missing token name: $source');
    }
    return parser.flatten(expected).trim();
  }

  Parser document() => (((ref(value)
    | ref(object)
    | ref(space)
    | ref(sections)).plus())
      .separatedBy(ref(l_eol).star()))
      .trim(ref(space));

  Parser sections() => ref(section).plus();

  Parser section() => ref(name)
    & l_space().star()
    & ( ref(object)
      | ref(space)
      | (ref(node)));

  Parser object() => ref(token, '{')
    & (ref(sections)
      | ref(value).star())
    & ref(token, '}');

  Parser node() => ((ref(value)
    | ref(attribute)
    | ref(space)
    | ref(object)).plus()).separatedBy(ref(l_space) | ref(token, ';'));

  Parser attribute() => ref(l_id) & ref(token, '=') & ref(value);

  Parser namespace() => ref(l_id) & ref(token, ':') & ref(l_id);

  Parser id() => ref(l_id, 'identifier');

  Parser name() => ref(namespace) | ref(id);

  Parser value() => (ref(stringToken)
      | ref(numberToken)
      | ref(primitiveToken))
        .trim(ref(space));

  Parser boolToken() => ref(token, ref(l_bool), 'boolean');
  Parser numberToken() => ref(token, ref(l_number), 'number');
  Parser stringToken() => ref(token, ref(l_string), 'string');
  Parser nullToken() => ref(token, string('null'), 'null');
  Parser switchToken() => ref(token, ref(l_switch), 'switch');
  Parser primitiveToken() => ref(boolToken)
    | ref(switchToken)
    | ref(nullToken);

  Parser l_bool() => ref(token, 'true') | ref(token, 'false');

  Parser l_switch() => ref(token, 'on') | ref(token, 'off');

  Parser l_number() => ref(l_64bit_float)
    | ref(l_64bit_int)
    | ref(l_32bit_int);

  Parser l_int() => ref(token, digit().plus(), 'integer');

  Parser l_32bit_int() => ref(token, ref(l_int), '32 bit integer');
  Parser l_64bit_int() => ref(token, ref(l_int) & char('L'), '64 bit integer');

  // Interpret all floats as 64bit due to https://github.com/dart-lang/sdk/issues/9064
  Parser l_64bit_float() => ref(token,
    ((digit().plus()
      & (char('.')
      & digit().plus())
      )
    & char('f').optional()), '64bit double precision');

  Parser space() => ref(l_comments).flatten();

  Parser l_comments() => (string('//') & Token.newlineParser().neg().star())
     | (string('--') & Token.newlineParser().neg().star())
     | (char('#') & Token.newlineParser().neg().star());

  Parser l_string() => ref(l_string_1)
    | ref(l_string_2);

  Parser l_space() => char(' ')
    | char('\t');


  Parser l_eol() => Token.newlineParser()
    | string(';');

  Parser l_id() => (letter()
    & (anyOf('_-.\$')
      | word()).star()
  );

  Parser l_special() => anyOf('!#\$%^&*()@-+=_{}[];:<>,.?/|');

  Parser l_char() => letter()
    | ref(l_special)
    | ref(l_space)
    | digit();

  Parser l_string_1() => (
      char('"')
        & (ref(l_char)
          | string('\\"')).star()
      & char('"')
    );

  Parser l_string_2() => (
    char("'")
      & (ref(l_char) | char('"')).star()
    & char("'")
    );

}
