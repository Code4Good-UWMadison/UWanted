import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thewanted/services/authentication.dart';
import 'package:thewanted/models/user.dart';
import 'package:thewanted/pages/profile/edit_profile.dart';
import 'package:thewanted/pages/profile/my_posts.dart';
import 'package:thewanted/pages/details.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, @required this.auth, @required this.userId})
      : super(key: key);

  final BaseAuth auth;
  final String userId;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User user;

  @override
  Widget build(BuildContext context) {
    if (this.user == null)
      return Center(
        child: CircularProgressIndicator(),
      );
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ExpansionTile(
              title: Text('Profile'),
              children: <Widget>[
                _buildListTile("Name", this.user.userName),
                _buildListTile("Role", this.user.userRoleToString()),
                _buildListTile("Lab", this.user.lab),
                _buildListTile("Major", this.user.major),
                _buildListTile("Technical Skills", this.user.skills.toString()),
                _buildEditProfileTile(),
              ],
            ),
            ExpansionTile(
              title: Text('Posts'),
              children: List.from(_buildPosts())
                ..add(_buildEditPostsListTile()),
            ),
            AboutListTile(icon: null),
          ],
        ).toList(),
      ),
    );
  }

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

  ListTile _buildListTile(String title, String trailing) => ListTile(
        title: Text(title),
        trailing: Text(trailing),
        onTap: _navigateToProfileEditingPage,
      );

  void _navigateToProfileEditingPage() async {
    User user = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditProfilePage(
              auth: widget.auth,
              userId: widget.userId,
              user: User.clone(this.user))),
    );
    setState(() {
      this.user = (user != null ? user : this.user);
    });
  }

  ListTile _buildEditProfileTile() => ListTile(
        title: Text('Edit Profile'),
        trailing: Icon(Icons.chevron_right),
        onTap: _navigateToProfileEditingPage,
      );

  ListTile _buildEditPostsListTile() => ListTile(
        title: Text('Edit Posts'),
        trailing: Text(this.user.posts.length.toString()),
        onTap: _navigateToPostsEditingPage,
      );

  void _navigateToPostsEditingPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyPostsPage(
          auth: widget.auth,
          userId: widget.userId,
          posts: this.user.posts,
        ),
      ),
    );
  }

  List<Widget> _buildPosts() => user.posts
      .map((String uid) => FutureBuilder<DocumentSnapshot>(
            future: Firestore.instance.collection('tasks').document(uid).get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.data != null)
                return ListTile(
                  title: Text(snapshot.data['title']),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailedPage(
                          title: snapshot.data['title'],
                          id: uid,
                        ),
                      ),
                    );
                  },
                );
              else
                return CircularProgressIndicator();
            },
          ))
      .toList();
}

// Call this like
// appendListToRemotePosts([UidOfTask,], userId);
// For appending multiple posts
// appendListToRemotePosts([UidOfTask1, UidOfTask2], userId);
appendListToRemotePosts(List<String> newPosts, String userId) {
  Firestore.instance
      .collection('users')
      .document(userId)
      .get()
      .then((DocumentSnapshot document) {
    List<String> updatedPosts =
        List<String>.from(document['posts'], growable: true);
    updatedPosts.addAll(newPosts);
    Firestore.instance.collection('users').document(userId).updateData({
      'posts': updatedPosts,
    });
  });
}
