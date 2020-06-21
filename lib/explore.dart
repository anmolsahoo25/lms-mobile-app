import 'package:flutter/material.dart';

class ExplorePage extends StatefulWidget {
  @override
  ExplorePageState createState() => ExplorePageState();
}

class ExplorePageState extends State<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Flexible(flex: 1, child: Container(color: Colors.grey[100], child: Center(child: Text('What will you learn today?', style: TextStyle(fontSize: 18))))),
        Flexible(flex: 1, child: Center(child: Padding(padding: EdgeInsets.all(16), child: 
          TextFormField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Type here to begin'
            )
          )
        ))),
        Flexible(flex: 3, child: GridView.extent(
          maxCrossAxisExtent: 200,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            Container(child: Padding(padding: EdgeInsets.all(16), child: Text('hello'))),
            Container(child: Padding(padding: EdgeInsets.all(16), child: Text('hello'))),
            Container(child: Padding(padding: EdgeInsets.all(16), child: Text('hello'))),
            Container(child: Padding(padding: EdgeInsets.all(16), child: Text('hello'))),
            Container(child: Padding(padding: EdgeInsets.all(16), child: Text('hello'))),
            Container(child: Padding(padding: EdgeInsets.all(16), child: Text('hello'))),
            Container(child: Padding(padding: EdgeInsets.all(16), child: Text('hello'))),
            Container(child: Padding(padding: EdgeInsets.all(16), child: Text('hello'))),
            Container(child: Padding(padding: EdgeInsets.all(16), child: Text('hello'))),
            Container(child: Padding(padding: EdgeInsets.all(16), child: Text('hello'))),
          ]
        )),
        Flexible(flex: 1, child: Padding(padding: EdgeInsets.all(16), child: Text('All categories'))),
        Flexible(flex: 3, child: GridView.extent(
          maxCrossAxisExtent: 200,
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Container(child: Padding(padding: EdgeInsets.all(16), child: Text('hello'))),
            Container(child: Padding(padding: EdgeInsets.all(16), child: Text('hello'))),
            Container(child: Padding(padding: EdgeInsets.all(16), child: Text('hello'))),
            Container(child: Padding(padding: EdgeInsets.all(16), child: Text('hello'))),
            Container(child: Padding(padding: EdgeInsets.all(16), child: Text('hello'))),
            Container(child: Padding(padding: EdgeInsets.all(16), child: Text('hello'))),
            Container(child: Padding(padding: EdgeInsets.all(16), child: Text('hello'))),
            Container(child: Padding(padding: EdgeInsets.all(16), child: Text('hello'))),
            Container(child: Padding(padding: EdgeInsets.all(16), child: Text('hello'))),
            Container(child: Padding(padding: EdgeInsets.all(16), child: Text('hello'))),
          ]
        )),
      ],
    ));
  }
}