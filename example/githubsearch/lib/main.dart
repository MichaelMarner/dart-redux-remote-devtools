import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'github_search_api.dart';
import 'github_search_widget.dart';
import 'redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:redux_dev_tools/redux_dev_tools.dart';
import 'package:redux_remote_devtools/redux_remote_devtools.dart';
import './SearchState.dart';

const REMOTE_HOST = '192.168.1.52:8000';

void main() async {
  var remoteDevtools = RemoteDevToolsMiddleware(REMOTE_HOST);
  await remoteDevtools.connect();
  final store = new DevToolsStore<SearchState>(searchReducer,
      initialState: SearchState.initial(),
      middleware: [
        remoteDevtools,
        EpicMiddleware<SearchState>(SearchEpic(GithubApi())),
      ]);

  remoteDevtools.store = store;

  runApp(new RxDartGithubSearchApp(
    store: store,
  ));
}

class RxDartGithubSearchApp extends StatelessWidget {
  final Store<SearchState> store;

  RxDartGithubSearchApp({Key key, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new StoreProvider<SearchState>(
      store: store,
      child: new MaterialApp(
        title: 'RxDart Github Search',
        theme: new ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.grey,
        ),
        home: new SearchScreen(),
      ),
    );
  }
}
