import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

enum LoginMethod {Username, Phone}

class LoginPage extends StatefulWidget {
  createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  LoginMethod _method = LoginMethod.Username;

  initState() {
    super.initState();
  }

  void _swapMethod() {
    setState(() => _method == LoginMethod.Username ? _method = LoginMethod.Phone : _method = LoginMethod.Username);
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
              child: TopPanel()
            ),
            Flexible(
              flex: 2,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: _method == LoginMethod.Username ? UsernameLogin() : PhoneLogin()
              )
            ),
            Flexible(
              flex: 1,
              child: LoginMethodList(method: _method, swapMethod: _swapMethod)
            ),
          ]
        )
      )
    );
  }
}

// Stages of login
// Stage1 : insert username and check if methods exist
// Stage2n : user does not exist, prompt method
// Stage2op : user exists, password
// Stage2ol : user exists, email link
// Stage3c : create user with password

enum UsernameLoginStage {Stage1, Stage2n, Stage2op, Stage2ol, Stage3c, Loading, ForgotPassword}

class UsernameLogin extends StatefulWidget {
  createState() => UsernameLoginState();
}

class UsernameLoginState extends State<UsernameLogin> {
  TextEditingController c1 = TextEditingController();
  TextEditingController c2 = TextEditingController();

  UsernameLoginStage s = UsernameLoginStage.Stage1;

