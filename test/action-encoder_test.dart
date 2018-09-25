import 'package:test/test.dart';
import '../lib/action-encoder.dart';

class TestAction {}

enum EnumActions { SimpleEnumAction }

void main() {
  group('JsonActionEncoder', () {
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
