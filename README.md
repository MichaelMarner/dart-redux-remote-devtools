# Redux Remote Devtools for Dart and Flutter

[![Build Status](https://travis-ci.com/MichaelMarner/dart-redux-remote-devtools.svg?branch=master)](https://travis-ci.com/MichaelMarner/dart-redux-remote-devtools) [![Coverage Status](https://coveralls.io/repos/github/MichaelMarner/dart-redux-remote-devtools/badge.svg?branch=master)](https://coveralls.io/github/MichaelMarner/dart-redux-remote-devtools?branch=master)

Redux Remote Devtools support for Dart and Flutter.

![Devtools Demo](https://github.com/MichaelMarner/dart-redux-remote-devtools/raw/master/doc/assets/DartReduxDemo.gif)

## Installation

Add the library to pubspec.yaml:

```yaml
dependencies:
  redux_remote_devtools: ^0.0.4
```

## Middleware configuration

Add the middleware to your Redux configuration:

```dart
  var remoteDevtools = RemoteDevToolsMiddleware('192.168.1.52:8000');
  final store = new DevToolsStore<AppState>(searchReducer,
      middleware: [
        remoteDevtools,
      ]);
  remoteDevtools.store = store;
  await remoteDevtools.connect();
```

### What's going on here?

1. Create a new instance of the devtools middleware. Specify the host and port to connect to.

1. Wait for devtools to connect to the remotedev server

1. Initialise your store. To take advantage of time travel, you should use a [DevToolsStore](https://pub.dartlang.org/packages/redux_dev_tools). Pass in remoteDevTools with the rest of your middlware

1. The middleware needs a reference to the store you just created, so commands from devtools can be dispatched. So as a final step, set the reference.

## Using remotedev

Use the Javascript [Remote Devtools](https://github.com/zalmoxisus/remotedev-server) package. Start the remotedev server on your machine

```bash
npm install -g remotedev-server
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

This of course means your Actions need to be json encodable. You can do what the example above does and write your own `toJson` method. However, a better approach is to use a generator like [json_serializable](https://pub.dartlang.org/packages/json_serializable) to do it for you. If your action is not json encodable, the payload property will be missing in devtools.

### Encoding strategy for State

For state, we simply attempt to `jsonEncode` the entire thing. If your state cannot be converted, then state updates will not appear in devtools.

### Overriding these strategies

The strategy described above should work for most cases. However, if you want to do something different, you can replace the `ActionEncoder` and `StateEncoder` with your own classes:

```dart
  var remoteDevtools = RemoteDevToolsMiddleware('192.168.1.52:8000', actionEncoder: new MyCoolActionEncoder());
```

## Making your actions and state json encodable

You can either write your own `toJson` methods for each of your actions and your state class. However, this quickly becomes cumbersome and error prone. Instead, the recommended way is to make use of the `json_annotation` package to automatically generate toJson functions for you.

# Example Apps

This repo includes remote-devtools enabled versions of the flutter-redux example apps:

- [flutter-redux Simple Counter App](https://github.com/MichaelMarner/dart-redux-remote-devtools/tree/master/example/counter).

  - Demonstrates how enum actions are sent to devtools.
  - Shows how time travel works.

* [flutter-redux Github Search App](https://github.com/MichaelMarner/dart-redux-remote-devtools/tree/master/example/githubsearch).

  - Demonstrates how class based actions and nested state objects are serialised and made browseable in devtools

  - Demonstrates the limits of time travel in apps that use epics
