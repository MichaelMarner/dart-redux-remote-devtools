part of redux_remote_devtools;

/// Interface for custom State encoding logic
abstract class StateEncoder {
  const StateEncoder();

  // Converts a State instance into a string suitable for sending to devtools
  String encode(dynamic state);
}

/// A State encoder that converts a state instances to stringified JSON
class JsonStateEncoder extends StateEncoder {
  const JsonStateEncoder() : super();

  /// Encodes a state instance as stringified JSON
  String encode(dynamic state) {
    return jsonEncode(state);
  }
}
