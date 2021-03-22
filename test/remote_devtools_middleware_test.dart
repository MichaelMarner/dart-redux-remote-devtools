import 'package:mockito/annotations.dart';
import 'package:redux_remote_devtools/redux_remote_devtools.dart';
import 'package:mockito/mockito.dart';
import 'package:socketcluster_client/socketcluster_client.dart';
import 'package:test/test.dart';
import 'dart:async';
import 'dart:convert';
import 'package:redux/redux.dart';
import 'package:redux_dev_tools/redux_dev_tools.dart';

import 'remote_devtools_middleware_test.mocks.dart';

class Next {
  void next(action) {}
}

enum TestActions { SomeAction, SomeOtherAction }

@GenerateMocks([Next, Store, SocketClusterWrapper])
void main() {
  group('RemoteDevtoolsMiddleware', () {
    group('constructor', () {
      test('socket is not connected', () {
        var socket = MockSocketClusterWrapper();
        RemoteDevToolsMiddleware('example.com', socket: socket);
        verifyNever(socket.connect());
      });
    });
    group('connect', () {
      late var socket;
      late RemoteDevToolsMiddleware devtools;
      setUp(() {
        socket = MockSocketClusterWrapper();
        devtools = RemoteDevToolsMiddleware('example.com', socket: socket);
      });
      test('it connects the socket', () {
        devtools.connect();
        verify(socket.connect());
      });
      test('it sends the login message', () async {
        when(socket.connect()).thenAnswer((_) => Future.value());
        when(socket.id).thenReturn('testId');
        when(socket.on('data', captureAny)).thenAnswer((Invocation i) {
          Function fn = i.positionalArguments[1];
          fn('name', {'type': 'START'});
          return Emitter();
        });
        when(socket.emit('login', 'master', captureAny))
            .thenAnswer((Invocation i) {
          Function fn = i.positionalArguments[2];
          fn('testChannel', 'err', 'data');
        });
        await devtools.connect();
        verify(socket.emit('login', 'master', captureAny));
      });
      test('it sends the start message message', () async {
        when(socket.emit('login', 'master', captureAny))
            .thenAnswer((Invocation i) {
          Function fn = i.positionalArguments[2];
          fn('testChannel', 'err', 'data');
          return Emitter();
        });
        when(socket.id).thenReturn('testId');
        when(socket.on('data', captureAny)).thenAnswer((Invocation i) {
          Function fn = i.positionalArguments[1];
          fn('name', {'type': 'START'});
          return Emitter();
        });
        await devtools.connect();
        verify(socket.emit('log',
            {'type': 'START', 'id': 'testId', 'name': 'flutter'}, captureAny));
      });
      test('instance name is configurable', () async {
        final coolInstanceName = 'testName';
        devtools = RemoteDevToolsMiddleware('example.com',
            socket: socket, instanceName: coolInstanceName);
        when(socket.emit('login', 'master', captureAny))
            .thenAnswer((Invocation i) {
          Function fn = i.positionalArguments[2];
          fn('testChannel', 'err', 'data');
          return Emitter();
        });
        when(socket.id).thenReturn('testId');
        when(socket.on('data', captureAny)).thenAnswer((Invocation i) {
          Function fn = i.positionalArguments[1];
          fn('name', {'type': 'START'});
          return Emitter();
        });
        await devtools.connect();
        verify(socket.emit(
            'log',
            {'type': 'START', 'id': 'testId', 'name': '$coolInstanceName'},
            captureAny));
      });
      test('it is in STARTED state', () async {
        when(socket.connect()).thenAnswer((_) => Future.value());
        when(socket.id).thenReturn('testId');
        when(socket.on('data', captureAny)).thenAnswer((Invocation i) {
          Function fn = i.positionalArguments[1];
          fn('name', {'type': 'START'});
          return Emitter();
        });
        when(socket.emit('login', 'master', captureAny))
            .thenAnswer((Invocation i) {
          Function fn = i.positionalArguments[2];
          fn('testChannel', 'err', 'data');
          return Emitter();
        });
        await devtools.connect();
        expect(devtools.status, RemoteDevToolsStatus.started);
      });
      test('it sends the state', () async {
        when(socket.emit('login', 'master', captureAny))
            .thenAnswer((Invocation i) {
          Function fn = i.positionalArguments[2];
          fn('testChannel', 'err', 'data');
          return Emitter();
        });
        when(socket.on('data', captureAny)).thenAnswer((Invocation i) {
          Function fn = i.positionalArguments[1];
          fn('name', {'type': 'START'});
          return Emitter();
        });
        when(socket.id).thenReturn('testId');
        var store = MockStore();
        when(store.state).thenReturn('TEST STATE');
        devtools.store = store;
        await devtools.connect();
        verify(socket.emit('log',
            {'type': 'START', 'id': 'testId', 'name': 'flutter'}, captureAny));
        verify(socket.emit(
            'log',
            {
              'type': 'ACTION',
              'id': 'testId',
              'name': 'flutter',
              'payload': '"TEST STATE"',
              'action': '{"type":"CONNECT","payload":"CONNECT"}',
              'nextActionId': null
            },
            captureAny));
      });
    });
    group('call', () {
      late MockSocketClusterWrapper socket;
      late RemoteDevToolsMiddleware devtools;
      Next next = MockNext();
      late Store store;
      setUp(() async {
        store = MockStore();
        when(store.state).thenReturn({'state': 42});
        socket = MockSocketClusterWrapper();
        when(socket.emit('login', 'master', captureAny))
            .thenAnswer((Invocation i) {
          Function fn = i.positionalArguments[2];
          fn('testChannel', 'err', 'data');
        });
        when(socket.on('data', any)).thenAnswer((Invocation i) {
          Function fn = i.positionalArguments[1];
          fn('name', {'type': 'START'});
          return Emitter();
        });
        when(socket.id).thenReturn('testId');
        when(socket.connect()).thenAnswer((_) => Future.value());

        when(next.next(any)).thenReturn(null);
        devtools = RemoteDevToolsMiddleware('example.com', socket: socket);
        await devtools.connect();
      });
      test('nothing sent if status is not started', () {
        devtools.status = RemoteDevToolsStatus.starting;
        devtools.call(store, TestActions.SomeAction, next.next);
        verifyNever(socket.emit(
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
      test('the action and state are sent', () {
        devtools.status = RemoteDevToolsStatus.started;
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
      MockSocketClusterWrapper socket;
      late RemoteDevToolsMiddleware devtools;
      late MockStore store;
      setUp(() async {
        store = MockStore();
        when(store.state).thenReturn({'state': 42});
        socket = MockSocketClusterWrapper();
        when(socket.emit('login', 'master', captureAny))
            .thenAnswer((Invocation i) {
          Function fn = i.positionalArguments[2];
          fn('testChannel', 'err', 'data');
        });
        when(socket.on('data', any)).thenAnswer((Invocation i) {
          Function fn = i.positionalArguments[1];
          fn('name', {'type': 'START'});
          return Emitter();
        });
        when(socket.id).thenReturn('testId');
        when(socket.connect()).thenAnswer((_) => Future.value());
        devtools = RemoteDevToolsMiddleware('example.com', socket: socket);
        devtools.store = store;
        await devtools.connect();
      });
      test('handles time travel', () {
        var remoteData = {
          'type': 'DISPATCH',
          'action': {'type': 'JUMP_TO_STATE', 'index': 4}
        };
        when(store.dispatch(any)).thenAnswer((i) => i.positionalArguments[0]);
        devtools.handleEventFromRemote(remoteData);
        final DevToolsAction arg =
            verify(store.dispatch(captureAny)).captured.first;
        expect(arg.type, DevToolsActionTypes.JumpToState);
        expect(arg.position, 4);
      });
      test('Dispatches arbitrary remote actions', () {
        var remoteData = {
          'type': 'ACTION',
          'action': '{"type": "TEST ACTION", "value": 12}'
        };
        when(store.dispatch(any)).thenAnswer((i) => i.positionalArguments[0]);
        devtools.handleEventFromRemote(remoteData);
        print(jsonDecode(remoteData['action']!));
        var expected =
            DevToolsAction.perform(jsonDecode(remoteData['action']!));
        print(expected);
        var verifyResult = verify(store.dispatch(captureAny)).captured.first;
        expect(verifyResult.type, DevToolsActionTypes.PerformAction);
        expect(verifyResult.appAction['type'], 'TEST ACTION');
        expect(verifyResult.appAction['value'], 12);
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
