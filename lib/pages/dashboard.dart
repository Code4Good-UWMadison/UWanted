import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/authentication.dart';
import '../pages/task.dart';
import 'dart:async';

class DashboardPage extends StatefulWidget {
  DashboardPage({Key key, this.auth, this.userId})
      : super(key: key);

  final BaseAuth auth;
  final String userId;
  @override
  State<StatefulWidget> createState() => new _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  var search;
  var _sortOptions;

  @override
  void initState() {
    super.initState();
    _sortOptions = Firestore.instance.collection('tasks').snapshots(); 
  }

  //Stream _sortOptions = Firestore.instance.collection('tasks').snapshots();
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
                        id:document.documentID,
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
      body: Container(child:Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (val) {
                search = val;
                setState((){
                        _sortOptions = Firestore.instance.collection('tasks').where('title',isGreaterThanOrEqualTo:search).where('title',isLessThan:search+'z').snapshots();
                });
              },
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10.0),
                  hintText: 'Search by name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0)),
                  suffixIcon: IconButton(
                    color: Colors.black,
                    icon: Icon(Icons.search),
                    iconSize: 20.0,
                    onPressed: () {
                      setState((){
                        _sortOptions = Firestore.instance.collection('tasks').where('title',isGreaterThanOrEqualTo:search).where('title',isLessThan:search+'z').snapshots();
                      });
                    },
                  ),  
                ),             
            ),
          ),
          Expanded(child:_show(),),
        ]
    )));
  }
}