import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thewanted/services/authentication.dart';
import 'package:thewanted/models/user.dart';
import 'package:thewanted/pages/profile/edit_profile.dart';
import 'package:thewanted/pages/profile/my_posts.dart';
import 'package:thewanted/pages/details.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  File _image;
  String _imageUrl;

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
              initiallyExpanded: true,
              title: Text('Profile'),
              children: <Widget>[
                _buildProfile(),
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
            // AboutListTile(icon: null),
          ],
        ).toList(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // init profile's url
    var ref = FirebaseStorage.instance
        .ref()
        .child('user')
        .child(widget.userId)
        .child('profile.jpg');
    ref.getDownloadURL().then((loc) => setState(() => _imageUrl = loc));
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

  Row _buildProfile() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(width: 50, height: 0),
          Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: new SizedBox(
                  width: 180.0,
                  height: 180.0,
                  child: (_imageUrl == null)
                      ? (Icon(
                          Icons.account_circle,
                          size: 50.0,
                          color: Colors.white,
                        ))
                      : (_image != null)
                          ? Image.file(
                              _image,
                              // fit: BoxFit.fill,
                            )
                          : Image.network(
                              _imageUrl,
                              // fit: BoxFit.fill,
                            ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 120.0),
            child: IconButton(
              icon: Icon(
                FontAwesomeIcons.camera,
                size: 30.0,
              ),
              onPressed: () {
                getImage();
              },
            ),
          ),
          (_image != null)
              ? RaisedButton(
                  color: Color(0xff476cfb),
                  onPressed: () {
                    uploadPic(context);
                  },
                  elevation: 4.0,
                  splashColor: Colors.blueGrey,
                  child: Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                )
              : new Container(width: 0, height: 0),
        ],
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

//////
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      print('Image Path $_image');
    });
  }

  Future uploadPic(BuildContext context) async {
    StorageReference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('user')
        .child(widget.userId)
        .child('profile.jpg');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    setState(() {
      _image = null;
      var ref = FirebaseStorage.instance
          .ref()
          .child('user')
          .child(widget.userId)
          .child('profile.jpg');
      ref.getDownloadURL().then((loc) => setState(() => _imageUrl = loc));
      print("Profile Picture uploaded");
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Profile Picture Uploaded')));
    });
  }
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
