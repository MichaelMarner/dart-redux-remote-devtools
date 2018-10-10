part of redux_remote_devtools;

class SocketClusterWrapper {
  Socket _socket;
  Function socketFactory;
  String url;
  SocketClusterWrapper(this.url, {this.socketFactory = Socket.connect});

  Future<void> connect() async {
    this._socket = await socketFactory(this.url);
  }

  Emitter on(String event, Function func) {
    return this._socket.on(event, func);
  }

  void emit(String event, Object data, [AckCall ack]) {
    this._socket.emit(event, data, ack);
  }

  get id => this._socket.id;
}
