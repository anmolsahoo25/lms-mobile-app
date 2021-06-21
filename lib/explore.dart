import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ExplorePage extends StatefulWidget {
  @override
  ExplorePageState createState() => ExplorePageState();
}

class ExplorePageState extends State<ExplorePage> {
  TextEditingController t1;
  List<dynamic> searchResults;

  initState() {
    super.initState();
    t1 = TextEditingController();
    searchResults = [];
  }

  dispose() {
    t1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Flexible(
          flex: 1, 
          child: Container(
            color: Colors.grey[100], 
            child: Center(child: Text('What will you learn today?', style: TextStyle(fontSize: 18))))),
        Flexible(
          flex: 1, 
          child: Row(
            children: <Widget>[
              Flexible(flex: 3, child: Padding(padding: EdgeInsets.all(16), child: TextFormField(
                controller: t1,
                decoration: InputDecoration(
                  hintText: "Type here to search courses"
                ),
              ))),
              Flexible(flex: 1, child: Padding(padding: EdgeInsets.all(16), child: RaisedButton(
                onPressed: () async {
                  var res = await GraphQLProvider.of(context).value.query(
                    QueryOptions(
                      documentNode: gql(r'''
                        query coursesByText($key : String!) {
                          mdlCoursesByText(key: $key) {
                            id
                            fullname
                            summary
                          }
                        }
                      '''),
                      pollInterval: 10000,
                      variables: {'key' : t1.value.text}
                    )
                  );
                  setState(() => searchResults = res.data['mdlCoursesByText']);
                },
                child: Icon(Icons.search)
              )))
            ]
          )
        ),
        Flexible(flex: 3, child: GridView.count(
          childAspectRatio: 1,
          crossAxisCount: 1,
          scrollDirection: Axis.horizontal,
          children: searchResults.map((e) {
            return InkWell(
                  onTap: null,
                  child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal[50],
                      borderRadius: BorderRadius.all(Radius.circular(16))
                    ),
                    child: Column(
                    children: <Widget>[
                      Expanded(child: Image(image: AssetImage('assets/img/course-placeholder-cn.png'))),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(e['fullname'])
                      )
                    ]
                  )
                )));
          }).toList().cast<Widget>()
        )),
        Flexible(flex: 1, child: Padding(padding: EdgeInsets.all(16), child: Text('All courses'))),
        Query(
          options: QueryOptions(
            documentNode: gql(r'''
              {
                mdlCourses {
                  id
                  fullname
                  summary
                }
              }
            '''),
            pollInterval: 10000,
            variables: {}
          ),
          builder: (result, {refetch, fetchMore}) {
            return result.loading ? 
              Center(child: SpinKitChasingDots(color: Colors.blue)) : 
              Flexible(flex: 4, child: GridView.builder(
              itemCount: result.data['mdlCourses'].length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                var courses = result.data['mdlCourses'];
                if (index > courses.length -1) {
                  return null;
                }

                return InkWell(
                  onTap: null,
                  child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal[50],
                      borderRadius: BorderRadius.all(Radius.circular(16))
                    ),
                    child: Column(
                    children: <Widget>[
                      Expanded(child: Image(image: AssetImage('assets/img/course-placeholder-cn.png'))),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(courses[index]['fullname'])
                      )
                    ]
                  )
                )));
              },
            ));
          }
        )
      ],
    ));
  }
}