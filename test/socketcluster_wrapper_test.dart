import 'package:mockito/annotations.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:socketcluster_client/socketcluster_client.dart';
import 'dart:async';
import 'package:redux_remote_devtools/redux_remote_devtools.dart';
import 'socketcluster_wrapper_test.mocks.dart';

abstract class SocketFactory {
  Future<Socket> connect(String url);
}

@GenerateMocks([Socket, SocketFactory])
void main() {
  group('SocketClusterWrapper', () {
    group('Constructor', () {
      test('It sets the URL', () {
        var wrapper = SocketClusterWrapper('ws://example.com');
        expect(wrapper.url, 'ws://example.com');
      });
      test('Does not attempt to connect', () {
        var factory = MockSocketFactory();
        SocketClusterWrapper('ws://example.com',
            socketFactory: factory.connect);
        verifyNever(factory.connect(captureAny));
      });
    });

    group('connect', () {
      test('It calls connect with the correct URL', () {
        final factory = MockSocketFactory();
        final s = MockSocket();
        when(factory.connect('ws://example.com'))
            .thenAnswer((_) => Future.value(s));
        final socket = SocketClusterWrapper('ws://example.com',
            socketFactory: factory.connect);
        socket.connect();
        verify(factory.connect('ws://example.com'));
      });
    });

    group('on', () {
      test('It passes the args through', () async {
        var socket = MockSocket();
        when(socket.on('testEvent', any)).thenReturn(Emitter());
        var wrapper = SocketClusterWrapper('ws://example.com',
            socketFactory: (String s) => Future.value(socket));
        var testFunc = () => 'asf';
        await wrapper.connect();
        wrapper.on('testEvent', testFunc);
        verify(socket.on('testEvent', testFunc));
      });
    });

    group('emit', () {
      test('It passes the args through', () async {
        var socket = MockSocket();
        when(socket.emit('event', 'data', any)).thenReturn(socket);
        var wrapper = SocketClusterWrapper('ws://example.com',
            socketFactory: (String s) => Future.value(socket));
        var testFunc = (String s, dynamic err, dynamic data) => 'asf';
        await wrapper.connect();
        wrapper.emit('event', 'data', testFunc);
        verify(socket.emit('event', 'data', testFunc));
      });
    });

    group('id', () {
      test('It passes the args through', () async {
        var socket = MockSocket();
        when(socket.id).thenReturn('TestId');
        var wrapper = SocketClusterWrapper('ws://example.com',
            socketFactory: (String s) => Future.value(socket));
        await wrapper.connect();
        expect(wrapper.id, 'TestId');
      });
    });
  });
}
