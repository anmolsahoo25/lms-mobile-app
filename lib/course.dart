import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'activity.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CourseEnrollView extends StatefulWidget {
  CourseEnrollView({Key key, this.course, this.controller}) : super(key: key);

  final Map<String,dynamic> course;
  final PageController controller;

  createState() => CourseEnrollViewState();
}

class CourseEnrollViewState extends State<CourseEnrollView> {
  build(context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Query(
        options: QueryOptions(
          documentNode: gql(r'''
            query getEnrolment($cid: BigInt!) {
              mdlCourse(id:$cid) {
                id
                fullname
                summary
                language
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
          variables: {'cid' : int.parse(widget.course['id'])}
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
          if(result.data['mdlCourse']['mdlEnrolsByCourseid'].length == 0) {
            self = false;
            enrolled = false;
          } else if(result.data['mdlCourse']['mdlEnrolsByCourseid'].length == 1) {
            if(result.data['mdlCourse']['mdlEnrolsByCourseid'][0]['enrol'] == 'self') {
              self = true;
            }

            if(result.data['mdlCourse']['mdlEnrolsByCourseid'][0]['mdlUserEnrolmentsByEnrolid'].length == 1) {
              enrolled = true;
            } else {
              enrolled = false;
            }
          } else {
            self = false;
            enrolled = false;
          }

          var course = result.data['mdlCourse'];
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
                  /*
                  if(result['enrollCourseAsStudent']['boolean']) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => CourseView(course: course) 
                    ));
                  }
                  */
                },
                onError: (error) => print(error)
              ),
              builder: (runMutation, result) {
                return RaisedButton(
                  onPressed: () async {
                    runMutation({'cid' : int.parse(course['id'])});
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Enroll complete!"),
                          content: Text("Go to your dashboard to view the course"),
                          actions: <Widget>[
                            RaisedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("Go!")
                            )
                          ]
                        );
                      }
                    );
                    Navigator.of(context).pop();
                    widget.controller.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                  },
                  child: Text('Enroll Now!')
                );
              }
            );
          } else if (!enrolled && !self) {
            button = RaisedButton(child: Text('Enrol Now!'));
          } else if (enrolled) {
            button = RaisedButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => CourseView(course: widget.course)
                )
              ),
              child: Text('Open Course')
            );
          }

          return Column(children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 32, bottom: 16), 
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.all(Radius.circular(16))
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Image(image: AssetImage('assets/img/course-placeholder-cn.png'))
                )
              )
            ),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Align(alignment: Alignment.centerLeft, child: Text(course['fullname'], style: TextStyle(fontSize: 24))),
            ),
            Flexible(flex: 1, child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
              child: SingleChildScrollView(
                child: Text(course['summary'], textAlign: TextAlign.left)
              )
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                button
              ],
            )
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
  
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var prefs = await SharedPreferences.getInstance();
      var course = widget.course;
      var save = json.encode({
        'id' : course['id'],
        'fullname' : course['fullname'],
        'language' : course['language'],
        'summary' : course['summary']
      });
      await prefs.setString('lastAccessed', save);
    });
  }

  Widget build(BuildContext context) {

    var course = widget.course;

    return Scaffold(
      body:SafeArea(child:
      CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: InkWell(
              onTap: () => print('lol'),
              child: Card(child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal[50],
                      borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    child: Padding(padding: EdgeInsets.all(4), child: Image(image: AssetImage('assets/img/course-placeholder-cn.png'), height: 100))
                  )
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(course['fullname'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                      Text(course['summary'].split('\n')[0], textAlign: TextAlign.center),
                      Padding(padding: EdgeInsets.only(top: 16), child: Text('Tap here for full details', style: TextStyle(fontSize: 12, color: Colors.grey)))
                    ]
                  )
                ),
              ],
            )
          )
        ))),
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
                    sequence

                    mdlCourseModuleCompletionsByCoursemoduleid {
                      id
                    }
                  }

                  mdlCourseSectionsByCourse {
                    id
                    sequence
                    name
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
            var activities = result.data['mdlCourse']['mdlActivitiesByCourse'].toList();
            var sequence = result.data['mdlCourse']['mdlCourseSectionsByCourse'].toList();
            sequence.sort((a,b) {
              var id1 = int.parse(a['id']);
              var id2 = int.parse(b['id']);
              return id1.compareTo(id2);
            });
            List<List<String>> seqInd = sequence.map((e) => e['sequence'].split(',')).toList().cast<List<String>>();
            List<String> seqIndSorted = seqInd.expand((e) => e).toList();
            activities.sort((a,b) {
              var seq1 = a['sequence'];
              var seq2 = b['sequence'];
              int id1 = seqIndSorted.indexWhere((e) => e == seq1);
              int id2 = seqIndSorted.indexWhere((e) => e == seq2);
              return id1.compareTo(id2);
            });

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (builder, index) {
                  if (index > sequence.length -1) {
                    return null;
                  } else {
                    return TopicCard(section: sequence[index], index: index, activities: activities);
                  }
                }
              )
            );
            }
        )
      ]
    )));
  }
}

class TopicCard extends StatefulWidget {
  TopicCard({Key key, this.section, this.index, this.activities}) : super(key : key);

  final Map<String, dynamic> section;
  final int index;
  final List<dynamic> activities;

  createState() => TopicCardState();
}

class TopicCardState extends State<TopicCard> {
  
  bool collapsed = false;
  double cardHeight = null;

  initState() {
    super.initState();
  }

  build(context) {
    final section = widget.section;
    final index = widget.index;
    final activities = widget.activities;
    final List<String> sectionActivities = section['sequence'].split(',');
    
    return Padding(
      padding: EdgeInsets.all(8),
      child: Card(
        elevation: 2,
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16), child: 
                InkWell(
                  onTap: () {
                  },
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(section['name'] ?? 'Topic ' + index.toString(), style: TextStyle(fontSize: 18)),
                  collapsed ? FaIcon(FontAwesomeIcons.caretUp) : FaIcon(FontAwesomeIcons.caretDown)
                ]
              ))),
              AnimatedContainer(
                duration: Duration(milliseconds: 400),
                child: Column(
                children: activities.where((e) => sectionActivities.contains(e['sequence'])).map((e) => ActivityCard(activity: e)).toList().cast<Widget>()
              ))
                ]
              )
            )
      )
    );
  }
}

class ActivityCard extends StatelessWidget {
  ActivityCard({Key key, this.activity}) : super(key : key);

  final activity;

  FaIcon getIcon(int activity) {
    switch(activity) {
      case 13:
        return FaIcon(FontAwesomeIcons.book, color: Colors.orange);
      case 15:
        return FaIcon(FontAwesomeIcons.video, color: Colors.blue[300]);
        break;
      case 16:
        return FaIcon(FontAwesomeIcons.pencilAlt, color: Colors.green);
      default:
        return FaIcon(FontAwesomeIcons.box);
    }
  }

  build(context) {
    getIcon(activity['type']);
    return Column(
      children: <Widget>[
        Divider(), 
        InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return ActivityView(activity: activity);
              }
            )
          ),
          child: Padding(
            padding: EdgeInsets.all(4), 
            child: ListTile(
              title: Text(activity['name']),
              subtitle: Text(activity['intro']),
              leading: getIcon(activity['type']),
              trailing: activity['mdlCourseModuleCompletionsByCoursemoduleid'].length > 0 ? FaIcon(FontAwesomeIcons.checkSquare, color: Colors.green) : FaIcon(FontAwesomeIcons.square)
            )
          )
        )
      ]
    );
  }
}