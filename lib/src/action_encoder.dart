part of redux_remote_devtools;

/// Interface for custom action encoding logic.
/// Converts an action into a string suitable for sending to devtools
typedef ActionEncoder = String Function(dynamic action);

/// An action encoder that converts an action to stringified JSON
ActionEncoder JsonActionEncoder = (dynamic action) {
  /// Gets a type name for the action, based on the class name or value
  String getActionType(dynamic action) {
    if (action.toString().contains('Instance of')) {
      return action.runtimeType.toString();
    }
    return action.toString();
  }

  try {
    return jsonEncode({'type': getActionType(action), 'payload': action});
  } on Error {
    return jsonEncode({'type': getActionType(action)});
  }
};
