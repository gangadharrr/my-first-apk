import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

import './question.dart';
import './answer.dart';

var APIkey = '2af789c41b934be69f4777295e83362d';
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<Position> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      return Position(
          longitude: 0,
          latitude: 0,
          altitude: 0,
          timestamp: DateTime.now(),
          accuracy: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0);
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  Future<dynamic> getWeatherDaily() async {
    String? _currentAddress;
    Position? _currentPosition = await _getCurrentPosition();
    var url =
        "https://api.openweathermap.org/data/2.5/forecast?lat=${await _currentPosition?.latitude}&lon=${await _currentPosition?.longitude}&appid=$APIkey&units=metric";
    var response = await http.get(Uri.parse(url));
    var data = jsonDecode(response.body);
    print("$url,${data['city']['name']}");
    return data;
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
  late Future<dynamic> temp;
  late Future<String> img;
  late Future<List> ApiResults;
  String? _currentAddress;
  Position? _currentPosition;
  @override
  void initState() {
    super.initState();
    temp = getWeatherDaily();
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
      _getCurrentPosition();
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
                  FutureBuilder<dynamic>(
                      future: temp,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                              "City: ${snapshot.data['city']['name']}\nTemperature: ${snapshot.data['list'][0]['main']['temp'].toString()}\nCoordinates:\nLatitude:${snapshot.data['city']['coord']['lat'].toString()}, Longitude:${snapshot.data['city']['coord']['lon'].toString()}",
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
