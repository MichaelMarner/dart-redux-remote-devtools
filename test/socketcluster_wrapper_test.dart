import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:socketcluster_client/socketcluster_client.dart';
import 'dart:async';
import '../lib/redux_remote_devtools.dart';

class SocketFactory {
  connect(String url) {}
}

class MockFactory extends Mock implements SocketFactory {}

class MockSocket extends Mock implements Socket {}

void main() {
  group('SocketClusterWrapper', () {
    group('Constructor', () {
      test('It sets the URL', () {
        var wrapper = new SocketClusterWrapper('ws://example.com');
        expect(wrapper.url, 'ws://example.com');
      });
      test('Does not attempt to connect', () {
        var factory = new MockFactory();
        new SocketClusterWrapper('ws://example.com',
            socketFactory: factory.connect);
        verifyNever(factory.connect(captureAny));
      });
    });

    group('connect', () {
      test('It calls connect with the correct URL', () {
        var factory = new MockFactory();
        var socket = new SocketClusterWrapper('ws://example.com',
            socketFactory: factory.connect);
        socket.connect();
        verify(factory.connect('ws://example.com'));
      });
    });

    group('on', () {
      test('It passes the args through', () async {
        var socket = new MockSocket();
        var wrapper = new SocketClusterWrapper('ws://example.com',
            socketFactory: (String s) => Future.value(socket));
        var testFunc = () => 'asf';
        await wrapper.connect();
        wrapper.on('testEvent', testFunc);
        verify(socket.on('testEvent', testFunc));
      });
    });

    group('emit', () {
      test('It passes the args through', () async {
        var socket = new MockSocket();
        var wrapper = new SocketClusterWrapper('ws://example.com',
            socketFactory: (String s) => Future.value(socket));
        var testFunc = (String s, dynamic err, dynamic data) => 'asf';
        await wrapper.connect();
        wrapper.emit('event', 'data', testFunc);
        verify(socket.emit('event', 'data', testFunc));
      });
    });

    group('id', () {
      test('It passes the args through', () async {
        var socket = new MockSocket();
        when(socket.id).thenReturn('TestId');
        var wrapper = new SocketClusterWrapper('ws://example.com',
            socketFactory: (String s) => Future.value(socket));
        var testFunc = (String s, dynamic err, dynamic data) => 'asf';
        await wrapper.connect();
        expect(wrapper.id, 'TestId');
      });
    });
  });
}
