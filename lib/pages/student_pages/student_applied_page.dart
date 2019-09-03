import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../details.dart';
import 'package:thewanted/services/authentication.dart';
import 'package:thewanted/models/user.dart';
import 'package:thewanted/pages/profile/edit_profile.dart';
import 'package:thewanted/pages/profile/my_posts.dart';
import 'package:thewanted/pages/details.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:thewanted/pages/status_tag.dart';
import 'package:thewanted/pages/components/avatar.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
bool _isLoading = false;

class StudentAppliedPage extends StatefulWidget {
  StudentAppliedPage({
    Key key,
    @required this.auth,
    @required this.userId,
// @required this.skipToProfile
  }) : super(key: key);

  final BaseAuth auth;
  final String userId;

  @override
  _StudentAppliedPageState createState() => _StudentAppliedPageState();
}

class _StudentAppliedPageState extends State<StudentAppliedPage> {
  List<bool> _expansionStatus = [true, false, false];
  User user;
  File _image;
  String _imageUrl;
  bool _confirmed;

  @override
  Widget build(BuildContext context) {
    if (this.user == null)
      return Center(
        child: CircularProgressIndicator(),
      );
    var list = ListView(
      padding: EdgeInsets.zero,
      children: ListTile.divideTiles(
        context: context,
        tiles: [
          ExpansionTile(
            key: GlobalKey(),
            initiallyExpanded: this._expansionStatus[2],
            title: Text(
              'Applied',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            children: List.from(_buildAppliedList())
              ..insert(0, Divider(color: Colors.black)),
            onExpansionChanged: (bool isExpanded) {
              setState(() {
                this._expansionStatus = [false, false, isExpanded];
              });
            },
          ),
        ],
      ).toList(),
    );
    var bodyProgress = new Container(
      child: new Stack(
        children: <Widget>[
          list,
          new Container(
            alignment: AlignmentDirectional.center,
            decoration: new BoxDecoration(
              color: Colors.white70,
            ),
            child: new Container(
              decoration: new BoxDecoration(
                  color: Colors.blue[200],
                  borderRadius: new BorderRadius.circular(10.0)),
              width: 300.0,
              height: 200.0,
              alignment: AlignmentDirectional.center,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Center(
                    child: new SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: new CircularProgressIndicator(
                        value: null,
                        strokeWidth: 7.0,
                      ),
                    ),
                  ),
                  new Container(
                    margin: const EdgeInsets.only(top: 25.0),
                    child: new Center(
                      child: new Text(
                        "loading.. wait...",
                        style: new TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    return Scaffold(key: _scaffoldKey, body: _isLoading ? bodyProgress : list);
  }

  @override
  void initState() {
    super.initState();
    _image = null;
    _imageUrl = null;
    _getUserProfileFromFirebase();
  }

  void _getUserProfileFromFirebase() {
    Firestore.instance
        .collection('users')
        .document(widget.userId)
        .get()
        .then(_initializeRemoteUserDataIfNotExist)
        .then(_getRemoteUserData);
  }

  void _initializeRemoteUserDataIfNotExist(DocumentSnapshot document) {
    if (!document.exists) {
      Firestore.instance
          .collection('users')
          .document(widget.userId)
          .setData(User.initialUserData);
    }
  }

  void _getRemoteUserData(_) {
    Firestore.instance
        .collection('users')
        .document(widget.userId)
        .get()
        .then(_setLocalUserData);
  }

  void _setLocalUserData(DocumentSnapshot document) {
    if (this.mounted) {
      setState(() {
        this.user = User.fromDocument(document);
      });
    }
  }

  List<Widget> _buildAppliedList() {
    var list = List<Widget>();
    if(user.applied == null || user.applied.length == 0){
      list.add(Text("Applied list is empty."));
      return list;
    }
    else return user.applied
        .map((String uid) =>
        FutureBuilder<DocumentSnapshot>(
          future: Firestore.instance.collection('tasks').document(uid).get(),
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.data != null) {
              return ListTile(
                leading: StatusTag.fromString(snapshot.data['status']),
                title: Text(
                  snapshot.data['title'],
                  style: TextStyle(fontSize: 15),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FlatButton(
                      child: Icon(Icons.delete),
                      onPressed: () {
                        if (snapshot.data['status'] == 'closed') {
                          _deleteAppliedTask(uid);
                        } else {
                          _showAlertDialog(uid);
                        }
                      },
                    ),
                    Icon(Icons.arrow_forward),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailedPage(
                              title: snapshot.data['title'],
                              id: uid,
                              currUserId: widget.userId,
                              auth: widget.auth,
                              withdrawlButton: true,
                            ),
                      )).then((_) {
                    setState(() {
                      _getRemoteUserData(_);
                    });
                  });
                },
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ))
        .toList();
  }

  Future<void> _showAlertDialog(String uid) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This task can not be directly deleted.'),
                Text('Try cancel it instead.')
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _deleteAppliedTask(String uid) async {
    List list;
    await Firestore.instance
        .collection("users")
        .document(widget.userId)
        .get()
        .then((DocumentSnapshot doc) {
      list = List<String>.from(doc['applied'], growable: true);
      list.remove(uid);
      //appliedList.removeWhere((item) => item == widget.id);
    });
    await Firestore.instance
        .collection('users')
        .document(widget.userId)
        .updateData({
      "applied": list
      //FieldValue.arrayRemove(new List)
    });
  }
}