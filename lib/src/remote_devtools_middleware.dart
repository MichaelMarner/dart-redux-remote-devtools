part of redux_remote_devtools;

/// The connection state of the middleware
enum RemoteDevToolsStatus {
  /// No socket connection to the remote host
  notConnected,

  /// Attempting to open socket
  connecting,

  /// Connected to remote, but not started
  connected,

  /// Awating start response
  starting,

  /// Sending and receiving actions
  started
}

class RemoteDevToolsMiddleware extends MiddlewareClass {
  ///
  /// The remote-devtools server to connect to. Should include
  /// protocol and port if necessary. For example:
  ///
  /// example.lan:8000
  ///
  ///
  final String _host;
  SocketClusterWrapper socket;
  Store store;
  String _channel;
  RemoteDevToolsStatus status = RemoteDevToolsStatus.notConnected;

  ActionDecoder actionDecoder;
  ActionEncoder actionEncoder;
  StateEncoder stateEncoder;

  RemoteDevToolsMiddleware(
    this._host, {
    this.actionDecoder = const NopActionDecoder(),
    this.actionEncoder = const JsonActionEncoder(),
    this.stateEncoder = const JsonStateEncoder(),
    this.socket,
  }) {
    if (socket == null) {
      socket = SocketClusterWrapper('ws://$_host/socketcluster/');
    }
  }

  connect() async {
    _setStatus(RemoteDevToolsStatus.connecting);
    await this.socket.connect();
    _setStatus(RemoteDevToolsStatus.connected);
    this._channel = await this._login();
    _setStatus(RemoteDevToolsStatus.starting);
    this._relay('START');
    await this._waitForStart();
    this.socket.on(_channel, (String name, dynamic data) {
      this.handleEventFromRemote(data as Map<String, dynamic>);
    });
    if (this.store != null) {
      this._relay('ACTION', store.state, 'CONNECT');
    }
  }

  Future<dynamic> _waitForStart() {
    final c = Completer();
    this.socket.on(_channel, (String name, dynamic data) {
      if (data['type'] == "START") {
        _setStatus(RemoteDevToolsStatus.started);
        c.complete();
      } else {
        c.completeError(data);
      }
    });
    return c.future;
  }

  Future<String> _login() {
    Completer<String> c = new Completer<String>();
    this.socket.emit('login', 'master',
        (String name, dynamic error, dynamic data) {
      c.complete(data as String);
    });
    return c.future;
  }

  _relay(String type, [Object state, dynamic action, String nextActionId]) {
    var message = {'type': type, 'id': socket.id, 'name': 'flutter'};

    if (state != null) {
      try {
        message['payload'] = this.stateEncoder.encode(state);
      } catch (error) {
        message['payload'] =
            'Could not encode state. Ensure state is json encodable';
      }
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
    switch (data['type'] as String) {
      case 'DISPATCH':
        _handleDispatch(data['action']);
        break;
      // The START action is a response indicating that remote devtools is up and running
      case 'START':
        _setStatus(RemoteDevToolsStatus.started);
        break;
      case 'ACTION':
        _handleRemoteAction(data['action'] as String);
        break;
      default:
        print('Unknown type:' + data['type'].toString());
    }
  }

  void _handleDispatch(dynamic action) {
    if (this.store == null) {
      print('No store reference set, cannot dispatch remote action');
      return;
    }
    switch (action['type'] as String) {
      case 'JUMP_TO_STATE':
        this
            .store
            .dispatch(new DevToolsAction.jumpToState(action['index'] as int));
        break;
      default:
        print("Unknown commans: ${action['type']}. Ignoring");
    }
  }

  void _handleRemoteAction(String action) {
    if (this.store == null) {
      print('No store reference set, cannot dispatch remote action');
      return;
    }
    var actionMap = jsonDecode(action);
    this.store.dispatch(
        new DevToolsAction.perform(this.actionDecoder.decode(actionMap)));
  }

  /// Middleware function called by redux, dispatches actions to devtools
  dynamic call(Store store, dynamic action, NextDispatcher next) {
    final result = next(action);
    if (this.status == RemoteDevToolsStatus.started &&
        !(action is DevToolsAction)) {
      this._relay('ACTION', store.state, action);
    }

    return result;
  }

  _setStatus(RemoteDevToolsStatus value) {
    this.status = value;
  }
}