  Widget getStartedButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          child: Text('Get started'),
          onPressed: () async {
            setState(() => s = UsernameLoginStage.Loading);
            var email = c1.value.text;
            var methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email: email);
            if (methods.length == 0) {
              setState(() => s = UsernameLoginStage.Stage2n);
            } else if (methods.length == 1) {
              // signin exists
              
              // password
              if (methods[0] == 'password') {
                setState(() => s = UsernameLoginStage.Stage2op);
              }
            }
          }
        )
      ]
    );
  }

  Widget loginButtonRow() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              child: Text('Go Back'),
              onPressed: () async {
                c1.clear();
                c2.clear();
                setState(() => s = UsernameLoginStage.Stage1);
              },
              color: Colors.grey[200]
            ),

            RaisedButton(
              child: Text('Sign In'),
              onPressed: () async {
                var email = c1.value.text;
                var password = c2.value.text;

                setState(() => s = UsernameLoginStage.Loading);

                try {
                  var res = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

                  if(res.user == null) {
                    await showDialog(
                      context: context, 
                      barrierDismissible: true,
                      builder: (context) => AlertDialog(
                        title: Text('Wrong password'),
                        content: Text('Please re-enter your password or reset it'),
                        actions: <Widget>[
                          RaisedButton(child: Text('Go back'), onPressed: () {
                            setState(() => s = UsernameLoginStage.Stage2op);
                            Navigator.of(context).pop();
                          })
                        ]
                      )
                    );
                  } else {
                    // check is user exists in database
                    await checkUserExists(context);
                    await setUserClaims(context);
                    Navigator.of(context).pushReplacementNamed("/");
                  }
                } catch(e) {
                  c2.clear();
                  await showDialog(
                    context: context, 
                    barrierDismissible: true,
                    builder: (context) => AlertDialog(
                      title: Text('Wrong password'),
                      content: Text('Please re-enter your password or reset it'),
                      actions: <Widget>[
                          RaisedButton(child: Text('Go back'), onPressed: () {
                            setState(() => s = UsernameLoginStage.Stage2op);
                            Navigator.of(context).pop();
                          })
                        ]
                    )
                  );
                }
              }
            )
          ]
        ),
        Center(
          child: RaisedButton(
            child: Text('Reset password'),
            onPressed: () async {
              setState(() => s = UsernameLoginStage.Loading);
              await FirebaseAuth.instance.sendPasswordResetEmail(email: c1.value.text);
              setState(() => s = UsernameLoginStage.ForgotPassword);
            }
          )
        )
      ]
    );
  }

  Widget signupMethodButtonRow() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Flexible(flex: 1, child: Padding(padding: EdgeInsets.all(8), child: RaisedButton(
              child: Text('Sign Up with \n Email Link', textAlign: TextAlign.center),
              onPressed: () async {
                print('lol');
              },
              color: Colors.grey[200]
            ))),

            Flexible(flex: 1, child: Padding(padding: EdgeInsets.all(8), child: RaisedButton(
              child: Text('Sign Up with Password', textAlign: TextAlign.center),
              onPressed: () async {
                setState(() => s = UsernameLoginStage.Stage3c);
              }
            )))
          ]
        ),
        Center(
          child: RaisedButton(
            child: Text('Go back'),
            onPressed: () async {
              setState(() => s = UsernameLoginStage.Stage1);
            }
          )
        )
      ]
    );
  }

  Widget signUpButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          color: Colors.grey[200],
          child: Text('Go Back'),
          onPressed: () => setState(() {
            c1.clear();
            c2.clear();
            s = UsernameLoginStage.Stage1;
            }
          )
        ),
        RaisedButton(
          child: Text('Sign Up'),
          onPressed: () async {
            setState(() => s = UsernameLoginStage.Loading);
            var email = c1.value.text;
            var password = c2.value.text;

            try {
              var res = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
              await checkUserExists(context);
              await setUserClaims(context);
              Navigator.of(context).pushReplacementNamed("/");
            } catch(e) {
              print(e);
              await showDialog(
                context: context, 
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: Text('Account creation failed'),
                  content: Text('Please try again'),
                  actions: <Widget>[
                    RaisedButton(child: Text('Go back'), onPressed: () => Navigator.of(context).pop())
                  ]
                )
              );
              Navigator.of(context).pushReplacementNamed("/");
            }
          }
        )
      ]
    );
  }

  Widget buttonRow() {
    Widget ret;
    switch(s) {
      case(UsernameLoginStage.Loading):
        ret = Center(child: SpinKitFadingCircle(color: Colors.blue));
        break;
      case(UsernameLoginStage.Stage1):
        ret = getStartedButtonRow();
        break;
      case(UsernameLoginStage.Stage2n):
        ret = signupMethodButtonRow();
        break;
      case(UsernameLoginStage.Stage2op):
        ret = loginButtonRow();
        break;
      case(UsernameLoginStage.Stage3c):
        ret = signUpButtonRow();
        break;
      case(UsernameLoginStage.ForgotPassword):
        ret = Container();
        break;
    }

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: ret
    );
  }

  Widget formRow() {
    Widget ret;
    switch(s) {
      case(UsernameLoginStage.Loading):
        ret = Container();
        break;
      case(UsernameLoginStage.Stage1):
        ret = Padding(
          child: TextFormField(
            controller: c1,
            decoration: InputDecoration(hintText: 'Enter your email')
          ),
          padding: EdgeInsets.only(left: 32, right: 32)
        );
        break;
      case(UsernameLoginStage.Stage2n):
        ret = Padding(
          child: TextFormField(
            controller: c1,
            decoration: InputDecoration(hintText: 'Enter your email')
          ),
          padding: EdgeInsets.only(left: 32, right: 32)
        );
        break;
      case(UsernameLoginStage.Stage2op):
        ret = Column(
          children: <Widget>[
            Padding(
              child: TextFormField(
                controller: c1, 
                decoration: InputDecoration(hintText: 'Enter your email'),
                enabled: false
              ),
              padding: EdgeInsets.only(left: 32, right: 32)
            ),
            Padding(
              child: TextFormField(
                controller: c2, 
                obscureText: true,
                decoration: InputDecoration(hintText: 'Enter your password')
              ),
            padding: EdgeInsets.only(left: 32, right: 32)
            )
          ]
        );
        break;
        case(UsernameLoginStage.Stage3c):
          ret = Column(
            children: <Widget>[
              Padding(
                child: TextFormField(
                  controller: c1, 
                  decoration: InputDecoration(hintText: 'Enter your email'),
                  enabled: false
                ),
                padding: EdgeInsets.only(left: 32, right: 32)
              ),
              Padding(
                child: TextFormField(
                  controller: c2, 
                  obscureText: true,
                  decoration: InputDecoration(hintText: 'Enter your password')
                ),
              padding: EdgeInsets.only(left: 32, right: 32)
              )
            ]
          );
          break;
        case(UsernameLoginStage.ForgotPassword):
          ret = Center(child: Text('A password reset link has been sent to the email'));
          break;
    }

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: ret
    );
  }

  build(context) {
    return Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              formRow(),
              buttonRow()
            ]
        )
      )
    );
  }
}

class PhoneLogin extends StatelessWidget {
  bool _enabled = false;

  TextEditingController t1 = TextEditingController();
  TextEditingController t2 = TextEditingController();

  String _id = '';

