import 'package:flutter/material.dart';
import './details.dart';

class Task extends StatelessWidget {
  Task({@required this.title, this.description});

  final title;
  final description;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
            padding: const EdgeInsets.only(top: 5.0),
            child: Column(
              children: <Widget>[
                Text(title),
                FlatButton(
                    child: Text("See More"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailedPage(
                                  title: title, description: description)));
                    }),
              ],
            )));
  }
}
