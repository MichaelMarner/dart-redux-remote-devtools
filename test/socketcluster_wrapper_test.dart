import 'package:test/test.dart';
import '../lib/redux_remote_devtools.dart';

void main() {
  group('SocketClusterWrapper', () {
    group('Constructor', () {
      test('It sets the URL', () {
        var wrapper = new SocketClusterWrapper('ws://example.com');
        expect(wrapper.url, 'ws://example.com');
      });
    });
  });
}
