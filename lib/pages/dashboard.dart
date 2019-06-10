import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/authentication.dart';
import '../pages/card.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({Key key, this.auth, this.userId})
      : super(key: key);

  final BaseAuth auth;
  final String userId;
  @override
  State<StatefulWidget> createState() => new _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Widget _showTodoList() {
    return Center(
      child: Container(
          padding: const EdgeInsets.all(10.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('tasks').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return new Text('Loading...');
                default:
                  return new ListView(
                    children: snapshot.data.documents
                        .map((DocumentSnapshot document) {
                      return new Task(
                        title: document['title'],
                        description: document['description'],
                      );
                    }).toList(),
                  );
                  // return new Text(widget.userId);
              }
            },
          )
        ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: _showTodoList(),
    );
  }
  
}