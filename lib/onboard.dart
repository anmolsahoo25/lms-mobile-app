import 'package:flutter/material.dart';
import 'login.dart';

class OnboardingPage extends StatelessWidget {
    build(context) {
      return Center(child: RaisedButton(
        onPressed: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginPage()
          )
        )
      ));
    }
}