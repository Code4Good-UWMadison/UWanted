import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thewanted/pages/profile/application_detail.dart';
// import 'package:thewanted/pages/components/avatar.dart';
// import 'package:thewanted/pages/profile/starRating.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:thewanted/pages/status_tag.dart';
// import 'package:thewanted/pages/components/avatar.dart';
// import 'package:thewanted/pages/details.dart';
import 'package:thewanted/services/authentication.dart';
import 'package:thewanted/models/user.dart';
import 'postToManage.dart';

class ManagePostsPage extends StatefulWidget {
  ManagePostsPage({
    Key key,
    // @required this.taskId,
    @required this.auth,
    @required this.userId,
    // this.navigateBack,
  }) : super(key: key);

  // final String taskId;
  final BaseAuth auth;
  final String userId;
  // final Function() navigateBack;

  @override
  _ManagePostsState createState() => _ManagePostsState();
}

class _ManagePostsState extends State<ManagePostsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  User user;
  final Firestore db = Firestore.instance;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    if (this.user == null)
      return Center(
        child: CircularProgressIndicator(),
      );
    return new Scaffold(
        key: this._scaffoldKey,
        body: Container(
            child: Column(children: <Widget>[
          // Row(
          //   children: <Widget>[
          //     Expanded(

          //     ),
          //   ],
          // ),
          Expanded(
            child: _show(),
          ),
        ])));
  }

  Widget _show() {
    return Center(
      child: Container(
          padding: const EdgeInsets.all(10.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('tasks')
                .where('userId', isEqualTo: widget.userId)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return new Text('Loading...');
                default:
                  List<DocumentSnapshot> list = snapshot.data.documents;
                  return list.toList().length == 0
                      ? Text("You haven't posted any request yet.")
                      : new ListView(
                          children: list
                              .map((DocumentSnapshot document) {
                                return new PostToManage(
                                  title: document['title'],
                                  taskId: document.documentID,
                                  status: document['status'],
                                  userId: widget.userId,
                                  auth: widget.auth,
                                  user: this.user,
                                  showAlertDialog: _showAlertDialog,
                                  naviDetails: _navigateToApplicationDetail,
                                );
                              })
                              // .where((task) => task.status != 'finished')
                              .toList(),
                        );
              }
            },
          )),
    );
  }

  Future<void> _showSnackbarThenWait1sec(String msg) async {
    this._scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _showAlertDialog(String taskId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Delete is irreversible!'),
                Text('Permanently delete selected tasks?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
                child: Text(
                  'PERMANENTLY DELETE',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  print("WHAT?");
                  _updateRemoteData(taskId);
                }),
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<String> _newList = List<String>();

  _updateRemoteData(taskId) {
    _deleteCheckedTasksFromFirestore(taskId)
        .then((_) => _deleteApps(taskId))
        .then((_) => _getNewList(taskId))
        .then((_) => _updateRemoteUser(taskId))
        .then((_) => _showSnackbarThenWait1sec('Success!'))
        .then((_) => Navigator.of(context).pop())
        .catchError((e) => _showSnackbarThenWait1sec('Delete failed! $e'));
  }

  Future<void> _deleteCheckedTasksFromFirestore(taskId) async {
    await db.collection('tasks').document(taskId).delete();
  }

  Future<void> _deleteApps(taskId) async {
    await db
        .collection('tasks')
        .document(taskId)
        .collection('applicants')
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        ds.reference.delete();
      }
    });
  }

  Future<void> _getNewList(taskId) async {
    print("getNew");
    await db
        .collection('users')
        .document(widget.userId)
        .get()
        .then((DocumentSnapshot document) {
      print("getIt?");
      _newList.addAll(List.from(document['posts']));
      print("remove " + taskId);
      _newList.removeWhere((item) => item == taskId);
    });
  }

  Future<void> _updateRemoteUser(taskId) async {
    print("updating");
    await db.collection('users').document(widget.userId).updateData({
      'posts': _newList,
    });
  }

  VoidCallback _navigateToApplicationDetail(
          String applicantId, String taskId) =>
      () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ApplicationDetail(
              taskId: taskId,
              applicantId: applicantId,
              // navigateBack: widget.navigateBack,
            ),
          ),
        );
      };
}
