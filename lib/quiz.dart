import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// models

class QuestionAnswerModel {
  QuestionAnswerModel(this.text, this.value, this.index);
  int index;
  String text;
  double value;
  bool selected = false;

  updateOption() {
    selected = !selected;
  }
  
  clear() {
    selected = false;
  }
}

class QuestionModel {
  QuestionModel(this.id, this.text, this.name, this.answers);
  final String id;
  final String name;
  final String text;
  int selected = -1;
  List<QuestionAnswerModel> answers;

  updateIndex(int index) {
    if (index == -1) {
      answers[index].updateOption();
      selected = index;
    } else {
      answers.forEach((a) => a.index == index ? null : a.clear());

      if(answers[index].selected) {
        selected = -1;
      } else {
        selected = index;
      }
      answers[index].updateOption();
    }
  }

  static QuestionModel fromQuestion(Map<String,dynamic> slot) {
    var answers = [];
    for(int i = 0; i < slot['mdlQuestionAnswersByQuestion'].length; i++) {
      var answer = slot['mdlQuestionAnswersByQuestion'][i];
      answers.add(QuestionAnswerModel(answer['answer'], double.parse(answer['fraction']), i));
    }
    QuestionModel question = QuestionModel(slot['id'], slot['questiontext'], slot['name'], answers.cast<QuestionAnswerModel>());

    return question;
  }
}

class AttemptModel {
  AttemptModel(this.timestamp, this.score);
  final String timestamp;
  final double score;
}

class QuizModel {
  String id;
  String name;
  String intro;
  double max;
  List<QuestionModel> questions;
  List<AttemptModel> attempts;
  
  static Future<QuizModel> initModel(String id, GraphQLClient client) async {
    var res = await client.query(QueryOptions(
      fetchPolicy: FetchPolicy.networkOnly,
      documentNode: gql(r'''
        query getQuiz($id: BigInt!) {
          mdlQuiz(id:$id) {
            id
            name
            intro
            sumgrades
            
            mdlQuizSlotsByQuizid {
              id
              mdlQuestionByQuestionid {
                id
                name
                questiontext
                mdlQuestionAnswersByQuestion {
                  id
                  answer
                  fraction
                }
              }
            }

            mdlQuizAttemptsByQuiz {
              id
              sumgrades
              timestart
            }
          }
        }
      '''),
      variables: {'id': int.parse(id)},
    ));
    var model = QuizModel();
    var mdlQuiz = res.data['mdlQuiz'];
    var mdlAttempts = mdlQuiz['mdlQuizAttemptsByQuiz'];
    var mdlQuestions = mdlQuiz['mdlQuizSlotsByQuizid'].map((e) => e['mdlQuestionByQuestionid']).toList();

    model.id = id;
    model.name = mdlQuiz['name'];
    model.intro = mdlQuiz['intro'];
    model.max = double.parse(mdlQuiz['sumgrades']);
    model.attempts = mdlAttempts.map((e) => AttemptModel(e['timestart'], double.parse(e['sumgrades']))).toList().cast<AttemptModel>();
    model.questions = mdlQuestions.map((e) => QuestionModel.fromQuestion(e)).toList().cast<QuestionModel>();
    return model;
  }

  double getScore() {
    double ret = 0;
    for(int i = 0; i < questions.length; i++) {
      ret += questions[i].answers[questions[i].selected].value;
    }

    return ret;
  }
}

// views
class QuestionAnswerView extends StatelessWidget {
  QuestionAnswerView({Key key, this.model}) : super(key : key);

  final QuestionAnswerModel model;

  build(context) {
    return Padding(padding: EdgeInsets.all(8), child: AnimatedContainer(
      duration: Duration(milliseconds: 100),
      curve: Curves.easeIn,
      decoration: BoxDecoration(
        border: Border.all(color: model.selected ? Colors.green : Colors.grey[200], width: 4),
        borderRadius: BorderRadius.circular(16)
      ),
      child: AnimatedPadding(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Center(child: Text(model.text, style: TextStyle(fontSize: 24)))
        ),
        duration: Duration(milliseconds: 100),
        curve: Curves.easeIn,
        padding: EdgeInsets.all(32)
      )
    ));
  }
}

class QuestionView extends StatelessWidget {
  QuestionView({Key key, this.model, this.index, this.controller}) : super(key : key);

