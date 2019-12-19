library sdl_dart.test.all_test;

import 'package:test/test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:sdl_dart/src/parser.dart';

void main() {
  final parser = new SDLangParser();
  group('Parser', () {
    group('Primitive', () {
      test('bool', () {
        expect(parser.parse('true false').value,
          [true, false]);
      });
      test('switch', () {
        expect(parser.parse('off on').value,
          ['off', 'on']);
      });
      test('null', () {
        expect(parser.parse('null').value, [null]);
      });
      test('binary', () {
        expect(parser.parse('[sdf789GSfsb2+3324sf2]').value,
        ['sdf789GSfsb2+3324sf2']);
        expect(parser.parse('[Bad()==^]').isFailure, isTrue);
      });
    });
    group('Number', () {
      test('64 bit float', () {
        expect(parser.parse('5.5f 5.555f 0.12222222223f').value,
          [5.5, 5.555, 0.12222222223]);
      });
      test('64 bit int', () {
        expect(parser.parse('5394239L 10L 10000239L').value,
          [Int64(5394239), Int64(10), Int64(10000239)]);
        expect(parser.parse('5.5L').isFailure, isTrue);
      });
      test('32 bit int', () {
        expect(parser.parse('1 2 3').value,
          [Int32(1), Int32(2), Int32(3)]);
      });
    });
    group('String', () {
      test('string type 1', () {
        expect(parser.parse(' "Hello World" ').value,
          ['Hello World']);
        expect(parser.parse(' "Hello \\" World" ').value,
          ['Hello \\" World']);
      });
      test('string type 2', () {
        expect(parser.parse(" 'Hello World' ").value,
          ['Hello World']);
        expect(parser.parse(""" 'Hello " World' """).value,
          ['Hello " World']);
      });
      test('string type 3', () {
        expect(parser.parse('`hello world`').value,
          ['hello world']);
      });
    });
    group('Date and time', () {
      test('time', () {
        expect(parser.parse('12:14:34').value,
          ['12:14:34']);
        expect(parser.parse('12:14:34.123').value,
          ['12:14:34.123']);
        expect(parser.parse('2d:12:14:34').value,
          ['2d:12:14:34']);
        expect(parser.parse('555:55:55').isFailure, isTrue);
      });
      test('date', () {
        expect(parser.parse('2015/12/06').value,
          ['2015/12/06']);
        expect(parser.parse('2015/12/06 12:00:00.000').value,
          ['2015/12/06 12:00:00.000']);
        expect(parser.parse('2015/12/06 12:00:00.000-UTC').value,
          ['2015/12/06 12:00:00.000-UTC']);
        expect(parser.parse('2015/12/06 12:00:00.000-NYT').isFailure, isTrue);
      });
    });
    group('Tags and nodes', () {
      test('id, section, and nodes', () {
        expect(parser.parse('test true').value,
          [['test', [true]]]);
        expect(parser.parse('this-is_a.valid\$tag-name true').value,
          [['this-is_a.valid\$tag-name', [true]]]);
        expect(parser.parse('test true\ntest true').value,
          [['test', [true]], ['test', [true]]]);
        expect(parser.parse('test true ; test true').value,
          [[['test', [true]], ['test', [true]]]]);
      });
      test('namespace', () {
        expect(parser.parse("math:physics true").value,
          [[['math', 'physics'], [true]]]);
      });
      test('attribute', () {
        expect(parser.parse("math physics=true").value,
          [['math', [{'physics': true}]]]);
      });
      test('object', () {
        final obj1 = '''
          section {
            paragraph "This is the first paragraph"
            paragraph "This is the second paragraph"
          }
          ''';
        final obj2 = '''
          contents {
            section "First section" {
              paragraph "This is the first paragraph"
              paragraph "This is the second paragraph"
            }
          }
          ''';
        expect(parser.parse('test { 1 2 3 }').value,
          [['test', [Int32(1), Int32(2), Int32(3)]]]);
        expect(parser.parse(obj1).value,
          [['section', ['paragraph', ['This is the first paragraph']]]]);
        expect(parser.parse(obj2).value,
          [[
            'contents',
            [
              'section',
              [
                'First section',
                [
                  ['paragraph', ['This is the first paragraph']],
                  ['paragraph', ['This is the second paragraph']]
                ]
              ]
            ]
          ]
        ]);
      });
    });
    group('Comments', () {
      test('Style 1', () {
        expect(parser.parse('"hello there" // this is a comment').value,
          ['hello there']);
      });
      test('Style 2', () {
        expect(parser.parse('"hello there"-- this is a comment').value,
          ['hello there']);
      });
      test('Style 3', () {
        expect(parser.parse('"hello there" # this is a comment').value,
          ['hello there']);
      });
      test('Style 4', () {
        expect(parser.parse(
          '''
            true  /* this is comment 1 */
            false /* this is comment 2 */
          ''').value,
          [true, false]);
      });
    });
  });
}