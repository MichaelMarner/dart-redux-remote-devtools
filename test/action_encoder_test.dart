import 'dart:convert';
import 'package:test/test.dart';
import 'package:redux_remote_devtools/redux_remote_devtools.dart';

class TestAction {
  int value;
  TestAction({this.value});
  Map<String, dynamic> toJson() {
    return {'value': value};
  }
}

enum EnumActions { SimpleEnumAction }

void main() {
  group('JsonActionEncoder', () {
    group('encodeAction', () {
      test('Returns a jsonified action', () {
        var encoder = JsonActionEncoder;
        var result = encoder(TestAction(value: 5));
        var decoded = jsonDecode(result);
        expect(decoded['type'], equals('TestAction'));
        expect(decoded['payload']['value'], equals(5));
      });

      test('Still returns the type if action is not jsonable', () {
        var encoder = JsonActionEncoder;
        var result = encoder(EnumActions.SimpleEnumAction);
        var decoded = jsonDecode(result);
        expect(decoded['type'], equals('EnumActions.SimpleEnumAction'));
        expect(decoded['payload'], equals(null));
      });
    });

    group('getActionType', () {
      test('Returns the class name for a class based action', () {
        var encoder = JsonActionEncoder;
        var result = encoder(TestAction());
        expect(result, equals('TestAction'));
      });
      test('Returns the value for enum actions', () {
        var encoder = JsonActionEncoder;
        var result = encoder(EnumActions.SimpleEnumAction);
        expect(result, equals('EnumActions.SimpleEnumAction'));
      });
    });
  });
}
