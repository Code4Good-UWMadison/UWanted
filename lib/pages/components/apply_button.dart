import 'package:flutter/material.dart';
import 'package:thewanted/pages/components/status_tag.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thewanted/pages/components/details.dart';

class ApplyButton extends StatefulWidget {
  ApplyButton(
      {@required this.taskId,
      @required String status,
      @required this.context,
      @required this.parentKey,
      @required this.request,
      @required this.notifyParent})
      : status = StatusTag.getStatusFromString(status),
        userId = FirebaseAuth.instance
            .currentUser()
            .then((FirebaseUser user) => user.uid);

  final String taskId;
  final Status status;
  final Future<String> userId;
  final BuildContext context;
  final GlobalKey<ScaffoldState> parentKey;
  final Request request;

  final Function(bool apply) notifyParent;

  @override
  _ApplyButtonState createState() => _ApplyButtonState();
}

class _ApplyButtonState extends State<ApplyButton> {
  bool _applied = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _updateButton();
  }

  Future _updateButton() async {
    widget.userId.then((String uid) {
      _checkIfApplied(uid).then((applied) {
        if (this.mounted) {
          setState(() {
            this._applied = applied;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          color: _buildColorFromStatus(),
          onPressed: this._pressed ? null : _buildOnpressedFromStatus(),
          child: _buildChildFromStatus(),
        ),
      );

  Widget _buildChildFromStatus() {
    if (this._pressed)
      return SizedBox(
        child: CircularProgressIndicator(strokeWidth: 2),
        height: 15,
        width: 15,
      );

    if (this._applied) return Text('Withdraw');

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
    if (this._applied) return Colors.orange;

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

  void _apply() {
    if (this.mounted) {
      setState(() {
        this._pressed = true;
      });
      _updateTaskdataAndProfiledata().then((_) {
        setState(() {
          this._pressed = false;
        });
      });
    }
  }

  Future<void> _updateTaskdataAndProfiledata() =>
      widget.userId.then((String uid) async {
        if (this._applied) {
          _showNotifyAppliedDialog();
        } else if (!await _checkIfRatingQualified(uid)) {
          _showRatingNotEnoughDialog();
        } else if (!await _checkIfNotFull()) {
          _showFullDialog();
        } else if (!await _checkProfileFullfilled(uid)) {
          _showFullfillProfile();
        } else {
          _showAppMsgDialog().then((String appMsg) {
            if (appMsg != null) {
              _updateTaskApplicants(uid, appMsg);
              _updateProfileApplied(uid);
            }
          }).then((_) {
            _updateButton();
          });
        }
      }).catchError((e) {
        widget.parentKey.currentState.showSnackBar(SnackBar(content: Text(e)));
      });

  //     }).then((_) {
  //       // showInSnackBar('Success!'); //TODO: showsnackbar!!!
  //     });
  //   }
  // }).catchError((e) {
  //   print(e);
  //   // widget.parentKey.currentState
  //   //     .showSnackBar(SnackBar(content: Text(e))); //TODO: showsnackbar!!!
  // });

  //TODO: showsnackbar!!!
  // not figure out how to display snackbar yet, none of these work
  // Reason: After submitting the application, the details page will be redrawn,
  // causing the change of context and key, but the widget created before cannot know
  // the key created now, thus cannot display snackbar on current Scaffold
  // void showInSnackBar(String value) {
  //   // widget.parentKey.currentState
  //   //     .showSnackBar(SnackBar(content: Text(value)));
  //   // Scaffold.of(context).showSnackBar(SnackBar(content: Text(value)));
  //   // Scaffold.of(widget.context).showSnackBar(SnackBar(content: Text(value)));
  // }

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

  Future<bool> _checkIfRatingQualified(String uid) => Firestore.instance
      .collection('users')
      .document(uid)
      .get()
      .then((DocumentSnapshot document) =>
          document['rating'] >= widget.request.leastRating);

  Future<bool> _checkProfileFullfilled(String uid) => Firestore.instance
      .collection('users')
      .document(uid)
      .get()
      .then((DocumentSnapshot document) =>
          document['name'] != "");

  Future<bool> _checkIfNotFull() => widget.request.maximumApplicants < 0
      ? Future(() => true)
      : Firestore.instance
          .collection('tasks')
          .document(widget.taskId)
          .collection('applicants')
          .getDocuments()
          .then((QuerySnapshot snapshot) =>
              snapshot.documents.length < widget.request.maximumApplicants);

  Future<String> _showRatingNotEnoughDialog() async => showDialog<String>(
        context: widget.context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Not enough rating!'),
            content: Text(
                "Sorry, your rating is not high enough for this task.\n" +
                    "Try to get higher rate!"),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

  Future<String> _showFullDialog() async => showDialog<String>(
        context: widget.context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Too Late!'),
            content: Text("Sorry, this task has received many applications\n" +
                "Try to apply early next time!"),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

    Future<String> _showFullfillProfile() async => showDialog<String>(
        context: widget.context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Haven\'t fullfilled your profile yet!'),
            content: Text(
                "Please fullfill your profile before applying!"),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

  Future<String> _showAppMsgDialog() async {
    TextEditingController _controller = TextEditingController();
    return showDialog<String>(
      context: widget.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter your application message'),
          content: SingleChildScrollView(
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(labelText: 'Application Message'),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop(_controller.text);
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future _updateTaskApplicants(String uid, String msg) {
    _addApplicants(uid);
    return Firestore.instance
        .collection('tasks')
        .document(widget.taskId)
        .collection('applicants')
        .document(uid)
        .setData({
      'msg': msg,
      'created': Timestamp.now(),
      'updated': Timestamp.now(),
      'accepted': false,
    }, merge: true).then((_) {
      widget.notifyParent(true);
      widget.parentKey.currentState
          .showSnackBar(SnackBar(content: Text("Successfully Applied!")));
    });
  }

  _addApplicants(String uid) async {
    int number = 0;
    await Firestore.instance
        .collection('tasks')
        .document(widget.taskId)
        .get()
        .then((DocumentSnapshot doc) {
      number = doc['numberOfApplicants'] + 1;
    });
    Firestore.instance
        .collection('tasks')
        .document(widget.taskId)
        .updateData({"numberOfApplicants": number});
  }

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
          title: Text('Warning'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You\'ve applid this task.'),
                Text('Are you sure you want to withdraw your application?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Withdraw',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                _withdrawApplication(context);
              },
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

  // int number = 0;

  _withdrawApplication(BuildContext context) {
    widget.userId.then((String uid) async {
      int number = 0;
      Firestore.instance
          .collection('tasks')
          .document(widget.taskId)
          .collection('applicants')
          .document(uid)
          .delete();

      await Firestore.instance
          .collection('tasks')
          .document(widget.taskId)
          .get()
          .then((DocumentSnapshot doc) {
        number = doc['numberOfApplicants'] - 1;
      });

      Firestore.instance
          .collection('tasks')
          .document(widget.taskId)
          .updateData({"numberOfApplicants": number});
      Firestore.instance.collection('users').document(uid).updateData({
        'applied': FieldValue.arrayRemove([
          widget.taskId,
        ])
      });
    }).then((_) {
      Navigator.of(context).pop();

      _updateButton();
      widget.notifyParent(false);
      widget.parentKey.currentState
          .showSnackBar(SnackBar(content: Text("Withdraw Successfully.")));
    }).catchError((e) {
      widget.parentKey.currentState.showSnackBar(SnackBar(content: Text(e)));
    });
  }
}
