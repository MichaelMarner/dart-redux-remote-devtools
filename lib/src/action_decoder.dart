part of redux_remote_devtools;

/// Interface for custom remote action decoding logic
abstract class ActionDecoder {
  const ActionDecoder();

  // Converts a JSON payload from remote devtools to an action
  dynamic decode(dynamic json);
}

/// An action decoder that simply passes through the JSON unmodified
class NOPActionDecoder extends ActionDecoder {
  const NOPActionDecoder() : super();

  dynamic decode(dynamic action) {
    return action;
  }
}
