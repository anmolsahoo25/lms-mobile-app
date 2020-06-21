import 'package:flutter/material.dart';
import 'course.dart';
import 'image.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              color: Theme.of(context).primaryColor,
              child: Align(
                alignment: Alignment.center,
                child: Text('Skill Live', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w700))
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
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 16, left: 8, right: 8),
            child: InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => CourseEnrollView(course: {'id': '3', 'fullname': 'Chinese', 'summary': 'lol'})
              )),
              child: Hero(tag:'tag1', child: Card(
              child: ListTile(
                leading: FlutterLogo(size: 56.0),
                title: Text('Let\'s say Ni Hao'),
                subtitle: Text('Resume course'),
                trailing: Icon(Icons.chevron_right),
              ),
            )
          ),
        ))),
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
        SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200.0,
            mainAxisSpacing: 0.0,
            crossAxisSpacing: 0.0,
            childAspectRatio: 1.0,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.all(16),
                child: FittedBox(fit: BoxFit.contain, child: ImageWidget(imgUrl: 'placeholder.png'))
              );
            },
          childCount: 4,
          ),
        ),
      ]
    ));
  } 
}