  final QuestionModel model;
  final int index;
  final PageController controller;

  build(context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: <Widget>[
            Flexible(flex: 2, child: Padding(padding: EdgeInsets.all(16), child: Center(child: Text(model.text, style: TextStyle(fontSize: 24))))),
            Flexible(flex: 4, child: GridView.count(
              crossAxisCount: 2,
                children: <Widget>[
                  InkWell(child: QuestionAnswerView(model: model.answers[0]), onTap: () => setState(() => model.updateIndex(0))),
                  InkWell(child: QuestionAnswerView(model: model.answers[1]), onTap: () => setState(() => model.updateIndex(1))),
                  InkWell(child: QuestionAnswerView(model: model.answers[2]), onTap: () => setState(() => model.updateIndex(2))),
                  InkWell(child: QuestionAnswerView(model: model.answers[3]), onTap: () => setState(() => model.updateIndex(3))),
                ]
              )
            ),
            Flexible(flex: 1, child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(child: Text('Previous'), onPressed: () => index == 0 ? showDialogAndExit(context) : controller.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.easeIn)),
                  RaisedButton(child: Text('Next'), onPressed: !(model.selected == -1) ? () => controller.animateToPage(index + 2, duration: Duration(milliseconds: 500), curve: Curves.easeIn) : null)
                ]
              )
            )),
          ]
        );
      }
    );
  }
}

class QuizHomeView extends StatelessWidget {
  QuizHomeView({Key key, PageController controller, this.model}) : 
    _controller = controller,
    super(key : key);

  final PageController _controller;
  final QuizModel model;
  
  build(context) {
    return Column(
      children: <Widget>[
        Flexible(flex: 2, child: Container(child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(model.name, style: TextStyle(fontSize: 32))
        ))),
        Flexible(flex: 6, child: Padding(padding: EdgeInsets.only(top: 16, bottom: 16, left: 8, right: 8), child: 
        
          model.attempts.length == 0 ? Center(child: Text('Your Attempts', style: TextStyle(color: Colors.grey))) : ListView.builder(
          itemBuilder: (context, index) {
            Widget body;

            if(index > model.attempts.length - 1) {
              body = null;
            } else {
              body = Column(
                children: <Widget>[
                  Divider(),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(flex: 3, child: Column(
                          children: <Widget>[
                            Align(alignment: Alignment.centerLeft, child: Text("Attempt ${index+1}")),
                            Align(alignment: Alignment.centerLeft, child: Text(formatDate(model.attempts[index].timestamp))),
                          ],
                        )),
                        Flexible(flex: 1, child: Center(child: Text('${(model.attempts[index].score / model.max)*100} %', style: TextStyle(fontSize: 18)))),
                      ]
                    )
                  )
                ]
              );
            }
            return body;
          }
        ))),
        Flexible(flex: 2, child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(model.intro, textAlign: TextAlign.left),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(child: Text('Start Quiz'), onPressed: () => _controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn)),
                ]
              )
            ]
          )
        ))
      ],
    );
  }
}

class QuizEndView extends StatelessWidget {
  QuizEndView({Key key, PageController controller, this.index, this.model}) : 
    _controller = controller,
    super(key : key);

  final PageController _controller;
  final index;
  final QuizModel model;
  bool _submitted = false;
  bool _completed = false;

