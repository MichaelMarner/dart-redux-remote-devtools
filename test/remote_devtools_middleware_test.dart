import '../lib/redux_remote_devtools.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'dart:async';
import 'package:redux/redux.dart';
import 'package:redux_dev_tools/redux_dev_tools.dart';

class MockSocket extends Mock implements SocketClusterWrapper {}

class MockStore extends Mock implements Store {}

class Next {
  next(action) {}
}

enum TestActions { SomeAction, SomeOtherAction }

class MockNext extends Mock implements Next {}

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
      var socket;
      RemoteDevToolsMiddleware devtools;
      Future connectResponse;
      setUp(() {
        socket = new MockSocket();
        devtools = RemoteDevToolsMiddleware('example.com', socket: socket);
      });
      test('it connects the socket', () {
        devtools.connect();
        verify(socket.connect());
      });
      test('it sends the login message', () async {
        when(socket.connect()).thenAnswer((_) => new Future.value());
        when(socket.id).thenReturn('testId');
        when(socket.emit("login", "master", captureAny))
            .thenAnswer((Invocation i) {
          Function fn = i.positionalArguments[2];
          fn('testChannel', 'err', 'data');
        });
        await devtools.connect();
        verify(socket.emit("login", "master", captureAny));
      });
      test('it sends the start message message', () async {
        when(socket.emit("login", "master", captureAny))
            .thenAnswer((Invocation i) {
          Function fn = i.positionalArguments[2];
          fn('testChannel', 'err', 'data');
        });
        when(socket.id).thenReturn('testId');
        connectResponse = await devtools.connect();
        verify(socket.emit("log",
            {'type': "START", 'id': 'testId', 'name': 'flutter'}, captureAny));
      });
    });
    group('call', () {
      SocketClusterWrapper socket;
      RemoteDevToolsMiddleware devtools;
      Next next = new MockNext();
      Store store;
      setUp(() async {
        store = new MockStore();
        when(store.state).thenReturn({'state': 42});
        socket = new MockSocket();
        when(socket.emit("login", "master", captureAny))
            .thenAnswer((Invocation i) {
          Function fn = i.positionalArguments[2];
          fn('testChannel', 'err', 'data');
        });
        when(socket.id).thenReturn('testId');
        when(socket.connect()).thenAnswer((_) => new Future.value());
        devtools = RemoteDevToolsMiddleware('example.com', socket: socket);
        await devtools.connect();
      });
      test('the action and state are sent', () {
        devtools.call(store, TestActions.SomeAction, next.next);
        verify(socket.emit(
            'log',
            {
              'type': 'ACTION',
              'id': 'testId',
              'name': 'flutter',
              'payload': '{"state":42}',
              'action': '{"type":"TestActions.SomeAction"}',
              'nextActionId': null
            },
            captureAny));
      });
      test('calls next', () {
        devtools.call(store, TestActions.SomeAction, next.next);
        verify(next.next(TestActions.SomeAction));
      });
    });
    group('remote action', () {
      SocketClusterWrapper socket;
      RemoteDevToolsMiddleware devtools;
      Store store;
      setUp(() async {
        store = new MockStore();
        when(store.state).thenReturn({'state': 42});
        socket = new MockSocket();
        when(socket.emit("login", "master", captureAny))
            .thenAnswer((Invocation i) {
          Function fn = i.positionalArguments[2];
          fn('testChannel', 'err', 'data');
        });
        when(socket.id).thenReturn('testId');
        when(socket.connect()).thenAnswer((_) => new Future.value());
        devtools = RemoteDevToolsMiddleware('example.com', socket: socket);
        devtools.store = store;
        await devtools.connect();
      });
      test('handles time travel', () {
        var remoteData = {
          'type': 'DISPATCH',
          'action': {'type': 'JUMP_TO_STATE', 'index': 4}
        };
        devtools.handleEventFromRemote(remoteData);
        verify(store.dispatch(new DevToolsAction.jumpToState(4)));
      });
      test('Does not dispatch if store has not been sent', () {
        devtools.store = null;
        var remoteData = {
          'type': 'DISPATCH',
          'action': {'type': 'JUMP_TO_STATE', 'index': 4}
        };
        expect(
            () => devtools.handleEventFromRemote(remoteData), returnsNormally);
      });
    });
  });
}
