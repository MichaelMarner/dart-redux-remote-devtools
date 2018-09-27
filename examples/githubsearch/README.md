# githubsearch

Redux demonstration app that lets you search Github repositories.

This is a copy of the example program from [flutter_redux](https://github.com/brianegan/flutter_redux), with additional support for Remote Devtools.

- Uses DevToolsStore to allow time travel
- Connects to remote devtools on startup
- Sends all actions and state updates serialized as JSON

## Trying it out

1.  Get [remotedev-server](https://github.com/zalmoxisus/remotedev-server) from npm:

        npm install -g remotedev-server

2.  Start the server

        remotedev --port 8000

3.  Edit `main.dart` and put in your computer's IP address or host name

4.  Open `http://localhost:8000` in a web browser. You should see the remote-devtools window

5.  Run the flutter app

        flutter run

6.  Search repos, see the actions fly through devtools