  build(context) {
    return StatefulBuilder(
      builder: (context, setState) => Column(
      children: <Widget>[
        Flexible(flex: 2, child: Container(child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Review Quiz', style: TextStyle(fontSize: 32))
        ))),
        Flexible(flex: 6, child: Padding(padding: EdgeInsets.only(top: 16, bottom: 16, left: 8, right: 8), child: ListView.builder(
          itemBuilder: (context, index) {
            Widget body;

            if(index > model.questions.length - 1) {
              body = null;
            } else {
              body = Column(
                children: <Widget>[
                  Divider(),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(flex: 6, child: Column(
                          children: <Widget>[
                            Align(alignment: Alignment.centerLeft, child: Text(model.questions[index].text)),
                            Align(alignment: Alignment.centerLeft, child: Text('Your answer: ' + model.questions[index].answers[model.questions[index].selected].text))
                          ],
                        )),
                        Flexible(flex: 1, child: AnimatedOpacity(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                          opacity: _submitted ? 1.0 : 0.0,
                          child: model.questions[index].answers[model.questions[index].selected].value == 0 ? FaIcon(FontAwesomeIcons.times, color: Colors.red) : FaIcon(FontAwesomeIcons.check, color: Colors.green)
                        ))
                      ]
                    )
                  )
                ]
              );
            }
            return body;
          }
        ))),
        Flexible(flex: 2, child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text('The quiz has ended. You can submit now or go back and re-attempt your questions.', textAlign: TextAlign.center,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  AnimatedOpacity(
                    opacity: !_submitted ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeIn,
                    child: RaisedButton(child: Text('Previous'), onPressed: () => _controller.animateToPage(index-1, duration: Duration(milliseconds: 500), curve: Curves.easeIn)),
                  ),
                  AnimatedOpacity(
                    opacity: _submitted ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeIn,
                    child: RaisedButton(child: Text('End Quiz'), onPressed: !_completed ? null : () {
                      Navigator.of(context, rootNavigator: true).pop();
                    })
                  ),
                  AnimatedOpacity(
                    opacity: !_submitted ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeIn,
                    child: Mutation(
                      options: MutationOptions(
                        documentNode: gql(r'''
                          mutation createAttempt($id : BigInt!, $score : BigFloat!) {
                            createNewQuizAttempt(input: { quizid : $id, score: $score }) {
                              boolean
                            }
                          }
                        '''),
                        onCompleted: (data) => data['createNewQuizAttempt']['boolean'] ? setState(() => _completed = true) : null
                      ),
                      builder: (runMutation, result) =>
                        RaisedButton(child: Text('Submit'), onPressed: () {
                          setState(() => _submitted = true);
                          runMutation({'id' : int.parse("1"), 'score': model.getScore()});
                        })
                    )
                  )
                ]
              )
            ]
          )
        ))
      ],
    ));
  }
}
class QuizView extends StatefulWidget {
  QuizView({Key key, this.id}) : super(key : key);
  final String id;
  createState() => QuizViewState();
}

class QuizViewState extends State<QuizView> {

  QuizModel _model;
  PageController _controller;
  
  initState() {
    super.initState();
    _controller = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var model = await QuizModel.initModel(widget.id, GraphQLProvider.of(context).value);
      setState(() => _model = model);
     });
  }

  dispose() {
    _controller.dispose();
    super.dispose();
  }

  build(context) {
    if(_model == null) {
      return Center(child: Text('loading'));
    } else {
      return WillPopScope(
          onWillPop: () => showDialogForExit(context),
          child: SafeArea(
            child: PageView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: _controller,
              itemBuilder: (context, index) {
                Widget body;

                if(index == 0) {
                  body = QuizHomeView(controller: _controller, model: _model);
                } else if((index - 1) < _model.questions.length) {
                  body = QuestionView(controller: _controller, index: index - 1, model: _model.questions[index-1]);
                } else {
                  body = QuizEndView(controller: _controller, index: index, model: _model);
                }
                
                return SafeArea(
                  child: body
                );
              },
            )
          )
        );
    }
  }
}

// utils
Future<bool> showDialogForExit(context) async {
  return await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      actions: <Widget>[
        RaisedButton(child: Text("Yes"), onPressed: () => Navigator.of(context, rootNavigator: true).pop(true), color: Colors.grey[500]),
        RaisedButton(child: Text("No"), onPressed: () => Navigator.of(context, rootNavigator: true).pop(false))
      ],
      title: Text('Are you sure?'),
      content: Text('You will lose progress if you leave'),
    )
  );
}

showDialogAndExit(context) async {
  var res = await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) => AlertDialog(
      actions: <Widget>[
        RaisedButton(child: Text("Yes"), onPressed: () => Navigator.of(context, rootNavigator: true).pop(true), color: Colors.grey[500]),
        RaisedButton(child: Text("No"), onPressed: () => Navigator.of(context, rootNavigator: true).pop(false))
      ],
      title: Text('Are you sure?'),
      content: Text('You will lose progress if you leave'),
    )
  );

  res ? Navigator.of(context, rootNavigator: true).pop() : null;
}

String formatDate(String timestamp) {
  int milliSecondsFromEpoch = int.parse(timestamp) * 1000;
  DateTime date = DateTime.fromMillisecondsSinceEpoch(milliSecondsFromEpoch);
  String ret = "${date.day}-${date.month}-${date.year}";
  return ret;
}