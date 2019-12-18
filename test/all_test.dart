library sdl_dart.test.all_test;

import 'package:test/test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:sdl_dart/src/parser.dart';
import 'package:sdl_dart/src/grammar.dart';

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
  });
}