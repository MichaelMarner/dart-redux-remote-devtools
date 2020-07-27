import 'dart:convert';
import 'package:test/test.dart';
import 'package:redux_remote_devtools/redux_remote_devtools.dart';

class TestState {
  int value;
  TestState({this.value});
  Map<String, dynamic> toJson() {
    return {'value': value};
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
        var encoder = JsonStateEncoder;
        var result = encoder(TestState(value: 5));
        var decoded = jsonDecode(result);
        expect(decoded['value'], equals(5));
      });
      test('Throws an exception if unencodable', () {
        var encoder = JsonStateEncoder;
        var testFunc = () {
          encoder(TestUnencodableState(value: 5));
        };
        expect(testFunc, throwsA(TypeMatcher<JsonUnsupportedObjectError>()));
      });
    });
  });
}
