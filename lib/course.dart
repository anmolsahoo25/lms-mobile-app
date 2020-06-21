import 'package:flutter/material.dart';
import 'activity.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CourseEnrollView extends StatelessWidget {
  CourseEnrollView({Key key, this.course}) : super(key: key);

  final Map<String,dynamic> course;

  build(context) {
    return SafeArea(
      child: Scaffold(body: Query(
        options: QueryOptions(
          documentNode: gql(r'''
            query getEnrolment($cid: BigInt!) {
              mdlCourse(id:$cid) {
                mdlEnrolsByCourseid {
                  id
                  enrol
                  mdlUserEnrolmentsByEnrolid {
                    id
                  }
                }
              }
            }
          '''),
          pollInterval: 10000,
          variables: {'cid' : course['id']}
        ),
        builder: (result, {refetch, fetchMore}) {
          if(result.loading) {
            return Center(child: Text('loading...'));
          }

          if(result.hasException) {
            return Center(child: Text('error...'));
          }
          
          bool enrolled;
          bool self;
          if (result.data['mdlCourse']['mdlEnrolsByCourseid'][0]['mdlUserEnrolmentsByEnrolid'].length == 0) {
            enrolled = false;
            if (result.data['mdlCourse']['mdlEnrolsByCourseid'][0]['enrol'] == 'self') {
              self = true;
            }
          } else {
            enrolled = true;
            self = false;
          }

          Widget button;

          if(!enrolled && self) {
            button = Mutation(
              options: MutationOptions(
                documentNode: gql(r'''
                  mutation enrollCourse($cid: BigInt!) {
                    enrollCourseAsStudent(input: {cid: $cid}) {
                      boolean
                    }
                  }
                '''),
                onCompleted: (result) {
                  if(result['enrollCourseAsStudent']['boolean']) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => CourseView(course: course) 
                    ));
                  }
                }
              ),
              builder: (runMutation, result) {
                return RaisedButton(
                  onPressed: () => runMutation({'cid' : course['id']}),
                  child: Text('Enroll Now!')
                );
              }
            );
          } else if (!enrolled && !self) {
            button = RaisedButton(child: Text('Enrol Now!'));
          } else if (enrolled) {
            button = RaisedButton(child: Text('Open Course'), onPressed: () =>
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => CourseView(course: course))
              )
            );
          }
          return Column(children: <Widget>[
            Flexible(flex: 1, child: Center(child: Image(image: AssetImage('assets/img/logo.png')))),
            Flexible(flex: 1, child: Column(
              children: <Widget>[
                Text(course['fullname']),
                Text(course['summary'])
              ],
            )),
            Flexible(flex: 1, child: Center(
              child: button
            ))
            ]
          );
        }
      )
    ));
  }
}
class CourseView extends StatefulWidget {
  CourseView({Key key, this.course}) : super (key : key);
  final Map<String,dynamic> course;
  @override
  CourseViewState createState() => CourseViewState();
}

class CourseViewState extends State<CourseView> {
  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return Scaffold(
      body:SafeArea(child:
      CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Hero(
            tag: 'tag1',
            child: Container(height: 200, child: Card(
              child: ListTile(
                leading: FlutterLogo(size: 56.0),
                title: Text(course['fullname']),
                subtitle: Text(course['summary']),
              )
            ),
          ))
        ),
        Query(
          options: QueryOptions(
            documentNode: gql(r'''
              query getCourseActivities($id: BigInt!) {
                mdlCourse(id : $id) {
                  mdlActivitiesByCourse {
                    id
                    name
                    intro
                    type
                  }
                }
              }
            '''),
            pollInterval: 10000,
            variables: <String,dynamic>{"id" : int.parse(course['id'])}
          ),
          builder: (result, {refetch, fetchMore}) {
            if (result.loading) {
              return SliverToBoxAdapter(child: Text('loading...'));
            }

            if (result.hasException) {
              return SliverToBoxAdapter(child: Text('error...'));
            }

            var activities = result.data['mdlCourse']['mdlActivitiesByCourse'];
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
              if (index >= activities.length) {
                return null;
              }
              
              final activity = activities[index];
              return Column(children: <Widget>[Divider(), 
              InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return ActivityView(activity: activity);
                    }
                  )
                ),
                child: Padding(padding: EdgeInsets.all(16), child: ListTile(
                title: Text(activity['name']),
                subtitle: Text(activity['intro']),
                leading: Icon(Icons.access_alarm),
              )))]);
            }
          )
        );}
        )
      ]
    )));
  }
}