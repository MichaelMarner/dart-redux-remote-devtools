import 'dart:convert';
import 'package:test/test.dart';
import '../lib/remote_devtools.dart';

class TestState {
  int value;
  TestState({this.value});
  toJson() {
    return {'value': this.value};
  }
}

class TestUnencodableState {
  int value;
  TestUnencodableState({this.value});
}

enum EnumActions { SimpleEnumAction }

void main() {
  group('JsonStateEncoder', () {
    group('encode', () {
      test('Returns a jsonified state', () {
        var encoder = new JsonStateEncoder();
        var result = encoder.encode(new TestState(value: 5));
        var decoded = jsonDecode(result);
        expect(decoded['value'], equals(5));
      });
      test('Throws an exception if unencodable', () {
        var encoder = new JsonStateEncoder();
        var testFunc = () {
          encoder.encode(new TestUnencodableState(value: 5));
        };
        expect(testFunc, throwsA(TypeMatcher<JsonUnsupportedObjectError>()));
      });
    });
  });
}
