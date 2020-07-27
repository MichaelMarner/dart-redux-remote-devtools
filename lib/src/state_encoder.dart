part of redux_remote_devtools;

/// Interface for custom State encoding logic
/// Converts a State instance into a string suitable for sending to devtools
typedef StateEncoder<State> = String Function(State state);

/// A State encoder that converts a state instances to stringified JSON
StateEncoder<dynamic> JsonStateEncoder = (dynamic state) {
  jsonEncode(state);
};
