import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thewanted/services/authentication.dart';
import 'package:thewanted/pages/details.dart';
import 'package:thewanted/pages/status_tag.dart';
import '../send_request_page/send_request_refactored.dart';
import 'package:thewanted/pages/profile/applicants_list.dart';

class MyPostsPage extends StatefulWidget {
  MyPostsPage({
    Key key,
    @required this.auth,
    @required this.userId,
    @required this.posts,
    // @required this.skipToProfile
  }) : super(key: key);

  final BaseAuth auth;
  final String userId;
  final List<String> posts;

  // final Function() skipToProfile;

  @override
  _MyPostsPageState createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  Map<String, Map<String, dynamic>> posts = Map<String, Map<String, dynamic>>();
  bool _isEditing = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final Firestore db = Firestore.instance;

  @override
  void initState() {
    super.initState();
    _getPostsFromRemote();
  }

  @override
  Widget build(BuildContext context) {
    if (this.posts == null)
      return Center(
        child: CircularProgressIndicator(),
      );
    return Scaffold(
      key: this._scaffoldKey,
      appBar: AppBar(
        title: Text("My Posts"),
        actions: <Widget>[
          _isEditing ? _doneButton() : _editButton(),
        ],
      ),
      body: ListView(
        children: this.posts.entries.map(_buildListTileFromPosts).toList(),
      ),
      bottomNavigationBar: _isEditing ? _bottomDeleteBar() : null,
    );
  }

  void _getPostsFromRemote() {
    widget.posts.forEach((String uid) {
      Firestore.instance
          .collection('tasks')
          .document(uid)
          .get()
          .then((DocumentSnapshot document) {
        setState(() {
          this.posts[uid] = {
            'uid': uid,
            'title': document['title'],
            'isChecked': false,
            'status': document['status'],
          };
        });
      });
    });
  }

  ListTile _buildListTileFromPosts(MapEntry entry) => ListTile(
        leading: _isEditing
            ? Checkbox(
                value: this.posts[entry.key]['isChecked'],
                onChanged: (bool value) {
                  setState(() {
                    this.posts[entry.key]['isChecked'] = value;
                  });
                },
              )
            : null,
        title: Row(
          children: <Widget>[
            Text(entry.value['title']),
            StatusTag.fromString(this.posts[entry.key]['status']),
          ],
        ),
        trailing: Row(
          //Merged here
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 50,
              child: FlatButton(
                child: Icon(Icons.list),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ApplicantsList(taskId: entry.key),
                      )).then((_) {
                    setState(() {
                      this._getPostsFromRemote();
                    });
                  });
                },
              ),
            ),
            Container(
              width: 50,
              child: FlatButton(
                child: Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestForm(
                        needUpdate: true,
                        postId: entry.key,
                      ),
                      )).then((_) {
                    setState(() {
                      this._getPostsFromRemote();
                    });
                  });
                },
              ),
            ),
          ],
        ), //to here
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailedPage(
                title: entry.value['title'],
                id: entry.key,
                currUserId: widget.userId,
                auth: widget.auth,
                withdrawlButton: false,
              ),
            ),
          ).then((_) {
            setState(() {
              this._getPostsFromRemote();
            });
          });
        },
      );

  FlatButton _editButton() => FlatButton(
        child:
            Text('Edit', style: TextStyle(color: Colors.white, fontSize: 18.0)),
        onPressed: () => setState(() {
          _isEditing = true;
        }),
      );

  FlatButton _doneButton() => FlatButton(
        child:
            Text('Done', style: TextStyle(color: Colors.white, fontSize: 18.0)),
        onPressed: () => setState(() {
          _isEditing = false;
        }),
      );

  BottomAppBar _bottomDeleteBar() => BottomAppBar(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border:
                Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          height: 50.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FlatButton(
                child: Text('Delete',
                    style: TextStyle(color: Colors.blue, fontSize: 16.0)),
                onPressed:
                    _getCheckedList().isNotEmpty ? _showAlertDialog : null,
              ),
              FlatButton(
                child: Text('Archive',
                    style: TextStyle(color: Colors.blue, fontSize: 16.0)),
                onPressed:
                    _getCheckedList().isNotEmpty ? _archiveRequest : null,
              )
            ],
          ),
        ),
      );

  List<String> _getCheckedList() {
    List<String> _checkedList = List<String>();
    this.posts.forEach((String uid, Map<String, dynamic> details) {
      if (details['isChecked']) {
        _checkedList.add(uid);
      }
    });
    return _checkedList;
  }

  List<String> _getUncheckedList() {
    List<String> _uncheckedList = List<String>();
    this.posts.forEach((String uid, Map<String, dynamic> details) {
      if (!details['isChecked']) {
        _uncheckedList.add(uid);
      }
    });
    return _uncheckedList;
  }

  Future<void> _showAlertDialog() async {
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
              onPressed: _updateRemoteData,
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

  //change status to finished
  _archiveRequest() {
    _getCheckedList().forEach((String uid) {
      db.collection('tasks').document(uid).updateData({'status': 'finished'});
    });
    setState(() {
      _getPostsFromRemote();
    });
  }

  _updateRemoteData() {
    _deleteCheckedTasksFromFirestore()
        .then((_) => _updateRemoteUserPosts())
        .then((_) => _updateWidgetPosts())
        .then((_) => _updateThisPosts())
        .then((_) => _showSnackbarThenWait1sec('Success!'))
        .then((_) => Navigator.of(context).pop())
        .catchError((e) => _showSnackbarThenWait1sec('Delete failed! $e'));
  }

  Future<void> _deleteCheckedTasksFromFirestore() async {
    _getCheckedList().forEach((String uid) async {
      await db.collection('tasks').document(uid).delete();
    });
  }

  Future<void> _updateRemoteUserPosts() => db
      .collection('users')
      .document(widget.userId)
      .updateData({'posts': _getUncheckedList()});

  Future<void> _updateWidgetPosts() => db
          .collection('users')
          .document(widget.userId)
          .get()
          .then((DocumentSnapshot document) {
        setState(() {
          widget.posts.clear();
          widget.posts.addAll(List.from(document['posts']));
        });
      });

  Future<void> _updateThisPosts() async {
    setState(() {
      this.posts = new Map<String, Map<String, dynamic>>();
    });
    widget.posts.forEach((String uid) {
      db
          .collection('tasks')
          .document(uid)
          .get()
          .then((DocumentSnapshot document) {
        setState(() {
          this.posts[uid] = {
            'uid': uid,
            'title': document['title'],
            'isChecked': false,
            'status': document['status'],
          };
        });
      });
    });
  }

  Future<void> _showSnackbarThenWait1sec(String msg) async {
    this._scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }
}
