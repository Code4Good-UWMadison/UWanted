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
      ),
      body: ListView(
        children: this.posts.entries.map(_buildListTileFromPosts).toList(),
      ),
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
          this.posts[uid] = document['title'];
        });
      });
    });
  }

  ListTile _buildListTileFromPosts(MapEntry<String, String> entry) {
    return ListTile(
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
  }
}
