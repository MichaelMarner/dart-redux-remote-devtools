part of remote_devtools;

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

  ActionEncoder actionEncoder;
  StateEncoder stateEncoder;

  RemoteDevToolsMiddleware(this.host,
      [this.actionEncoder = const JsonActionEncoder(),
      this.stateEncoder = const JsonStateEncoder()]);

  void onAuthentication(Socket s, bool status) {}
  void onConnected(Socket socket) {}
  void onDisconnected(Socket socket) {}
  void onConnectError(Socket socket, dynamic e) {}
  void onSetAuthToken(String token, Socket socket) {}

  connect() async {
    this.socket =
        await Socket.connect('ws://$host/socketcluster/', listener: this);
    this.channel = await this.login();
    this.relay('START');
    started = true;
    this.socket.on(channel, (String name, dynamic data) {
      this.handleEventFromRemote(data as Map<String, dynamic>);
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
      message['payload'] = this.stateEncoder.encode(state);
    }
    if (type == 'ACTION') {
      message['action'] = this.actionEncoder.encode(action);
      message['nextActionId'] = nextActionId;
    } else if (action != null) {
      message['action'] = action as String;
    }
    socket.emit(this.socket.id != null ? 'log' : 'log-noid', message);
  }

  void handleEventFromRemote(Map<String, dynamic> data) {
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

  /// Middleware function called by redux, dispatches actions to devtools
  call(Store<dynamic> store, dynamic action, NextDispatcher next) {
    next(action);
    print(action);
    if (started && !(action is DevToolsAction)) {
      this.relay('ACTION', store.state as T, action);
    }
  }
}
