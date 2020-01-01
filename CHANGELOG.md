# Redux Remote Devtools

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
