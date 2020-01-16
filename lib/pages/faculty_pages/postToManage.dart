import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thewanted/pages/profile/starRating.dart';
import 'package:thewanted/services/authentication.dart';
import '../components/details.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewanted/pages/components/status_tag.dart';

import '../components/avatar.dart';
import 'package:thewanted/models/user.dart';
import 'package:thewanted/pages/request/send_request_refactored.dart';

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
    @required this.naviDetails,
  });
  final title;
  final taskId;
  final String status;
  final String userId;
  final BaseAuth auth;
  final User user;
  final Function(String) showAlertDialog;
  final Function(String, String) naviDetails;
  final Firestore db = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
          Container(
              padding: const EdgeInsets.only(top: 5.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      StatusTag.fromString(this.status),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Text("Details",
                              style: TextStyle(
                                  color: Colors.blue, fontSize: 14.0)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DetailedPage(
                                          title: title,
                                          id: this.taskId,
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
                              style: TextStyle(
                                  color: Colors.blue, fontSize: 14.0)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RequestForm(
                                    needUpdate: true,
                                    postId: this.taskId,
                                  ),
                                ));
                          }),
                      RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Text('Delete',
                              style: TextStyle(
                                  color: Colors.blue, fontSize: 14.0)),
                          onPressed: () {
                            showAlertDialog(this.taskId);
                          }),
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Text('Archive',
                            style:
                                TextStyle(color: Colors.blue, fontSize: 14.0)),
                        onPressed: _archiveRequest,
                      ),
                    ],
                  ),
                ],
              )),
          _buildAppList(),
        ]));
  }

  //change status to finished
  _archiveRequest() {
    db
        .collection('tasks')
        .document(this.taskId)
        .updateData({'status': 'finished'});
  }

  int number = 0;
  bool reviewed = false;
  num rate = 0;
  StreamBuilder<QuerySnapshot> _buildReview() => StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('tasks')
            .document(this.taskId)
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
                    .map(_buildReviewListTileFromDocument)
                    .toList(),
                shrinkWrap: true,
              );
          }
        },
      );

  ListTile _buildReviewListTileFromDocument(DocumentSnapshot document) =>
      ListTile(
        title: Row(
          children: <Widget>[
            Avatar(userId: document.documentID),
            Container(
              width: 10,
            ),
            _buildReviewTile(document.documentID),
          ],
        ),
        // trailing: Icon(Icons.arrow_forward),
        // onTap: _navigateToApplicationDetail(document.documentID),
      );

  _checkReviewed() async {
    await db
        .collection("tasks")
        .document(this.taskId)
        .get()
        .then((DocumentSnapshot doc) {
      reviewed = doc['reviewed'];
    });
  }

  _updateNumberOfRating(String uid) async {
    // int number;
    await Firestore.instance
        .collection("users")
        .document(uid)
        .get()
        .then((DocumentSnapshot doc) {
      number = doc['numberOfRate'] + 1;
      //appliedList.removeWhere((item) => item == widget.id);
    });
    await Firestore.instance.collection('users').document(uid).updateData({
      "numberOfRate": number
      //FieldValue.arrayRemove(new List)
    });
    // return number;
  }

  _updateRating(String uid, int value) async {
    await Firestore.instance
        .collection("users")
        .document(uid)
        .get()
        .then((DocumentSnapshot doc) {
      rate = doc['rating'];
      //appliedList.removeWhere((item) => item == widget.id);
    });
    if (number == 1) {
      rate = value;
    } else {
      rate = (rate * (number - 1) + value) / number;
    }
    print("UPDATE RATE" + rate.toString());
    await Firestore.instance.collection('users').document(uid).updateData({
      "rating": rate
      //FieldValue.arrayRemove(new List)
    });
    await db
        .collection('tasks')
        .document(this.taskId)
        .updateData({"reviewed": true});
  }

  FutureBuilder<DocumentSnapshot> _buildReviewTile(String uid) =>
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
              rate = snapshot.data['rating'].toInt();
              return Row(
                children: <Widget>[
                  Text(snapshot.data['name']),
                  StatefulBuilder(builder: (context, setState) {
                    return StarRating(
                      value: rate,
                      reviewed: reviewed,
                      changeStar: (value) {
                        setState(() {
                          rate = rate.toInt();
                          _checkReviewed()
                              .then((_) => reviewed
                                  ? null
                                  : _updateNumberOfRating(uid)
                                      .then((_) => _updateRating(uid, value)))
                              .then((_) => rate = rate.toInt())
                              .then((_) => print("RATE" + rate.toString()));
                          reviewed = reviewed;
                        });
                      },
                    );
                  }),
                  FutureBuilder<DocumentSnapshot>(
                      future:
                          db.collection("tasks").document(this.taskId).get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> taskshot) {
                        if (taskshot.hasError)
                          return Text('Error: ${taskshot.error}');
                        switch (taskshot.connectionState) {
                          case ConnectionState.waiting:
                            return Row(
                              children: <Widget>[CircularProgressIndicator()],
                            );
                          default:
                            reviewed = taskshot.data['reviewed'];
                            return reviewed ? Text("  Reviewed") : Text("");
                        }
                      })
                ],
              );
          }
        },
      );

  StreamBuilder<QuerySnapshot> _buildSelect() => StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('tasks')
            .document(this.taskId)
            .collection('applicants')
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
                    .map(_buildSelectListTileFromDocument)
                    .toList(),
                shrinkWrap: true,
              );
          }
        },
      );

  ListTile _buildSelectListTileFromDocument(DocumentSnapshot document) =>
      ListTile(
        leading: (document['accepted'] as bool) ? Icon(Icons.check_box) : null,
        title: Row(
          children: <Widget>[
            Avatar(userId: document.documentID),
            Container(
              width: 10,
            ),
            _buildSelectTile(document.documentID),
          ],
        ),
        trailing: Icon(Icons.arrow_forward),
        onTap: naviDetails(document.documentID, this.taskId),
      );

  FutureBuilder<DocumentSnapshot> _buildSelectTile(String uid) =>
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
                rate = snapshot.data['rating'].toInt();
                return Row(children: <Widget>[
                  Text(snapshot.data['name']),
                ]);
            }
          });

  FutureBuilder<DocumentSnapshot> _buildAppList() =>
      FutureBuilder<DocumentSnapshot>(
          future: Firestore.instance
              .collection('tasks')
              .document(this.taskId)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Row(
                  children: <Widget>[CircularProgressIndicator()],
                );
              default:
                String status = snapshot.data['status'];
                return Container(
                    padding: const EdgeInsets.all(10.0),
                    child:
                        status == "finished" ? _buildReview() : _buildSelect());
            }
          });
}
