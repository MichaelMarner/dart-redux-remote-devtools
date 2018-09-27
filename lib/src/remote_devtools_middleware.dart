part of remote_devtools;

class RemoteDevToolsMiddleware<T> extends MiddlewareClass<T> {
  /**
   * The remote-devtools server to connect to. Should include
   * protocol and port if necessary. For example:
   * 
   * example.lan:8000
   * 
   */
  String _host;
  Socket _socket;
  Store<T> store;
  String _channel;
  bool _started = false;

  ActionEncoder actionEncoder;
  StateEncoder stateEncoder;

  RemoteDevToolsMiddleware(this._host,
      [this.actionEncoder = const JsonActionEncoder(),
      this.stateEncoder = const JsonStateEncoder(),
      this._socket]) {
    if (_socket == null) {
      this._socket = new Socket('ws://${this._host}/socketcluster/');
    }
  }

  connect() async {
    await this._socket.connect();
    this._channel = await this._login();
    this._relay('START');
    _started = true;
    this._socket.on(_channel, (String name, dynamic data) {
      this._handleEventFromRemote(data as Map<String, dynamic>);
    });
  }

  Future<String> _login() {
    Completer<String> c = new Completer<String>();
    this._socket.emit('login', 'master',
        (String name, dynamic error, dynamic data) {
      c.complete(data as String);
    });
    return c.future;
  }

  _relay(String type, [T state, dynamic action, String nextActionId]) {
    var message = {'type': type, 'id': _socket.id, 'name': 'flutter'};

    if (state != null) {
      message['payload'] = this.stateEncoder.encode(state);
    }
    if (type == 'ACTION') {
      message['action'] = this.actionEncoder.encode(action);
      message['nextActionId'] = nextActionId;
    } else if (action != null) {
      message['action'] = action as String;
    }
    _socket.emit(this._socket.id != null ? 'log' : 'log-noid', message);
  }

  void _handleEventFromRemote(Map<String, dynamic> data) {
    print(data);
    switch (data['type'] as String) {
      case 'DISPATCH':
        _handleDispatch(data['action']);
        break;
      default:
        print('Unknown type:' + data['type'].toString());
    }
  }

  void _handleDispatch(dynamic action) {
    switch (action['type'] as String) {
      case 'JUMP_TO_STATE':
        this
            .store
            .dispatch(new DevToolsAction.jumpToState(action['index'] as int));
        break;
    }
  }

  /// Middleware function called by redux, dispatches actions to devtools
  call(Store<T> store, dynamic action, NextDispatcher next) {
    next(action);
    if (_started && !(action is DevToolsAction)) {
      this._relay('ACTION', store.state, action);
    }
  }
}
