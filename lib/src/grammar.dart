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

  Parser document() => (ref(value)
      | ref(object)
      | ref(sections)
    ).plus()
      .trim(ref(space));

  Parser sections() =>
    ref(section).separatedBy(char(';'), includeSeparators: false)
      | ref(section).plus();

  Parser section() => ref(name)
    & space().star()
    & ( ref(object)
      | (ref(node)));

  Parser object() => ref(token, '{')
    & (ref(value).plus()
      | ref(sections).star())
    & ref(token, '}');

  Parser node() => ((ref(value)
    | ref(attribute)
    | ref(space)
    | ref(object)).plus())
      .separatedBy(ref(SPACE), includeSeparators: false);

  Parser attribute() => ref(ID) & ref(token, '=') & ref(value);
  Parser namespace() => ref(ID) & ref(token, ':') & ref(ID);
  Parser id() => ref(token, ID, 'identifier');
  Parser name() => ref(namespace) | ref(id);
  Parser value() => (ref(string_)
    | ref(datetime_)
    | ref(number_)
    | ref(primitive_))
      .trim(ref(space));

  Parser token(Object parser, [String message]) {
    if (parser is Parser) {
      return parser.flatten(message).trim(ref(space));
    } else if (parser is String) {
      return token(
        parser.length == 1 ? char(parser) : string(parser),
        message ?? '$parser expected',
      );
    } else {
      throw ArgumentError.value(parser, 'parser', 'Invalid parser type');
    }
  }

  Parser number_() => ref(token, ref(NUMBER), 'number')
    .map((each) {
      return RegExp(r"(\S+)").firstMatch(each)[0];
    });
  Parser string_() => ref(token, ref(STRING), 'string');
  Parser datetime_() => ref(token, ref(DATETIME)
    | ref(date_)
    | ref(time_), 'datetime');
  Parser date_() => ref(token, ref(DATE), 'date');
  Parser time_() => ref(token, ref(DURATION_1)
    | ref(DURATION_2)
    | ref(TIME), 'time');
  Parser primitive_() => ref(BOOL)
    | ref(SWITCH)
    | ref(NULL)
    | ref(BINARY);

  Parser BOOL() => ref(token, 'true') | ref(token, 'false');

  Parser SWITCH() => ref(token, 'on') | ref(token, 'off');

  Parser NUMBER() => ref(I64BIT_FLOAT)
    | ref(I64BIT_INT)
    | ref(I32BIT_INT);

  Parser NULL() => ref(token, string('null'), 'null');

  Parser INT() => ref(token, digit().plus(), 'integer');

  Parser I32BIT_INT() => ref(token, ref(INT), '32 bit integer');
  Parser I64BIT_INT() => ref(token, ref(INT) & char('L'), '64 bit integer');

  // Interpret all floats as i64bit due to https://github.com/dart-lang/sdk/issues/i9064
  Parser I64BIT_FLOAT() => ref(token,
    ((digit().plus()
      & (char('.')
      & digit().plus())
      )
    & char('f').optional()), '64bit double precision');

  Parser space() => whitespace() | ref(COMMENTS);

  Parser COMMENTS() =>
    (string('/*') & any().starLazy(string('*/')) & string('*/'))
      | (string('//') & Token.newlineParser().neg().star())
      | (string('--') & Token.newlineParser().neg().star())
      | (char('#') & Token.newlineParser().neg().star());

  Parser STRING() => ref(STRING_1)
    | ref(STRING_2)
    | ref(STRING_3);

  Parser EOL() => Token.newlineParser()
    | string(';');

  Parser ID() => (letter()
    & (anyOf('_-.\$')
      | word()).star()
  );

  Parser DATETIME() => ref(DATE)
    & char(' ')
    & ref(DURATION_1)
    & string('-UTC').optional();

  Parser DATE() => digit().times(4)
    & char('/')
    & digit().times(2)
    & char('/')
    & digit().times(2);

  Parser TIME() => digit().times(2)
    & char(':')
    & digit().times(2)
    & char(':')
    & digit().times(2);

  Parser DURATION_1() => digit().times(2)
    & char(':')
    & digit().times(2)
    & char(':')
    & digit().times(2)
    & char('.')
    & digit().times(3);

  Parser DURATION_2() => digit().times(1)
    & char('d')
    & char(':')
    & digit().times(2)
    & char(':')
    & digit().times(2)
    & char(':')
    & digit().times(2);

  Parser BINARY() => char('[')
    & pattern('A-Za-z0-9+/=-').plus()
    & char(']');

  Parser SPECIAL() => anyOf('!#\$%^&*()@-+=_{}[];:<>,.?/|');

  Parser SPACE() => char(' ')
    | char('\t');

  Parser CHAR() => letter()
    | ref(SPECIAL)
    | ref(SPACE)
    | digit();

  Parser STRING_1() => (
      char('"')
        & (ref(CHAR)
          | string('\\"')).star()
      & char('"')
    );

  Parser STRING_2() => (
    char("'")
      & (ref(CHAR)
        | char('"')).star()
    & char("'")
    );

  Parser STRING_3() => (
    char("`")
      & (ref(CHAR)
        | char('"')
        | char("'")).star()
    & char("`")
    );
}
