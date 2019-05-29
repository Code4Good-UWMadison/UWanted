import 'package:flutter/material.dart';

class DetailedPage extends StatelessWidget {
  DetailedPage({@required this.title, this.description});

  final title;
  final description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(description),
                RaisedButton(
                    child: Text('Back To DashBoard'),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    onPressed: () => Navigator.pop(context)),
              ]),
        ));
  }
}