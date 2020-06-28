import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'quiz.dart';
import 'image.dart';

class ActivityView extends StatelessWidget {
  ActivityView({Key key, this.activity}) : super(key : key);

  final Map<String, dynamic> activity;
  
  Widget build(context) {

    Widget body;

    switch(activity['type']) {
      case(13):
        // lesson
        body = LessonView(activity: activity);
        break;
      case(15):
        // page
        body = SinglePageView(activity: activity);
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

class LessonView extends StatefulWidget {
  LessonView({Key key, this.activity}) : super(key : key);

  final activity;

  createState() => LessonViewState();
}

class LessonViewState extends State<LessonView> {

  PageController controller = PageController();

  build(context) {
    return Scaffold(
      body: SafeArea(
        child: Query(
          options: QueryOptions(
            documentNode: gql(r'''
              query getLesson($id: BigInt!) {
                mdlLesson(id: $id) {
                  mdlLessonPagesByLessonid {
                    id
                    contents
                  }
                }
              }
            '''),
            pollInterval: 10000,
            variables: {'id' : widget.activity['id']}
          ),
          builder: (result, {refetch, fetchMore}) {
            var pages = result.data['mdlLesson']['mdlLessonPagesByLessonid'];
            return PageView.builder(
              controller: controller,
              itemBuilder: (context, index) {
                if(index > pages.length - 1) {
                  return null;
                }

                List<Widget> navRow;

                if(index == pages.length - 1) {
                  navRow = [
                    RaisedButton(
                      child: Text('Mark Completed')
                    )
                  ];
                } else {
                  navRow = [
                    Icon(Icons.arrow_left),
                    Text('Swipe to view more pages', style: TextStyle(color: Colors.grey)),
                    Icon(Icons.arrow_right)
                  ];
                }

                return Column(
                  children: <Widget>[
                    Expanded(child: Markdown(
                      data: pages[index]['contents'],
                      imageBuilder: (uri,title,alt) {
                        return ImageWidget(imgUrl: 'placeholder.png');
                      },
                    )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: navRow 
                    )
                  ]
                );
              },
            );
          }
        )
      )
    );
  }
}

class LessonPageView extends StatelessWidget {
  LessonPageView({Key key, this.page}) : super(key : key);

  final page;

  build(context) {
    return Markdown(
      data: page['contents'],
    );
  }
}

class SinglePageView extends StatelessWidget {
  SinglePageView({Key key, this.activity}) : super(key : key);

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
              return Center(child: Text('error'));
            }

            final page = result.data['mdlPage'];
            return Markdown(
              data: page['content']
            );
          }
        )
      )
    );
  }
}