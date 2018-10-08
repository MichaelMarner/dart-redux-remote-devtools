import '../lib/redux_remote_devtools.dart';
import 'package:socketcluster_client/socketcluster_client.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockSocket extends Mock implements Socket {}

void main() {
  group('RemoteDevtoolsMiddleware', () {
    group('constructor', () {
      test('socket is not connected', () {
        var socket = new MockSocket();
        new RemoteDevToolsMiddleware('example.com', socket: socket);
        verifyNever(socket.connect());
      });
    });
    group('connect', () {
      Socket socket;
      RemoteDevToolsMiddleware devtools;
      setUp(() {
        socket = new MockSocket();
        devtools = RemoteDevToolsMiddleware('example.com', socket: socket);
        devtools.connect();
      });
      test('it connects the socket', () {
        verify(socket.connect());
      });
      test('it sends the login message', () {
        verify(socket.emit("login", "master", captureAny));
      });
      test('it sends the start message message', () {});
    });
    group('call', () {
      group('enum actions', () {
        test('the action is sent', () {});
        test('the state is sent', () {});
      });
      group('class actions', () {
        test('the action is sent', () {});
        test('the state is sent', () {});
      });
    });
    group('remote action', () {});
  });
}
