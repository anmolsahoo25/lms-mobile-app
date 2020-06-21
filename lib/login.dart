import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app.dart';

class LoginPage extends StatefulWidget {
  createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  Widget _loginWidget = UsernameLogin();
  bool _selected = false;

  initState() {
    super.initState();
    _loginWidget = UsernameLogin();
    _selected = true;
  }

  build(context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 2,
              child: Hero(
                tag: 'main-logo',
                child: FittedBox(child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:<Widget>[
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    child: Image(image: AssetImage('assets/img/logo.png'))
                  ),
                  Column(
                    children: <Widget>[
                      Text('Skill Live', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
                      Text('Learn a language. Earn an opportunity', style: TextStyle(fontSize: 16, color: Colors.grey))
                    ]
                  )
                ]
              )
            ))),
            Flexible(
              flex: 2,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: _loginWidget
              )
            ),
            Flexible(
              flex: 1,
              child: FittedBox(
                fit: BoxFit.fill, 
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      child: Row(children: <Widget>[
                        Padding(padding: EdgeInsets.only(right: 8), child: 
                          FaIcon(_selected ? FontAwesomeIcons.phoneAlt : FontAwesomeIcons.envelope, color: Colors.blue, size: 20)), 
                          _selected ? Text('Login with Phone') : Text('Login with Email')]), 
                      onPressed: () => setState(() { 
                        _loginWidget = _selected ? PhoneLogin() : UsernameLogin();
                        _selected = _selected ? false : true;
                      }), 
                      color: Colors.grey[200]
                      ),
                      FlatButton(
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 24)
                            ),
                            Text('Login with Google')]), onPressed: () => print('lol'), color: Colors.grey[200]),
                  ],
                )
              )
            ),
          ]
        )
      )
    );
  }
}

class UsernameLogin extends StatelessWidget {
  build(context) {
    return Center(child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(child: TextFormField(decoration: InputDecoration(hintText: 'Username')), padding: EdgeInsets.only(left: 32, right: 32)),
            Padding(child: TextFormField(decoration: InputDecoration(hintText: 'Password')), padding: EdgeInsets.only(left: 32, right: 32)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(child: Text('Login'), onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AppHome()))),
                RaisedButton(child: Text('Sign Up'), onPressed: () async {
                  var res = await FirebaseAuth.instance.signInWithEmailAndPassword(email: 'anmol.sahoo25@gmail.com', password: 'lolwa123');
                  print(res.user);
                })
              ]
            )
          ]
        )
      )
    );
  }
}

class PhoneLogin extends StatelessWidget {
  build(context) {
    return Center(child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(child: TextFormField(decoration: InputDecoration(hintText: 'Phone number')), padding: EdgeInsets.only(left: 32, right: 32)),
            Padding(child: TextFormField(decoration: InputDecoration(hintText: 'One-time password')), padding: EdgeInsets.only(left: 32, right: 32)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(child: Text('Send OTP'), onPressed: () => print('lol')),
                RaisedButton(child: Text('Login'), onPressed: () => print('lol'))
              ]
            )
          ]
        )
      )
    );
  }
}