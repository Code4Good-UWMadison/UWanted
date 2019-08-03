import 'package:flutter/material.dart';
import 'package:thewanted/pages/status_tag.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplyButton extends StatefulWidget {
  ApplyButton({
    @required this.taskId,
    @required String status,
    @required this.context,
    @required this.parentKey,
  })  : status = StatusTag.getStatusFromString(status),
        userId = FirebaseAuth.instance
            .currentUser()
            .then((FirebaseUser user) => user.uid);

  final String taskId;
  final Status status;
  final Future<String> userId;
  final BuildContext context;
  final GlobalKey<ScaffoldState> parentKey;

  @override
  _ApplyButtonState createState() => _ApplyButtonState();
}

class _ApplyButtonState extends State<ApplyButton> {
  bool pressed = false;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: RaisedButton(
          color: _buildColorFromStatus(),
          onPressed: this.pressed ? null : _buildOnpressedFromStatus(),
          child: _buildTextFromStatus(),
        ),
      );

  Text _buildTextFromStatus() {
    switch (widget.status) {
      case Status.open:
        return Text('Apply');
        break;
      case Status.inprogress:
        return Text('In Progress');
        break;
      case Status.finished:
        return Text('Closed');
        break;
      default:
        return Text('Undefined');
        break;
    }
  }

  Color _buildColorFromStatus() {
    switch (widget.status) {
      case Status.open:
        return Colors.green;
        break;
      case Status.inprogress:
        return Colors.yellow[800];
        break;
      case Status.finished:
        return Colors.red;
        break;
      default:
        return Colors.blue;
        break;
    }
  }

  VoidCallback _buildOnpressedFromStatus() {
    switch (widget.status) {
      case Status.open:
        return _apply;
        break;
      default:
        return null;
        break;
    }
  }

  _apply() {
    setState(() {
      this.pressed = true;
    });
    print('Apply this task!');
    // TODO: implement apply
    // 1. ask user to input apply message
    // 2. add apply to firestore
    _updateTaskdataAndProfiledata().then((_) {
      setState(() {
        this.pressed = false;
      });
    });
  }

  Future<void> _updateTaskdataAndProfiledata() =>
      widget.userId.then((String uid) async {
        if (await _checkIfApplied(uid)) {
          print('Already applied!');
          _showNotifyAppliedDialog();
        } else {
          _updateTaskApplicants(uid)
              .then((_) => _ != false ? _updateProfileApplied(uid) : false);
        }
      }).catchError((e) {
        widget.parentKey.currentState.showSnackBar(SnackBar(content: Text(e)));
      });

  Future<bool> _checkIfApplied(String uid) async =>
      await _checkIfAppliedInTask(uid) && await _checkIfAppliedInUser(uid);

  Future<bool> _checkIfAppliedInTask(String uid) => Firestore.instance
      .collection('tasks')
      .document(widget.taskId)
      .collection('applicants')
      .document(uid)
      .get()
      .then((DocumentSnapshot document) => document.exists);

  Future<bool> _checkIfAppliedInUser(String uid) => Firestore.instance
      .collection('users')
      .document(uid)
      .get()
      .then((DocumentSnapshot document) =>
          (document['applied'] as List).contains(widget.taskId));

  Future _updateTaskApplicants(String uid) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ApplicationMessagePage()),
      ).then((msg) => msg != null
          ? Firestore.instance
              .collection('tasks')
              .document(widget.taskId)
              .collection('applicants')
              .document(uid)
              .setData({
              'msg': msg,
              'created': Timestamp.now(),
              'updated': Timestamp.now(),
              'accepted': false,
            }, merge: true)
          : false);

  Future<void> _updateProfileApplied(String uid) =>
      Firestore.instance.collection('users').document(uid).updateData({
        'applied': FieldValue.arrayUnion([
          widget.taskId,
        ])
      });

  Future<void> _showNotifyAppliedDialog() async {
    return showDialog<void>(
      context: widget.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Whoops'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You\'ve applid this task.'),
                Text('Are you trying to modify your application?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Modify',
                // style: TextStyle(color: Colors.red),
              ),
              onPressed: null,
            ),
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
}

class ApplicationMessagePage extends StatefulWidget {
  ApplicationMessagePage();

  @override
  _ApplicationMessagePageState createState() => _ApplicationMessagePageState();
}

class _ApplicationMessagePageState extends State<ApplicationMessagePage> {
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Application Message'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              Navigator.pop(context, myController.text);
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: myController,
            ),
          )
        ],
      ),
    );
  }
}
