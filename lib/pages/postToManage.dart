import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thewanted/pages/profile/starRating.dart';
import 'package:thewanted/services/authentication.dart';
import './details.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewanted/pages/status_tag.dart';

import 'components/avatar.dart';
import 'package:thewanted/models/user.dart';
import 'package:thewanted/pages/send_request_page/send_request_refactored.dart';

class PostToManage extends StatelessWidget {
  // Task({@required this.title, this.description});
  PostToManage({
    @required this.title,
    @required this.taskId,
    @required this.status,
    @required this.userId,
    @required this.auth,
    @required this.user,
    @required this.showAlertDialog,
  });
  final title;
  final taskId;
  final String status;
  final String userId;
  final BaseAuth auth;
  final User user;
  final Function(String) showAlertDialog;
  final Firestore db = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    // ScreenUtil.instance = ScreenUtil(width: 640, height: 1136)..init(context);
    return Card(
        child: Container(
            padding: const EdgeInsets.only(top: 5.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    StatusTag.fromString(this.status),
                  ],
                ),
                // Column(children: <Widget>[_buildReview(this.taskId)],),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Text("Details",
                            style:
                                TextStyle(color: Colors.blue, fontSize: 14.0)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailedPage(
                                        title: title,
                                        id: taskId,
                                        currUserId: userId,
                                        auth: auth,
                                        withdrawlButton: false,
                                      )));
                        }),
                    RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Text("Edit",
                            style:
                                TextStyle(color: Colors.blue, fontSize: 14.0)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RequestForm(
                                  needUpdate: true,
                                  postId: taskId,
                                ),
                              ));
                        }),
                    RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Text('Delete',
                            style:
                                TextStyle(color: Colors.blue, fontSize: 14.0)),
                        onPressed: () {
                          showAlertDialog(this.taskId);
                        }),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Text('Archive',
                          style: TextStyle(color: Colors.blue, fontSize: 14.0)),
                      onPressed: _archiveRequest,
                    ),
                  ],
                ),
              ],
            )));
  }
   //change status to finished
  _archiveRequest() {
    db
        .collection('tasks')
        .document(this.taskId)
        .updateData({'status': 'finished'});
  }

  
  // Future<void> _updateRemoteUserPosts() => db
  //     .collection('users')
  //     .document(this.userId)
  //     .updateData({'posts': _getUncheckedList()});

  // Future<void> _updateWidgetPosts() => db
  //         .collection('users')
  //         .document(this.userId)
  //         .get()
  //         .then((DocumentSnapshot document) {
  //       setState(() {
  //         widget.posts.clear();
  //         widget.posts.addAll(List.from(document['posts']));
  //       });
  //     });

  // Future<void> _updateThisPosts() async {
  //   setState(() {
  //     this.posts = new Map<String, Map<String, dynamic>>();
  //   });
  //   widget.posts.forEach((String uid) {
  //     db
  //         .collection('tasks')
  //         .document(uid)
  //         .get()
  //         .then((DocumentSnapshot document) {
  //       setState(() {
  //         this.posts[uid] = {
  //           'uid': uid,
  //           'title': document['title'],
  //           'isChecked': false,
  //           'status': document['status'],
  //         };
  //       });
  //     });
  //   });
  // }

  // Future<void> _showSnackbarThenWait1sec(String msg) async {
  //   this.keyForSnack.currentState.showSnackBar(SnackBar(content: Text(msg)));
  // }

  StreamBuilder<QuerySnapshot> _buildReview(taskId) =>
      StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('tasks')
            .document(taskId)
            .collection('applicants')
            .where('accepted', isEqualTo: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              return ListView(
                children: snapshot.data.documents
                    .map(_buildListTileFromDocument)
                    .toList(),
              );
          }
        },
      );

  ListTile _buildListTileFromDocument(DocumentSnapshot document) => ListTile(
        // leading: (document['accepted'] as bool)
        //     ? Icon(Icons.check_box)
        //     : Icon(Icons.check_box_outline_blank),
        title: Row(
          children: <Widget>[
            Avatar(userId: document.documentID),
            Container(
              width: 10,
            ),
            _buildTitleFromUsername(document.documentID),
            StarRating(
              onChanged: (value) {
                int number = _updateNumberOfRating(document.documentID);
                _updateRating(number, document.documentID, value);
              },
            ),
          ],
        ),
        // trailing: Icon(Icons.arrow_forward),
        // onTap: _navigateToApplicationDetail(document.documentID),
      );

  _updateNumberOfRating(String uid) async {
    int number;
    await Firestore.instance
        .collection("users")
        .document(uid)
        .get()
        .then((DocumentSnapshot doc) {
      number = doc['numberOfRate'];
      //appliedList.removeWhere((item) => item == widget.id);
    });
    await Firestore.instance.collection('users').document(uid).updateData({
      "numberOfRate": number
      //FieldValue.arrayRemove(new List)
    });
    return number;
  }

  _updateRating(int number, String uid, int value) async {
    num rate;
    await Firestore.instance
        .collection("users")
        .document(uid)
        .get()
        .then((DocumentSnapshot doc) {
      rate = doc['rating'];
      //appliedList.removeWhere((item) => item == widget.id);
    });
    if (rate == 0) {
      rate = value;
    } else {
      rate = (rate + value) / number;
    }
    await Firestore.instance.collection('users').document(uid).updateData({
      "rating": rate
      //FieldValue.arrayRemove(new List)
    });
  }

  FutureBuilder<DocumentSnapshot> _buildTitleFromUsername(String uid) =>
      FutureBuilder<DocumentSnapshot>(
        future: Firestore.instance.collection('users').document(uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Row(
                children: <Widget>[CircularProgressIndicator()],
              );
            default:
              return Text(snapshot.data['name']);
          }
        },
      );
}
