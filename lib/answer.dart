import 'package:flutter/material.dart';

class Answer extends StatelessWidget {
  final List answerText;
  final Function(int answer, int actualAnswer) answerPressed;

  Answer(this.answerText, this.answerPressed);
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      margin: EdgeInsets.all(10),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
                onPressed: () => answerPressed(0, answerText[1][0]),
                child: Text(answerText[0][0])),
            ElevatedButton(
                onPressed: () => answerPressed(1, answerText[1][0]),
                child: Text(answerText[0][1])),
            ElevatedButton(
                onPressed: () => answerPressed(2, answerText[1][0]),
                child: Text(answerText[0][2])),
          ]),
    );
  }
}
