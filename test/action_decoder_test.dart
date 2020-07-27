import 'package:test/test.dart';
import 'package:redux_remote_devtools/redux_remote_devtools.dart';

void main() {
  group('NOPActionDecoder', () {
    group('decode', () {
      test('Passes through the json payload', () {
        var payload = {'type': 'SOME ACTION', 'value': 123};
        var decoder = NopActionDecoder;
        var result = decoder(payload);
        expect(result, payload);
      });
    });
  });
}
