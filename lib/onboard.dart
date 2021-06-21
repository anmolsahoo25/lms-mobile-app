import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class OnboardingPage extends StatefulWidget {
  createState() => OnboardingPageState();
}

class OnboardingPageState extends State<OnboardingPage> {

  double index = 2;

  _setPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('firstTime', false);
  }

  build(context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          child: Column(
            children: <Widget>[
              Flexible(flex: 1, child: OnboardingPanel(text: 'Panel 1', image: 'img1', opacity: (index - 1.0))),
              Flexible(flex: 1, child: OnboardingPanel(text: 'Panel 1', image: 'img1', opacity: (index - 2.0))),
              Flexible(flex: 1, child: OnboardingPanel(text: 'Panel 1', image: 'img1', opacity: (index - 3.0))),
              Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                        child: Text('Next'),
                        onPressed: () {
                          setState(() {
                            if (index < 4) {
                              index += 1;
                            } else {
                              _setPrefs();
                              Navigator.of(context).pushReplacement(MaterialPageRoute(
                                builder: (context) => LoginPage()
                              ));
                            }
                          });
                        }
                      )
                    ]
              )
            ]
          )
        )
      )
    );
  }
}

class OnboardingPanel extends StatefulWidget {
  OnboardingPanel({Key key, this.text, this.image, this.opacity}) : super(key : key);

  final String text;
  final String image;
  double opacity;

  createState() => OnboardingPanelState();
}
class OnboardingPanelState extends State<OnboardingPanel> {

  build(context) {
    var text = widget.text;
    var image = widget.image;
    var opacity = widget.opacity;

    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
      opacity: opacity >= 1 ? 1 : 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Flexible(flex: 1, child: Image(image: AssetImage('assets/img/course-placeholder-cn.png'))),
          Flexible(flex: 1, child: Text(text))
        ],
      )
    );
  }
}