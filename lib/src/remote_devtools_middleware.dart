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

class RemoteDevToolsMiddleware<State> extends MiddlewareClass<State> {
  ///
  /// The remote-devtools server to connect to. Should include
  /// protocol and port if necessary. For example:
  ///
  /// example.lan:8000
  ///
  ///
  final String _host;
  late SocketClusterWrapper socket;
  Store<State>? store;
  late String _channel;
  RemoteDevToolsStatus status = RemoteDevToolsStatus.notConnected;

  /// The function used to decode actions. If not specifies, defaults to [NopActionDecoder]
  late ActionDecoder actionDecoder;

  /// The function used to encode actions to a String for sending. If not specifies, defaults to [JsonActionEncoder]
  late ActionEncoder actionEncoder;

  /// The function used to encode state to a String for sending. If not specifies, defaults to [JsonStateEncoder]
  late StateEncoder<State> stateEncoder;

  /// The name that will appear in Instance Name in Dev Tools. If not specified, default to 'flutter'.
  String instanceName;

  RemoteDevToolsMiddleware(
    this._host, {
    ActionDecoder? actionDecoder,
    ActionEncoder? actionEncoder,
    StateEncoder<State>? stateEncoder,
    SocketClusterWrapper? socket,
    this.instanceName = 'flutter',
  }) {
    this.actionEncoder = actionEncoder ?? JsonActionEncoder;
    this.actionDecoder = actionDecoder ?? NopActionDecoder;
    this.stateEncoder = stateEncoder ?? JsonStateEncoder;
    this.socket = socket ?? SocketClusterWrapper('ws://$_host/socketcluster/');
  }

  Future<void> connect() async {
    _setStatus(RemoteDevToolsStatus.connecting);
    await socket.connect();
    _setStatus(RemoteDevToolsStatus.connected);
    _channel = await _login();
    _setStatus(RemoteDevToolsStatus.starting);
    _relay('START');
    await _waitForStart();
    socket.on(_channel, (String? name, dynamic data) {
      handleEventFromRemote(data as Map<String, dynamic>);
    });
    if (store != null) {
      _relay('ACTION', store!.state, 'CONNECT');
    }
  }

  Future<dynamic> _waitForStart() {
    final c = Completer();
    socket.on(_channel, (String? name, dynamic data) {
      if (data['type'] == 'START') {
        _setStatus(RemoteDevToolsStatus.started);
        c.complete();
      } else {
        c.completeError(data);
      }
    });
    return c.future;
  }

  Future<String> _login() {
    final c = Completer<String>();
    socket.emit('login', 'master', (String name, dynamic error, dynamic data) {
      c.complete(data as String?);
    });
    return c.future;
  }

  void _relay(String type,
      [State? state, dynamic action, String? nextActionId]) {
    var message = {'type': type, 'id': socket.id, 'name': instanceName};

    if (state != null) {
      try {
        message['payload'] = stateEncoder(state);
      } catch (error) {
        message['payload'] =
            'Could not encode state. Ensure state is json encodable';
      }
    }
    if (type == 'ACTION') {
      message['action'] = actionEncoder(action);
      message['nextActionId'] = nextActionId;
    } else if (action != null) {
      message['action'] = action as String;
    }
    socket.emit(socket.id != null ? 'log' : 'log-noid', message);
  }

  void handleEventFromRemote(Map<String, dynamic> data) {
    switch (data['type'] as String?) {
      case 'DISPATCH':
        _handleDispatch(data['action']);
        break;
      // The START action is a response indicating that remote devtools is up and running
      case 'START':
        _setStatus(RemoteDevToolsStatus.started);
        break;
      case 'ACTION':
        _handleRemoteAction(data['action'] as String?);
        break;
      default:
        print('Unknown type:' + data['type'].toString());
    }
  }

  void _handleDispatch(dynamic action) {
    if (store == null) {
      print('No store reference set, cannot dispatch remote action');
      return;
    }
    switch (action['type'] as String?) {
      case 'JUMP_TO_STATE':
        store?.dispatch(DevToolsAction.jumpToState(action['index'] as int));
        break;
      default:
        print("Unknown commans: ${action['type']}. Ignoring");
    }
  }

  void _handleRemoteAction(String? action) {
    if (store == null) {
      print('No store reference set, cannot dispatch remote action');
      return;
    }
    var actionMap = jsonDecode(action!);
    store?.dispatch(DevToolsAction.perform(actionDecoder(actionMap)));
  }

  /// Middleware function called by redux, dispatches actions to devtools
  @override
  void call(Store<State> store, dynamic action, NextDispatcher next) {
    next(action);
    if (status == RemoteDevToolsStatus.started && !(action is DevToolsAction)) {
      _relay('ACTION', store.state, action);
    }
  }

  void _setStatus(RemoteDevToolsStatus value) {
    status = value;
  }
}
