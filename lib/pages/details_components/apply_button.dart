import 'package:flutter/material.dart';
import 'package:thewanted/pages/status_tag.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplyButton extends StatelessWidget {
  ApplyButton({
    @required this.taskId,
    @required String status,
  }): status = StatusTag.getStatusFromString(status);

  final String taskId;
  final Status status;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: RaisedButton(
          color: _buildColorFromStatus(),
          onPressed: _buildOnpressedFromStatus(),
          child: _buildTextFromStatus(),
        ),
      );

  Text _buildTextFromStatus() {
    switch (this.status) {
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
    switch (this.status) {
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
    switch (this.status) {
      case Status.open:
        return _apply;
        break;
      default:
        return null;
        break;
    }
  }

  _apply() {
    print('Apply this task!');
    // TODO: implement apply
    // 1. ask user to input apply message
    // 2. add apply to firestore
    _updateTaskdataAndProfiledata();
    // 3. Send owner (email) notification
  }

  Future<void> _updateTaskdataAndProfiledata() =>
      _getCurrentUserId().then((FirebaseUser user) {
        _updateTaskApplicants(user.uid);
        _updateProfileApplied(user.uid);
      }).catchError((e) {
        print(e);
      });

  Future<void> _updateTaskApplicants(String uid) => Firestore.instance
          .collection('tasks')
          .document(this.taskId)
          .collection('applicants')
          .document(uid)
          .setData({
        'msg': 'I am good at this kind of job, please let me do this',
        'created': Timestamp.now(),
        'updated': Timestamp.now(),
      }, merge: true);

  Future<void> _updateProfileApplied(String uid) =>
      Firestore.instance.collection('users').document(uid).updateData({
        'applied': FieldValue.arrayUnion([
          this.taskId,
        ])
      });

  Future<FirebaseUser> _getCurrentUserId() =>
      FirebaseAuth.instance.currentUser();
}
