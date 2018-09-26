import 'dart:convert';
import 'package:test/test.dart';
import '../lib/remote-devtools.dart';

class TestAction {
  int value;
  TestAction({this.value});
  toJson() {
    return {'value': this.value};
  }
}

enum EnumActions { SimpleEnumAction }

void main() {
  group('JsonActionEncoder', () {
    group('encodeAction', () {
      test('Returns a jsonified action', () {
        var encoder = new JsonActionEncoder();
        var result = encoder.encode(new TestAction(value: 5));
        var decoded = jsonDecode(result);
        expect(decoded['type'], equals('TestAction'));
        expect(decoded['payload']['value'], equals(5));
      });

      test('Still returns the type if action is not jsonable', () {
        var encoder = new JsonActionEncoder();
        var result = encoder.encode(EnumActions.SimpleEnumAction);
        var decoded = jsonDecode(result);
        expect(decoded['type'], equals('EnumActions.SimpleEnumAction'));
        expect(decoded['payload'], equals(null));
      });
    });

    group('getActionType', () {
      test('Returns the class name for a class based action', () {
        var encoder = new JsonActionEncoder();
        var result = encoder.getActionType(new TestAction());
        expect(result, equals('TestAction'));
      });
      test('Returns the value for enum actions', () {
        var encoder = new JsonActionEncoder();
        var result = encoder.getActionType(EnumActions.SimpleEnumAction);
        expect(result, equals('EnumActions.SimpleEnumAction'));
      });
    });
  });
}
