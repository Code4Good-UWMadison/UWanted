import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/authentication.dart';
import '../pages/task.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({Key key, this.auth, this.userId}) : super(key: key);

  final BaseAuth auth;
  final String userId;
  @override
  State<StatefulWidget> createState() => new _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Stream _sortOptions = Firestore.instance.collection('tasks').snapshots();
  Widget _show() {
    return Center(
      child: Container(
          padding: const EdgeInsets.all(10.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: _sortOptions,
            // stream: Firestore.instance.collection('tasks').snapshots(),
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
                        ai: document['AI&ML'],
                        app: document['App'],
                        be: document['Backend'],
                        data: document['Data'],
                        fe: document['Frontend'],
                        ot: document['Other'],
                        id: document.documentID,
                      );
                    }).toList(),
                  );
                // return new Text(widget.userId);
              }
            },
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Container(
            child: Column(children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              onChanged: (val) {
                //initiateSearch(val);
              },
              decoration: InputDecoration(
                hintText: 'Search by name',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0)),
              ),
            ),
          ),
          Container(
            child: DropdownButton<String>(
              // value: 'Sort',
              icon: Icon(Icons.sort),
              onChanged: (String newValue) {
                setState(() {
                  switch (newValue) {
                    case 'Time':
                      _sortOptions = Firestore.instance
                          .collection('tasks')
                          .orderBy('updated', descending: true)
                          .snapshots();
                      break;
                    case 'Alphabet':
                      _sortOptions = Firestore.instance
                          .collection('tasks')
                          .orderBy('title')
                          .snapshots();
                      break;
                    default:
                  }
                });
              },
              items: <String>['Time', 'Alphabet']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      Expanded(
        child: _show(),
      ),
    ])));
  }
}
