import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AboutPage extends StatelessWidget {
  _runMe() async {
    print((await (await FirebaseAuth.instance.currentUser()).getIdToken()).token);
  }
  build(context) {
    _runMe();
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
            Icon(Icons.person, size: 128),
            Text('My Account')
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
        Flexible(flex: 1, child: OptionCard()),
        Divider(),
        Flexible(flex: 1, child: OptionCard()),
        Divider(),
        Flexible(flex: 1, child: OptionCard()),
        Divider(),
        Flexible(flex: 1, child: SignoutCard()),
      ]
    );
  }
}

class OptionCard extends StatelessWidget {
  build(contex) {
    return InkWell(
      onTap: () => print('lol'),
      child: Center(child: Padding(padding: EdgeInsets.only(left: 16, right: 16), child: Row(
      children: <Widget>[
        Icon(Icons.ac_unit, size: 32),
        Padding(padding: EdgeInsets.only(left: 32, right: 32), child: Center(child: Text('Option 1')))
      ],
    ))));
  }
}

class SignoutCard extends StatelessWidget {
  build(context) {
    return InkWell(
      onTap: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil("/", (route) => false);
      },
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Row(
            children: <Widget>[
              Icon(Icons.ac_unit, size: 32),
              Padding(padding: EdgeInsets.only(left: 32, right: 32), child: Center(child: Text('Sign Out')))
            ],
          )
        )
      )
    );
  }
}