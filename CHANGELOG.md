# 3.0.0

## Sound Null Safety

This release migrates Remote DevTools to Dart's new null safety. The changes are mostly internal, so this new release should slot into your previous code, once you have migrated your project to null safety.o

Note that going forward I will not be doing fixes or new features on the 2.x branch - Null Safety is the Future.

# 2.0.0

## Breaking Change

Replaces the abstract classes `StateEncoder`, `ActionEncoder`, and `ActionDecoder` with function typedefs.
This is inline with the [Dart styleguide](http://dart-lang.github.io/linter/lints/one_member_abstracts.html), which advocates using function typedefs instead of single method abstract classes.

**This will only affect you if you are using custom encoders/decoders. No changes if you are using remote devtools as-is.**

Before:

```dart
class MyActionEncoder extends ActionEncoder {
  String encode(dynamic action) {
    // custom encoding logic here...
  }
}
```

After:

```dart
ActionEncoder MyActionEncoder = (dynamic action) {
  // custom encoding logic here
}
```

Again, for most people this will require no changes to code.

# 1.0.4

- Updates pubspec to get those sweet sweet Pub Points
- No functional changes

# 1.0.3

- Updates documentation. No functional changes

# 1.0.2

- Adds analysis_options.yaml and fixes warnings. No functional changes

# 1.0.1

- Allows use of latest redux_devtools
- Clean up code to get that pub.dev health rating up

# 1.0.0

- Allows support for Redux 4.0.0 (backwards compatible with 3)
- Switching to semver versioning

# 0.0.11

- Updates dependency to latest socketcluster_client and makes this package work
  on Flutter mobile again

# 0.0.10

- Updates dependency to latest socketcluster_client

# 0.0.9

- Resolves an issue where the connect function returned when the http
  connection was established, instead of after the connect handshake
  completed. This was causing the first few actions to be missing from
  devtools. Thanks to @dennis-tra for fixing this.

# 0.0.8

- Backwards compatible Update to support changes to Dart API (thanks @tvolkert)

## 0.0.7

- add support for receiving remote actions from the devtools ui. big thanks to @kadza for helping work through this feature

## 0.0.6

- Correctly handle the START response message

## 0.0.5

- Send current state to devtools on connect

## 0.0.4

- Update Documentation

## 0.0.3

- Specify minimum version of socketcluster_client

## 0.0.2

- Use socketcluster_client from pub.

## 0.0.1 - Initial Release
