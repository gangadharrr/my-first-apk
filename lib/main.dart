import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import './question.dart';
import './answer.dart';

var APIkey = '2af789c41b934be69f4777295e83362d';
void main() {
  runApp(MyApp());
}

Future<double> getWeatherDaily(lat, lon) async {
  var response = await http.get(Uri.parse(
      "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$APIkey&units=metric"));
  var data = jsonDecode(response.body);
  return data['list'][0]['main']['temp'];
}

Future<String> getRickNdMorty(num) async {
  var reponse1 = await http
      .get(Uri.parse("https://rickandmortyapi.com/api/character/$num"));
  var data1 = jsonDecode(reponse1.body);
  return data1['image'];
}

Future<String> getRickNdMortyAll(num) async {
  var reponse1 = await http
      .get(Uri.parse("https://rickandmortyapi.com/api/character/$num"));
  var data1 = jsonDecode(reponse1.body);
  return data1['image'];
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  var questions = [
    'What is the name of Greatest Person?',
    'What is the age of Greatest Person?',
    'What is the profession of Greatest Person?',
    'What is the skill of Greatest Person?'
  ];
  var answers = [
    [
      ['Abdullah', 'Rahaman', 'Gangadhar'],
      [2]
    ],
    [
      ['20', '21', '22'],
      [1]
    ],
    [
      ['Librarian', 'Software Engineer', 'Scientist'],
      [1]
    ],
    [
      ['Intelligent', 'Kind', 'Brave'],
      [0]
    ]
  ];
  late Future<double> temp;
  late Future<String> img;
  late Future<List> ApiResults;
  @override
  void initState() {
    super.initState();
    temp = getWeatherDaily(12.91547, 77.61278);
    img = getRickNdMorty(questionIndex + 1);
  }

  int questionIndex = 0;
  int score = 0;
  bool visible = false;
  resetState() {
    setState(() {
      questionIndex = 0;
      score = 0;
      visible = false;
      img = getRickNdMorty(questionIndex + 1);
    });
  }

  answerQuestions(int answer, int actualAnswer) {
    setState(() {
      if (questionIndex < questions.length - 1) {
        questionIndex = (questionIndex + 1);
      } else if (questionIndex == questions.length - 1) {
        visible = true;
      } else {
        visible = false;
      }
      if ((questionIndex < questions.length) && (answer == actualAnswer)) {
        score++;
      }
      img = getRickNdMorty(questionIndex + 1);
    });
    print(questionIndex);
    print(score);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text('My First App'),
            ),
            body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Question(questions[questionIndex]),
                  Answer(answers[questionIndex], answerQuestions),
                  ElevatedButton(
                      onPressed: resetState,
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red)),
                      child: Text('Reset')),
                  Visibility(
                    visible: visible,
                    child: Text('Score: $score',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center),
                  ),
                  FutureBuilder<double>(
                      future: temp,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                              'Temperature: ${snapshot.data.toString()}',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center);
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        }
                        return const CircularProgressIndicator();
                      }),
                  FutureBuilder<String>(
                    future: img,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.network(snapshot.data.toString());
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }

                      // By default, show a loading spinner.
                      return const CircularProgressIndicator();
                    },
                  ),
                ])));
  }
}
