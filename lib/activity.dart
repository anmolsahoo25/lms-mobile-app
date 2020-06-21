import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'quiz.dart';

class ActivityView extends StatelessWidget {
  ActivityView({Key key, this.activity}) : super(key : key);

  final Map<String, dynamic> activity;
  
  Widget build(context) {
    print(activity);

    Widget body;

    switch(activity['type']) {
      case(15):
        // page
        body = VideoContentView(activity: activity);
        break;
      case(16):
        // quiz
        body = QuizView(id: activity['id']);
        break;
      default:
        body = Center(child: Text('Not implemented'));
        break;
    }

    return Scaffold(
      body: body
    );
  }
}

class VideoContentView extends StatelessWidget {
  VideoContentView({Key key, this.activity}) : super(key : key);

  final Map<String, dynamic> activity;
  
  Widget build(BuildContext context) {
    final String query = r'''
              query getPage($id: BigInt!) {
                mdlPage(id : $id) {
                  name
                  intro
                  content
                }
              }
            ''';
    return Scaffold(
      body: SafeArea(
        child: Query(
          options: QueryOptions(
            documentNode: gql(query),
            variables: <String,dynamic> {"id": int.parse(activity['id'])},
            pollInterval: 100,
          ),
          builder: (QueryResult result, { VoidCallback refetch, FetchMore fetchMore }) {
            if (result.loading) {
              return Center(child: Text('loading'));
            }

            if (result.hasException) {
              print(result.exception);
              return Center(child: Text('error'));
            }

            final data = result.data;
            final page = data['mdlPage'];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Flexible(flex: 4, child: Container(color: Colors.grey, child: Center(child: Text('video content')))),
                Flexible(flex: 4, child: Container(color: Colors.white, child: Center(child: Text(page['content'])))),
                Flexible(flex: 1, child: Container(color: Colors.white, child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(onPressed: () => print('lol'), child: Text('Mark completed'))
                    ]
                  )
                ))
              ],
            );
          }
        )
      )
    );
  }
}