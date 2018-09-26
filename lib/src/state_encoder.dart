part of remote_devtools;

/// Interface for custom State encoding logic
abstract class StateEncoder<T> {
  const StateEncoder();

  // Converts a State instance into a string suitable for sending to devtools
  String encode(T state);
}

/// A State encoder that converts a state instances to stringified JSON
class JsonStateEncoder<T> extends StateEncoder<T> {
  const JsonStateEncoder() : super();

  /// Encodes a state instance as stringified JSON
  String encode(T state) {
    return jsonEncode(state);
  }
}
