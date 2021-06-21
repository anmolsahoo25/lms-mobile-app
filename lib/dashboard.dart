import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'course.dart';

class DashboardPage extends StatefulWidget {
  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.white,
          elevation: 1.0,
          title: Text('My Dashboard', style: TextStyle(color: Colors.grey[600])),
          centerTitle: true,
          pinned: true
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Enrolled Courses')
          )
        ),
        Query(
          options: QueryOptions(
            documentNode: gql("""
              {
	              mdlUserEnrolments {
                  mdlEnrolByEnrolid {
                    mdlCourseByCourseid {
                      id
                      fullname
                      summary
                      language
                    }
                  }
	              }
              }
            """),
          variables: {},
          pollInterval: 10000
          ),
          builder: (QueryResult result, {VoidCallback refetch, FetchMore fetchMore}) {
            if(result.loading) {
              return SliverToBoxAdapter(child: Center(child: Text('Loading...')));
            }

            if(result.hasException) {
              print(result.exception);
              return SliverToBoxAdapter(child: Center(child: Text('Error...')));
            }

            final courses = result.data['mdlUserEnrolments'];
            return courses.length == 0 ? 
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 8, left: 16, right: 16), 
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text('No courses enrolled yet!'))
                    )
                  )
                )
              ) : 
              SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if(index >= courses.length) {
                    return null;
                  } else {
                    return Padding(
                      padding: EdgeInsets.only(top: 8, left: 16, right: 16),
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CourseView(course: courses[index]['mdlEnrolByEnrolid']['mdlCourseByCourseid'])
                          )
                        ),
                        child: 
                          Card(child: ListTile(
                            leading: Container(height: 64, child: Image(image: AssetImage('assets/img/course-placeholder-cn.png'))),
                            title: Text(courses[index]['mdlEnrolByEnrolid']['mdlCourseByCourseid']['fullname']),
                            subtitle: Text(courses[index]['mdlEnrolByEnrolid']['mdlCourseByCourseid']['summary'].split('\n')[0])
                            )
                          )
                        )
                    );
                  }
                }
              ),
            );
          }
        ),
        /* ENROLLED CLASSES TODO
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(children: <Widget>[Divider(), Align(child: Padding(padding: EdgeInsets.only(top: 8), child: Text('Enrolled Classes')), alignment: Alignment.centerLeft)])
          )
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              if(index > 3) {
                return null;
              } else {
                return Padding(
                  padding: EdgeInsets.only(top: 8, left: 16, right: 16),
                  child: Card(child: ListTile(
                    leading: FlutterLogo(size: 32.0),
                    title: Text('okay then')
                  ))
                );
              }
            }
          ),
        )*/
      ],
    );
  }
}