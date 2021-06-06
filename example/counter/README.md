# counter

Redux version of the Flutter counter app.

This is a copy of the example program from [flutter_redux](https://github.com/brianegan/flutter_redux), with additional support for Remote Devtools.

- Uses DevToolsStore to allow time travel
- Connects to remote devtools on startup
- Sends all actions and state updates

## Trying it out

1.  Get [redux-devtools-cli](https://github.com/reduxjs/redux-devtools/tree/master/packages/redux-devtools-cli) from npm:

        npm install -g redux-devtools-cli

2.  Start the server

        redux-devtools --port=8000

3.  Edit `main.dart` and put in your computer's IP address or host name

4.  Open `http://localhost:8000` in a web browser. You should see the remote-devtools window

5.  Run the flutter app

        flutter packages get
        flutter run

6.  Hit that button, increment the counter, see the actions fly through

7.  Use the time travel slider to move back and forth through state changes!