  build(context) {
    return StatefulBuilder(
      builder: (context, setState) => Center(child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(child: TextFormField(controller: t2, decoration: InputDecoration(hintText: 'One-time password'), enabled: _enabled), padding: EdgeInsets.only(left: 32, right: 32)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(child: Text('Send OTP'), onPressed: () async {
                  var phone = t1.value.text;
                  var auth = FirebaseAuth.instance;

                  auth.verifyPhoneNumber(
                    phoneNumber: '+91' + phone, 
                    timeout: Duration(seconds: 0), 
                    verificationCompleted: (credential) async {
                      var res = await auth.signInWithCredential(credential);
                      print(res.user.email);
                    }, 
                    verificationFailed: (exception) async {

                    }, 
                    codeSent: (s, [int p = 0]) {
                      print('code sent');
                    },
                    codeAutoRetrievalTimeout: (id) async {
                      setState(() => _enabled = true);
                      setState(() => _id = id);
                    }
                  );
                }),
                RaisedButton(child: Text('Login'), onPressed: !_enabled ? null : () async {
                  var credential = PhoneAuthProvider.getCredential(verificationId: _id, smsCode: t2.value.text);
                  var res = await FirebaseAuth.instance.signInWithCredential(credential);
                  
                  if(res.user.email == null) {
                    await res.user.updateEmail('f2013294@goa.bits-pilani.ac.in');
                    GraphQLProvider.of(context).value
                    .mutate(
                    MutationOptions(
                      documentNode: gql(r'''
                        mutation {
                          createUser(input: {}) {
                            mdlUser {
                              username
                            }
                          }
                        }
                      '''),
                      onCompleted: (data) async {
                        print(data);
                        if(data['createUser']['mdlUser'] == null) {
                          print("null route");
                          Navigator.of(context).pushReplacementNamed("/");
                        } else {
                          var idToken = (await ((await FirebaseAuth.instance.currentUser()).getIdToken())).token;
                          var res = await http.post(
                            'http://192.168.0.107:3000/setclaims',
                            headers: {'Authorization' : 'Bearer ' + idToken }
                          );
                          print((await ((await FirebaseAuth.instance.currentUser()).getIdToken(refresh: true))).token);
                          Navigator.of(context).pushReplacementNamed("/");
                        }
                      },
                      onError: (error) => print(error)
                    )
                  );
                  } else {
                    Navigator.of(context).pushReplacementNamed("/");
                  }
                })
              ]
            )
          ]
        )
      )
    ));
  }
}

class TopPanel extends StatelessWidget {
  build(context) {
    return FittedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:<Widget>[
          Container(
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
    );
  }
}

class LoginMethodList extends StatelessWidget {

  LoginMethodList({Key key, this.method, this.swapMethod}) : super(key : key);

  final method;
  final swapMethod;

  FaIcon selectedIcon() {
    return FaIcon(
      method == LoginMethod.Username ? FontAwesomeIcons.phoneAlt : FontAwesomeIcons.envelope,
      color: Colors.blue,
      size: 20
    );
  }

  Text selectedText() {
    return method == LoginMethod.Username ? Text('Sign in with Phone') : Text('Sign in with Email');
  }

  build(context) {
    return FittedBox(
      fit: BoxFit.fill, 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FlatButton(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: selectedIcon()
                ), 
                selectedText()
              ]
            ),           
            onPressed: () => swapMethod(),
            color: Colors.grey[200]
          ),
          FlatButton(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 24)
                ),
                Text('Login with Google')]), onPressed: () => print('lol'), color: Colors.grey[200]
          ),
        ],
      )
    );
  }
}

checkUserExists(context) async {
  GraphQLProvider.of(context).value.mutate(
    MutationOptions(
      documentNode: gql(r'''
        mutation {
          createUser(input: {}) {
            mdlUser {
              username
            }
          }
        }
      '''),
      onCompleted: (data) async { },
      onError: (error) async { }
    )  
  );
}

setUserClaims(context) async {
  var idToken = (await ((await FirebaseAuth.instance.currentUser()).getIdToken())).token;
  var res = await http.post(
    'http://192.168.0.107:3000/setclaims',
    headers: {'Authorization' : 'Bearer ' + idToken}
  );
  print(res.body);

  while(true) {
    (await ((await FirebaseAuth.instance.currentUser()).getIdToken(refresh: true))).token;
    var res = (await (await FirebaseAuth.instance.currentUser()).getIdToken()).claims;
    if(res['role'] == null) {} else {break;}
  }
  
}