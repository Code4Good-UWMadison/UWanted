import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thewanted/services/authentication.dart';
import 'package:thewanted/pages/details.dart';

class MyPostsPage extends StatefulWidget {
  MyPostsPage(
      {Key key,
      @required this.auth,
      @required this.userId,
      @required this.posts})
      : super(key: key);

  final BaseAuth auth;
  final String userId;
  final List<String> posts;

  @override
  _MyPostsPageState createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  Map<String, String> posts = Map<String, String>();
  Map postss = Map();
  bool _isEditing = false;

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
      appBar: AppBar(
        title: Text("My Posts"),
        actions: <Widget>[
          _isEditing ? _doneButton() : _editButton(),
        ],
      ),
      body: ListView(
        // children: this.posts.entries.map(_buildListTileFromPosts).toList(),
        children: this.postss.entries.map(_buildListTileFromPostss).toList(),
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
          this.postss[uid] = {
            'uid': uid,
            'title': document['title'],
            'isChecked': false,
          };
          this.posts[uid] = document['title'];
        });
      });
    });
  }

  ListTile _buildListTileFromPosts(MapEntry<String, String> entry) => ListTile(
        leading: _isEditing
            ? Checkbox(
                value: null,
                onChanged: null,
              )
            : null,
        title: Text(entry.value),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailedPage(
                title: entry.value,
                id: entry.key,
              ),
            ),
          );
        },
      );

  ListTile _buildListTileFromPostss(MapEntry entry) => ListTile(
        leading: _isEditing
            ? Checkbox(
                value: this.postss[entry.key]['isChecked'],
                onChanged: (bool value) {
                  setState(() {
                    this.postss[entry.key]['isChecked'] = value;
                  });
                },
              )
            : null,
        title: Text(entry.value['title']),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailedPage(
                title: entry.value['title'],
                id: entry.key,
              ),
            ),
          );
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
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
}
