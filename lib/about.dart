import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutPage extends StatelessWidget {
  build(context) {
    return SafeArea(child: Column(
      children: <Widget>[
        Flexible(flex: 1, child: ProfilePanel()),
        Flexible(flex: 2, child: SettingsPanel())
      ],
    ));
  }
}

class ProfilePanel extends StatelessWidget {
  build(context) {
    return Stack(
      children: <Widget>[
        FractionallySizedBox(
          heightFactor: 1.0,
          child: Container(color: Colors.white)
        ),
        FractionallySizedBox(
          heightFactor: 0.5,
          child: Container()
        ),
        Align(
          alignment: Alignment.center,
          child: Container(child: Column(
            mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FaIcon(FontAwesomeIcons.user, size: 100),
          ]
        )))
      ]
    );
  }
}

class SettingsPanel extends StatelessWidget {
  build(context) {
    return Column(
      children: <Widget>[
        Divider(),
        Flexible(flex: 1, child: ProfileCard()),
        Divider(),
        Flexible(flex: 1, child: AboutCard()),
        Divider(),
        Flexible(flex: 1, child: SignoutCard()),
      ]
    );
  }
}

class ProfileCard extends StatelessWidget {
  build(contex) {
    return InkWell(
      onTap: () => print('lol'),
      child: Center(child: Padding(padding: EdgeInsets.only(left: 16, right: 16), child: Row(
      children: <Widget>[
        FaIcon(FontAwesomeIcons.cog, size: 32),
        Padding(padding: EdgeInsets.only(left: 32, right: 32), child: Center(child: Text('My Profile')))
      ],
    ))));
  }
}

class AboutCard extends StatelessWidget {
  build(contex) {
    return InkWell(
      onTap: () => print('lol'),
      child: Center(child: Padding(padding: EdgeInsets.only(left: 16, right: 16), child: Row(
      children: <Widget>[
        FaIcon(FontAwesomeIcons.infoCircle, size: 32),
        Padding(padding: EdgeInsets.only(left: 32, right: 32), child: Center(child: Text('About App')))
      ],
    ))));
  }
}

class SignoutCard extends StatelessWidget {
  build(context) {
    return InkWell(
      onTap: () async {
        var prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await FirebaseAuth.instance.signOut();
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil("/", (route) => false);
      },
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Row(
            children: <Widget>[
              FaIcon(FontAwesomeIcons.signOutAlt, size: 32),
              Padding(padding: EdgeInsets.only(left: 32, right: 32), child: Center(child: Text('Sign Out')))
            ],
          )
        )
      )
    );
  }
}