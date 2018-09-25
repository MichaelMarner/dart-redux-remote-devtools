# Redux Remote Devtools for Dart and Flutter

[![Build Status](https://travis-ci.com/MichaelMarner/dart-redux-remote-devtools.svg?branch=master)](https://travis-ci.com/MichaelMarner/dart-redux-remote-devtools) [![Coverage Status](https://coveralls.io/repos/github/MichaelMarner/dart-redux-remote-devtools/badge.svg?branch=master)](https://coveralls.io/github/MichaelMarner/dart-redux-remote-devtools?branch=master)

Work in progress getting the Javascript Redux Remote Devtools working with Dart
and Flutter. Not to be used by anybody (yet)

## Installation

Add the library to pubspec.yaml. The package is not available on pub yet, so use the git repo instead.

```yaml
dependencies:
  redux-remote-devtools:
    git: https://github.com/MichaelMarner/dart-redux-remote-devtools.git
```

## Middleware configuration

Add the middleware to your Redux configuration:

```dart
  var remoteDevtools = RemoteDevToolsMiddleware<AppState>('192.168.1.52:8000');
  await remoteDevtools.connect();
  final store = new DevToolsStore<AppState>(searchReducer,
      middleware: [
        remoteDevtools,
      ]);

  remoteDevtools.store = store;
```

### What's going on here?

1. Create a new instance of the devtools middleware. The middleware is a parameterised type - you need to pass in the type of your redux state. Specify the host and port to connect to.

1. Wait for devtools to connect to the remotedev server

1. Initialise your store. To take advantage of time travel, you should use a `DevToolsStore`. Pass in remoteDevTools with the rest of your middlware

1. The middleware needs a reference to the store you just created, so commands from devtools can be dispatched. So as a final step, set the reference.

## Using remotedev

Use the Javascript Remote Devtools package. Start the remotedev server on your machine

```bash
remotedev --port 8000
```

Run your application. It will connect to the remotedev server. You can now debug your redux application by opening up `http://localhost:8000` in a web browser.

## Encoding Actions and State

In the Javascript world, Redux follows a convention that your redux state is a plain Javascript Object, and actions are also Javascript objects that have a `type` property. The JS Redux Devtools expect this. However, Redux.dart tries to take advantage of the strong typing available in Dart. To make Redux.dart work with the JS devtools, we need to convert actions and state instances to JSON before sending.

Remember that the primary reason for using devtools is to allow the developer to reason about what the app is doing. Therefore, exact conversion is not strictly necessary - it's more important for what appears in devtools to be meaningful to the developer.

### Enconding Strategy for Actions

We use the class name as the action `type` for class based actions. For enum typed actions, we use the value of the action. For example:

```dart
enum EnumActions {
  Action1;
  Action2;
}

class ClassAction {}
```

When converted, these actions will be `{"type": "Action1"}` or `{"type": "ClassAction"}`, etc.

We also want to send the action properties over to devtools. To do this, we attempt to `jsonEncode` the entire Action, and attach this JSON data as a `payload` property. For example:

```dart
class ClassAction {
  int someValue;

  toJson() {
    return {'someValue': this.someValue};
  }
}
```

Would appear in devtools as:

```js
{
  "type": "ClassAction",
  "payload": {
    "someValue": 5 // or whatever someValue was set to
  },
}
```

This of course means your Actions need to be json encodable. You can do what the example above does and write your own `toJson` method. However, a better approach is to use a generator to do it for you. If your action is not json encodable, the payload property will be missing in devtools.

### Encoding strategy for State

For state, we simply attempt to `jsonEncode` the entire thing. If your state cannot be converted, then state updates will not appear in devtools.

### Overriding these strategies

The strategy described above should work for most cases. However, if you want to do something different, you can replace the `ActionEncoder` and `StateEncoder` with your own classes:

```dart
  var remoteDevtools = RemoteDevToolsMiddleware<AppState>('192.168.1.52:8000', actionEncoder: new MyCoolActionEncoder());
```
