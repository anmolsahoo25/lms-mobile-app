import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app.dart';

void main() => runApp(GraphQLApp());

class GraphQLApp extends StatelessWidget {
  static final HttpLink httpLink = HttpLink(
    uri: 'http://192.168.0.107:3000/graphql'
  );

  static final AuthLink authLink = AuthLink(
    getToken: () async => 
      'Bearer ' + (await (await FirebaseAuth.instance.currentUser()).getIdToken()).token
  );

  static final Link link = authLink.concat(httpLink);

  static final ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      cache: InMemoryCache(),
      link: link
    )
  );

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      child: MainApp(),
      client: client
    );
  }
}

class MainApp extends StatefulWidget {
  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skill Live',
      theme: ThemeData(
        fontFamily: 'NotoSans',
        primaryColor: Colors.red
      ),
      routes: {
        '/' : (BuildContext context) => App()
      }
    );
  }
}