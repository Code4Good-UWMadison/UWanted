import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thewanted/pages/profile/application_detail.dart';
import 'package:thewanted/pages/components/avatar.dart';
import 'package:thewanted/pages/profile/starRating.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:thewanted/pages/status_tag.dart';
import 'package:thewanted/pages/components/avatar.dart';
import 'package:thewanted/pages/details.dart';
import 'package:thewanted/services/authentication.dart';
import 'package:thewanted/models/user.dart';
import 'package:thewanted/pages/postToManage.dart';

class ManagePostsPage extends StatefulWidget {
  ManagePostsPage({
    Key key,
    // @required this.taskId,
    @required this.auth,
    @required this.userId,
    // @required this.skipToProfile
  }) : super(key: key);

  // final String taskId;
  final BaseAuth auth;
  final String userId;

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
    // var list = ListView(
    //     padding: EdgeInsets.zero,
    //     children: ListTile.divideTiles(context: context, tiles: [
    //       ExpansionTile(
    //         key: GlobalKey(),
    //         initiallyExpanded: true,
    //         title: Text(
    //           'Manage Your Requests:',
    //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    //         ),
    //         children: List.from(_buildPosts()),
    //       )
    //     ]).toList());
    // return Scaffold(body: list);
    return new Scaffold(
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
            stream: Firestore.instance.collection('tasks').where('userId', isEqualTo: widget.userId).snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return new Text('Loading...');
                default:
                  List<DocumentSnapshot> list = snapshot.data.documents;
                  return new ListView(
                    children: list.map((DocumentSnapshot document) {
                      return new PostToManage(
                        title: document['title'],
                        taskId: document.documentID,
                        status: document['status'],
                        userId: widget.userId,
                        auth: widget.auth,
                        user: this.user,
                        keyForSnack: _scaffoldKey,
                      );
                    }).where((task) => task.status != 'finished').toList(),
                  );
                // return new Text(widget.userId);
              }
            },
          )),
    );
  }

  // List<Widget> _buildPosts() => this
  //     .user
  //     .posts
  //     .map((String uid) => FutureBuilder<DocumentSnapshot>(
  //           future: Firestore.instance.collection('tasks').document(uid).get(),
  //           builder: (BuildContext context,
  //               AsyncSnapshot<DocumentSnapshot> snapshot) {
  //             if (snapshot.data != null)
  //               return ListTile(
  //                 leading: StatusTag.fromString(snapshot.data['status']),
  //                 title: Container(
  //                     child: Column(children: <Widget>[
  //                   Text(snapshot.data['title']),
  //                   Row(
  //                     children: <Widget>[
  //                     ],
  //                   ),
  //                   Container(child:_buildReview(uid),)
  //                   // Column(children: <Widget>[                        
  //                   //   // Expanded(
  //                   //   //     child: _buildReview(uid),
  //                   //   // ),
  //                   //   _buildReview(uid),
  //                   //   ],)
  //                 ])),
  //                 // trailing: Icon(Icons.arrow_forward),
  //                 onTap: () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) => DetailedPage(
  //                         title: snapshot.data['title'],
  //                         id: uid,
  //                         currUserId: widget.userId,
  //                         auth: widget.auth,
  //                         withdrawlButton: false,
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               );
  //             else
  //               return CircularProgressIndicator();
  //           },
  //         ))
  //     .toList();

  // StreamBuilder<QuerySnapshot> _buildReview(taskId) =>
  //     StreamBuilder<QuerySnapshot>(
  //       stream: Firestore.instance
  //           .collection('tasks')
  //           .document(taskId)
  //           .collection('applicants')
  //           .where('accepted', isEqualTo: true)
  //           .snapshots(),
  //       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
  //         if (snapshot.hasError) return Text('Error: ${snapshot.error}');
  //         switch (snapshot.connectionState) {
  //           case ConnectionState.waiting:
  //             return Center(
  //               child: CircularProgressIndicator(),
  //             );
  //           default:
  //             return ListView(
  //               children: snapshot.data.documents
  //                   .map(_buildListTileFromDocument)
  //                   .toList(),
  //             );
  //         }
  //       },
  //     );

  // ListTile _buildListTileFromDocument(DocumentSnapshot document) => ListTile(
  //       // leading: (document['accepted'] as bool)
  //       //     ? Icon(Icons.check_box)
  //       //     : Icon(Icons.check_box_outline_blank),
  //       title: Row(
  //         children: <Widget>[
  //           Avatar(userId: document.documentID),
  //           Container(
  //             width: 10,
  //           ),
  //           _buildTitleFromUsername(document.documentID),
  //           StarRating(
  //             onChanged: (value) {
  //               int number = _updateNumberOfRating(document.documentID);
  //               _updateRating(number, document.documentID, value);
  //             },
  //           ),
  //         ],
  //       ),
  //       // trailing: Icon(Icons.arrow_forward),
  //       // onTap: _navigateToApplicationDetail(document.documentID),
  //     );

  // _updateNumberOfRating(String uid) async {
  //   int number;
  //   await Firestore.instance
  //       .collection("users")
  //       .document(uid)
  //       .get()
  //       .then((DocumentSnapshot doc) {
  //     number = doc['numberOfRate'];
  //     //appliedList.removeWhere((item) => item == widget.id);
  //   });
  //   await Firestore.instance.collection('users').document(uid).updateData({
  //     "numberOfRate": number
  //     //FieldValue.arrayRemove(new List)
  //   });
  //   return number;
  // }

  // _updateRating(int number, String uid, int value) async {
  //   num rate;
  //   await Firestore.instance
  //       .collection("users")
  //       .document(uid)
  //       .get()
  //       .then((DocumentSnapshot doc) {
  //     rate = doc['rating'];
  //     //appliedList.removeWhere((item) => item == widget.id);
  //   });
  //   if (rate == 0) {
  //     rate = value;
  //   } else {
  //     rate = (rate + value) / number;
  //   }
  //   await Firestore.instance.collection('users').document(uid).updateData({
  //     "rating": rate
  //     //FieldValue.arrayRemove(new List)
  //   });
  // }

  // FutureBuilder<DocumentSnapshot> _buildTitleFromUsername(String uid) =>
  //     FutureBuilder<DocumentSnapshot>(
  //       future: Firestore.instance.collection('users').document(uid).get(),
  //       builder:
  //           (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
  //         if (snapshot.hasError) return Text('Error: ${snapshot.error}');
  //         switch (snapshot.connectionState) {
  //           case ConnectionState.waiting:
  //             return Row(
  //               children: <Widget>[CircularProgressIndicator()],
  //             );
  //           default:
  //             return Text(snapshot.data['name']);
  //         }
  //       },
  //     );

  // VoidCallback _navigateToApplicationDetail(String applicantId) => () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => ApplicationDetail(
  //             taskId: taskId,
  //             applicantId: applicantId,
  //           ),
  //         ),
  //       );
  //     };
}
