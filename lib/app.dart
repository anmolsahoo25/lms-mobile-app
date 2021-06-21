import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';
import 'dashboard.dart';
import 'explore.dart';
import 'about.dart';
import 'login.dart';
import 'onboard.dart';

class App extends StatefulWidget {
  AppState createState() => AppState();
}

class AppState extends State<App> {
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var prefs = await SharedPreferences.getInstance();
      var user = await FirebaseAuth.instance.currentUser();
      var firstTime = prefs.getBool('firstTime') ?? true;

      if (firstTime) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => OnboardingPage()));
        return;
      }

      if (user == null) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPage()));
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AppHome()));
      }
    });
  }

  build(context) {
    return Scaffold(
        body: Center(
            child: Hero(
                tag: 'logo-main',
                child: FractionallySizedBox(
                    heightFactor: 0.5,
                    widthFactor: 0.5,
                    child: Image(image: AssetImage('assets/img/logo.png'))))));
  }
}

class AppHome extends StatefulWidget {
  createState() => AppHomeState();
}

class AppHomeState extends State<AppHome> {
  int _currIndex;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currIndex = 0;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: (value) => setState(() => _currIndex = value),
            children: <Widget>[
              HomePage(controller: _pageController),
              DashboardPage(),
              ExplorePage(),
              AboutPage()
            ]),
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currIndex,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.home), title: Text('Home')),
              BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.bookReader),
                  title: Text('Learn')),
              BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.search),
                  title: Text('Explore')),
              BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.user), title: Text('Account'))
            ],
            onTap: (value) {
              setState(() => _currIndex = value);
              _pageController.animateToPage(value,
                  duration: Duration(milliseconds: 500), curve: Curves.easeIn);
            }));
  }
}
