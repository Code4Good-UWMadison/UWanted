import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/authentication.dart';
import '../pages/components/task.dart';
import 'dart:async';

class DashboardPage extends StatefulWidget {
  DashboardPage({Key key, this.auth, this.userId}) : super(key: key);

  final BaseAuth auth;
  final String userId;
  @override
  State<StatefulWidget> createState() => new _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  var _sortOptions;
  CollectionReference originList =
      Firestore.instance.collection('tasks'); // Search from origin
  Stream<QuerySnapshot> currList = Firestore.instance
      .collection('tasks')
      .snapshots(); // current list after search

  @override
  void initState() {
    super.initState();
    _sortOptions = null;
  }

  Widget _show() {
    return Center(
      child: Container(
          padding: const EdgeInsets.all(10.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: currList,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.data != null) {
                // print("NOT NULL??????");
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                // switch (snapshot.connectionState) {
                //   case ConnectionState.waiting:
                //     return new Text('Loading...');
                //   default:
                List<DocumentSnapshot> list = snapshot.data.documents;
                //print(list.length);
                if (_sortOptions != null) {
                  switch (_sortOptions) {
                    case 'Remaining':
                      list.sort((a, b) =>
                          (a['maximumApplicants'] - a['numberOfApplicants'])
                              .compareTo((b['maximumApplicants'] -
                                  b['numberOfApplicants'])));
                      break;
                    case 'Request':
                      list.sort((a, b) =>
                          a['leastRating'].compareTo(b['leastRating']));
                      break;
                    default:
                  }
                } else {
                  list = snapshot.data.documents;
                }
                //snapshot.
                return new ListView(
                  children: list
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
                          status: document['status'],
                          request: document['leastRating'],
                          max: document['maximumApplicants'],
                          already: document['numberOfApplicants'],
                          userId: widget.userId,
                          auth: widget.auth,
                        );
                      })
                      .where((task) => task.status != 'finished')
                      .toList(),
                );
                // return new Text(widget.userId);
                // }
              }
              return new Text("No available tasks right now");
            },
          )),
    );
  }

  // Future<int> countDocuments(id) async {
  //   // var size;
  //   // QuerySnapshot querySnapshot = await Firestore.instance.collection('task').document(id).collection('applicants').getDocuments();
  //   // List<DocumentSnapshot> list = querySnapshot.documents;
  //   //print(id);
  //   int size = 0;
  //   await Firestore.instance
  //         .collection('tasks')
  //         .document(id)
  //         .collection('applicants')
  //         .getDocuments()
  //         .then((QuerySnapshot snapshot) {
  //             size = snapshot.documents.length;
  //         });
  //   //print("doc size" + size.toString());
  //   return size;
  // }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (val) {
                        var search = val;
                        setState(() {
                          _sortOptions = null;
                          currList = originList
                              .where('title', isGreaterThanOrEqualTo: search)
                              .where('title', isLessThan: search + 'z')
                              .snapshots();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: DropdownButton<String>(
                      // value: 'Sort',

                      icon: Icon(Icons.sort),
                      onChanged: (String newValue) {
                        setState(() {
                          switch (newValue) {
                            case 'Sorted by Availbility':
                              _sortOptions = 'Remaining';
                              break;
                            case 'Min. Rating satisfied':
                              _sortOptions = 'Request';
                              break;
                            default:
                          }
                        });
                      },
                      items: <String>[
                        'Sorted by Availbility',
                        'Min. Rating satisfied'
                      ].map<DropdownMenuItem<String>>((String value) {
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
