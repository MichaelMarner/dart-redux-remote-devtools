# Redux Remote Devtools for Dart and Flutter

[![Build Status](https://travis-ci.com/MichaelMarner/dart-redux-remote-devtools.svg?branch=master)](https://travis-ci.com/MichaelMarner/dart-redux-remote-devtools) [![Coverage Status](https://coveralls.io/repos/github/MichaelMarner/dart-redux-remote-devtools/badge.svg?branch=master)](https://coveralls.io/github/MichaelMarner/dart-redux-remote-devtools?branch=master)

Redux Remote Devtools support for Dart and Flutter.

![Devtools Demo](https://github.com/MichaelMarner/dart-redux-remote-devtools/raw/master/doc/assets/DartReduxDemo.gif)

## Installation

Add the library to pubspec.yaml:

```yaml
dependencies:
  redux_remote_devtools: ^2.0.0
```

## Middleware configuration

Add the middleware to your Redux configuration:

```dart
  var remoteDevtools = RemoteDevToolsMiddleware('192.168.1.52:8000');
  final store = DevToolsStore<AppState>(searchReducer,
      middleware: [
        remoteDevtools,
      ]);
  remoteDevtools.store = store;
  await remoteDevtools.connect();
```

> :warning: **Using multiple middleware?**
>
> If you use other middleware, RemoteDevTools _must_ be put last. Otherwise,
> actions and state updates will be out of sync

### What's going on here?

1. Create a new instance of the devtools middleware. Specify the host and port to connect to.

1. Wait for devtools to connect to the remotedev server

1. Initialise your store. To take advantage of time travel, you should use a [DevToolsStore](https://pub.dartlang.org/packages/redux_dev_tools). Pass in remoteDevTools with the rest of your middlware

1. The middleware needs a reference to the store you just created, so commands from devtools can be dispatched. So as a final step, set the reference.

## Using redux-devtools

Use the Javascript [redux-devtools-cli](https://github.com/reduxjs/redux-devtools/tree/master/packages/redux-devtools-cli) package. Start the redux-devtools server on your machine

```bash
npm install -g redux-devtools-cli
redux-devtools --open
```

In the Redux DevTools window select `Settings`... `Connection`... `use local (custom) server` and click `Connect`.

<img width="404" alt="Screen Shot 2020-08-09 at 6 01 30 pm" src="https://user-images.githubusercontent.com/1059276/89727743-f92bb080-da6a-11ea-92d6-d36c0629ff69.png">

Run your application. It will connect to the redux-devtools server. You can now debug your redux application with the Redux DevTools window.

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

The strategy described above should work for most cases. However, if you want to do something different, you can replace the `ActionEncoder` and `StateEncoder` with your own implementations:

```dart
  var remoteDevtools = RemoteDevToolsMiddleware('192.168.1.52:8000', actionEncoder: MyCoolActionEncoder);
```

## Making your actions and state json encodable

You can either write your own `toJson` methods for each of your actions and your state class. However, this quickly becomes cumbersome and error prone. Instead, the recommended way is to make use of the `json_annotation` package to automatically generate toJson functions for you.

## Dispatching Actions from DevTools

You are able to dispatch actions from the Devtools UI and have these processed by the redux implementation in your Flutter app.

In order for this to work, you need to implement an `ActionDecoder`. ActionDecoder's job is to take the JSON data received from the Devtools UI, and return an action that your reducers know how to use. For example if we dispatch an action:

```json
{
  "type": "INCREMENT"
}
```

We would implement an ActionDecoder like so:

```dart
ActionDecoder myDecoder = (dynamic payload) {
  final map = payload as Map<String, dynamic>;
  if (map['type'] == 'INCREMENT') {
    return IncrementAction();
  }
};
```

Essentially, you need to map every JSON action type into an action that can be used by your reducers.

Please get in touch if you have any awesome ideas for how to make this process smoother.

# Example Apps

This repo includes remote-devtools enabled versions of the flutter-redux example apps:

- [flutter-redux Simple Counter App](https://github.com/MichaelMarner/dart-redux-remote-devtools/tree/master/example/counter).

  - Demonstrates how enum actions are sent to devtools.
  - Shows how time travel works.

* [flutter-redux Github Search App](https://github.com/MichaelMarner/dart-redux-remote-devtools/tree/master/example/githubsearch).

  - Demonstrates how class based actions and nested state objects are serialised and made browseable in devtools

  - Demonstrates the limits of time travel in apps that use epics
