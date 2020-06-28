import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'course.dart';
import 'image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatelessWidget {
  HomePage({Key key, this.controller}) : super(key : key);

  final PageController controller;

  build(context) {
    return SafeArea(child: CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: false,
          expandedHeight: 100,
          centerTitle: true,
          elevation: 20,
          backgroundColor: Colors.grey[50],
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Container(
              color: Colors.white,
              child: Align(
                alignment: Alignment.center,
                child: Text('Skill Live', style: TextStyle(fontSize: 32, color: Colors.grey[600], fontWeight: FontWeight.w700))
              )
            )
          )
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 16, left: 12, right: 12),
            child: Column(children: <Widget>[Align(alignment: Alignment.centerLeft, child: Text('My courses', style: TextStyle(fontSize: 18)))])
          )
        ),
        LatestCoursePanel(),
        /* UPCOMING EVENTS TODO
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 16, left: 12, bottom: 16, right: 12),
            child: Column(children: <Widget>[Align(alignment: Alignment.centerLeft, child: Text('Upcoming events', style: TextStyle(fontSize: 18)))])
          )
        ),
        */
        /* NOTIFICATIONS TODO
        SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.only(left: 12, right: 12), child: Column(
            children: <Widget>[
              Card(child: ListTile(leading: FlutterLogo(size: 24), title: Text('item 1'))),
              Card(child: ListTile(leading: FlutterLogo(size: 24), title: Text('item 2'))),
              Card(child: ListTile(leading: FlutterLogo(size: 24), title: Text('item 3')))
            ],
          )
        )),
        */
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 16, left: 12, bottom: 16, right: 12),
            child: Column(children: <Widget>[Align(alignment: Alignment.centerLeft, child: Text('Explore', style: TextStyle(fontSize: 18)))])
          )
        ),
        Query(
          options: QueryOptions(
            documentNode: gql(r'''
              {
                mdlCoursesTrending {
                  id
                  fullname
                  language
                  summary
                }
              }
            '''),
            pollInterval: 100,
            variables: {}
          ),
          builder: (result, {refetch, fetchMore}) => SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              childAspectRatio: 1
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if(result.hasException) {
                  return Container();
                }

                if (result.loading) {
                  return Container();
                }

                var courses = result.data['mdlCoursesTrending'];

                if (index > courses.length-1) {
                  return null;
                }

                var imgString;

                switch(courses[index]['language']) {
                  case('fr'):
                    imgString = 'assets/img/course-placeholder-fr.png';
                    break;
                  case('cn'):
                    imgString = 'assets/img/course-placeholder-cn.png';
                    break;
                  default:
                    imgString = 'assets/img/course-placeholder.png';
                    break;
                }

                return InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CourseEnrollView(course: courses[index], controller: controller)
                    )
                  ),
                  child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal[50],
                      borderRadius: BorderRadius.all(Radius.circular(16))
                    ),
                    child: Column(
                    children: <Widget>[
                      Expanded(child: Image(image: AssetImage(imgString))),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(courses[index]['fullname'])
                      )
                    ]
                  )
                )));
              },
              childCount: 4
            )
          ),
        )
      ]
    ));
  } 
}

class LatestCoursePanel extends StatefulWidget {
  createState() => LatestCoursePanelState();
}

class LatestCoursePanelState extends State<LatestCoursePanel> {
  Map<String,dynamic> lastAccessed;

  _loadLatestCourse() async {
    var prefs = await SharedPreferences.getInstance();
    var course = json.decode(prefs.getString('lastAccessed'));
    if(course['id'] == null || course['fullname'] == null || course['language'] == null || course['summary'] == null) {

    } else {
      setState(() => lastAccessed = course);
    }
  }
  
  _latestCourseCard() {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => CourseView(course: lastAccessed)
        )
      ),
      child: Card(
        child: ListTile(
          leading: Container(
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.all(Radius.circular(8))
            ),
            child: Padding(padding: EdgeInsets.all(4), child: Image(image: AssetImage('assets/img/course-placeholder-cn.png')))
          ),
          title: Text(lastAccessed['fullname']),
          subtitle: Text('Resume course'),
          trailing: Icon(Icons.chevron_right),
        ),
      )
    );
  }

  _noCourseCard() {
    return Card(
      child: FractionallySizedBox(
        widthFactor: 0.75,
        child: Padding(padding: EdgeInsets.all(16), child: Center(child: Text('Your latest accessed course will show up here', textAlign: TextAlign.center)))
      )
    );
  }

  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLatestCourse();
    });
  }

  build(context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: 16, left: 8, right: 8),
        child: lastAccessed == null ? _noCourseCard() : _latestCourseCard()
      )
    );
  }
}