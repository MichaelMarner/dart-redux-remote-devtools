part of redux_remote_devtools;

/// Interface for custom action encoding logic.
/// Converts an action into a string suitable for sending to devtools
typedef ActionEncoder = String Function(dynamic action);

/// An action encoder that converts an action to stringified JSON
///
/// Encodes an action as stringified JSON
///
/// Uses the form:
///
/// {
///   "type": "TYPE"
///   "payload": jsonEncode(action)
/// }
///
/// Action type is set to be the class name for class based
/// actions, or an enum value for enum actions
///
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
