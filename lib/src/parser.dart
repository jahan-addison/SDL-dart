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

  @override
  Parser document() => super.document().trim();

  @override
  Parser namespace() => super.namespace().map((each) {
        return [each[0], each[2]];
      });

  @override
  Parser object() => super.object().map((each) {
        return each[1];
      });

  @override
  Parser sections() => super.sections().map((each) {
        return each.length > 1 ? each : each[0];
      });

  @override
  Parser section() => super.section().map((each) {
        return []..add(each[0])..add(each[2][0] is List ? each[2][0] : each[2]);
      });

  @override
  Parser id() => ref(ID).trim();

  @override
  Parser attribute() => super.attribute().map((each) {
        return {'${each[0]}': each[2]};
      });

  @override
  Parser node() => super.node().map((each) {
        return each.fold([], (a, e) {
          if (e != ' ') {
            a.add(e);
          }
          return a;
        });
      });

  @override
  Parser string_() => ref(STRING).trim();

  @override
  Parser number_() => super.number_().map((each) {
        final len = each.length;
        final special = each[len - 1] == 'L' || each[len - 1] == 'f';
        final floating =
            double.parse(special ? each.substring(0, len - 1) : each);
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

  @override
  Parser datetime_() => super.datetime_().flatten();

  @override
  Parser ID() => super.ID().flatten();
  @override
  Parser DATE() => super.DATE().flatten();
  @override
  Parser BOOL() => super.BOOL().map((each) {
        return each == 'true' ? true : false;
      });

  @override
  Parser NULL() => super.NULL().map((each) => null);
  @override
  Parser TIME() => super.TIME().flatten();

  @override
  Parser BINARY() => super.BINARY().flatten().map((each) {
        return each.substring(1, each.length - 1);
      });

  @override
  Parser DURATION_1() => super.DURATION_1().flatten();
  @override
  Parser DURATION_2() => super.DURATION_2().flatten();
  @override
  Parser STRING() => super.STRING().map((e) => e[1].join());
}
