part of redux_remote_devtools;

/// Interface for custom remote action decoding logic.
/// Converts a JSON payload from remote devtools to an action
typedef ActionDecoder = dynamic Function(dynamic json);

/// An action decoder that simply passes through the JSON unmodified
ActionDecoder NopActionDecoder = (dynamic action) => action;
