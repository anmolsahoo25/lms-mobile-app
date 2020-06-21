import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AboutPage extends StatelessWidget {
  build(context) {
    return Center(
      child: RaisedButton(
        child: Text('Log Out'),
        onPressed: () async {
           await FirebaseAuth.instance.signOut();
        }
      )
    );
  }
}