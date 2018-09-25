import 'package:redux/redux.dart';
import 'package:socketcluster_client/socketcluster_client.dart';
import 'package:redux_dev_tools/redux_dev_tools.dart';
import 'dart:convert';
import 'dart:async';

class RemoteDevToolsMiddleware<T> extends MiddlewareClass<T>
    implements BasicListener {
  /**
   * The remote-devtools server to connect to. Should include
   * protocol and port if necessary. For example:
   * 
   * example.lan:8000
   * 
   */
  String host;
  Socket socket;
  Store<T> store;
  String channel;
  bool started = false;

  RemoteDevToolsMiddleware(this.host);

  onAuthentication(Socket s, bool status) {
    print('onAuthentication');
    print(status);
  }

  void onConnected(Socket socket) {
    print('onConnected');
  }

  void onDisconnected(Socket socket) {
    print('onDisconnected');
  }

  void onConnectError(Socket socket, dynamic e) {
    print('onConnectError');
    print(e);
  }

  void onSetAuthToken(String token, Socket socket) {
    print('onSetAuthToken');
  }

  connect() async {
    this.socket =
        await Socket.connect('ws://$host/socketcluster/', listener: this);
    print('Connected to server');
    this.channel = await this.login();
    print('channel: $channel');
    this.relay('START');
    started = true;
    this.socket.on(channel, (String name, dynamic data) {
      this.handleRemoteAction(data as Map<String, dynamic>);
    });
  }

  Future<String> login() {
    Completer<String> c = new Completer<String>();
    this.socket.emit('login', 'master',
        (String name, dynamic error, dynamic data) {
      c.complete(data as String);
    });
    return c.future;
  }

  relay(String type, [T state, dynamic action, String nextActionId]) {
    var message = {'type': type, 'id': socket.id, 'name': 'flutter'};

    if (state != null) {
      message['payload'] = jsonEncode(state);
    }
    if (type == 'ACTION') {
      try {
        message['action'] =
            jsonEncode({'type': getActionType(action), 'payload': action});
      } on Error {
        message['action'] = jsonEncode({'type': getActionType(action)});
      }
      message['nextActionId'] = nextActionId;
    } else if (action != null) {
      message['action'] = action as String;
    }
    socket.emit(this.socket.id != null ? 'log' : 'log-noid', message);
  }

  void handleRemoteAction(Map<String, dynamic> data) {
    print(data);
    switch (data['type'] as String) {
      case 'DISPATCH':
        handleDispatch(data['action']);
        break;
      default:
        print('Unknown type:' + data['type'].toString());
    }
  }

  void handleDispatch(dynamic action) {
    switch (action['type'] as String) {
      case 'JUMP_TO_STATE':
        this
            .store
            .dispatch(new DevToolsAction.jumpToState(action['index'] as int));
        break;
    }
  }

  /**
   * Middleware function called automatically by Redux
   * when an action is dispatched.
   */
  call(Store<dynamic> store, dynamic action, NextDispatcher next) {
    next(action);
    print(action);
    if (started && !(action is DevToolsAction)) {
      this.relay('ACTION', store.state as T, action);
    }
  }

  String getActionType(dynamic action) {
    try {
      return action.runtimeType.toString();
    } on Exception {
      return action.toString();
    }
  }
}
