import 'package:test/test.dart';
import '../lib/redux_remote_devtools.dart';

void main() {
  group('NOPActionDecoder', () {
    group('decode', () {
      test('Passes through the json payload', () {
        var payload = {'type': 'SOME ACTION', 'value': 123};
        var decoder = new NopActionDecoder();
        var result = decoder.decode(payload);
        expect(result, payload);
      });
    });
  });
}
