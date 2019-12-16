library sdl_dart.parser;
import 'package:petitparser/petitparser.dart';
import 'package:fixnum/fixnum.dart';

import 'grammar.dart';

/// SDLang parser
class SDLangParser extends GrammarParser {
  SDLangParser() : super(const SDLangParserDefinition());
}

/// SDLang parser definition
class SDLangParserDefinition extends SDLangGrammarDefinition {
  const SDLangParserDefinition();

  Parser document() => super.document().trim();

  Parser namespace() => super.namespace().map((each) {
    return [each[0], each[2]];
  });

  Parser object() => super.object().map((each) {
    return []..add(each[1]);
  });

  Parser section() => super.section().map((each) {
    return []..add(each[0])..add(each[2]);
  });

  Parser id() => ref(l_id).trim();

  Parser attribute() => super.attribute().map((each) {
    return {'${each[0]}' : each[2]};
  });

  Parser value() => super.value().map((each) => [each]);

  Parser node() => super.node().map((each) {
    return each.fold([], (a, e) {
      if (e != ' ') {
        a.add(e);
      }
      return a;
    });
  });

  Parser stringToken() => ref(l_string).trim();
  Parser numberToken() => super.numberToken().map((each) {
    final len = each.length;
    final special = each[len-1] == 'L' || each[len-1] == 'f';
    final floating = double.parse(special ? each.substring(0, len-1) : each);
    final integral = floating.toInt();
    if (floating == integral && each.indexOf('.') == -1) {
      if (each.indexOf('L') == -1) {
        return Int32(integral);
      } else {
        return Int64(integral);
      }
    } else {
      return floating;
    }
  });
  Parser l_id() => super.l_id().flatten();
  Parser l_string() => super.l_string().map((e) => e[1].join());
}