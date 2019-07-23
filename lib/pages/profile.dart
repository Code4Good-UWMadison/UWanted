import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './details.dart';
import 'package:thewanted/services/authentication.dart';
import 'package:thewanted/models/user.dart';
import 'package:thewanted/pages/profile/edit_profile.dart';
import 'package:thewanted/pages/profile/my_posts.dart';
import 'package:thewanted/pages/details.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:thewanted/pages/status_tag.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
bool _isLoading = false;

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
      var list = ListView(
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
      );
              var bodyProgress = new Container(
            child: new Stack(
              children: <Widget>[
                list,
                new Container(
                  alignment: AlignmentDirectional.center,
                  decoration: new BoxDecoration(
                    color: Colors.white70,
                  ),
                  child: new Container(
                    decoration: new BoxDecoration(
                      color: Colors.blue[200],
                      borderRadius: new BorderRadius.circular(10.0)
                    ),
                    width: 300.0,
                    height: 200.0,
                    alignment: AlignmentDirectional.center,
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Center(
                          child: new SizedBox(
                            height: 50.0,
                            width: 50.0,
                            child: new CircularProgressIndicator(
                              value: null,
                              strokeWidth: 7.0,
                            ),
                          ),
                        ),
                        new Container(
                          margin: const EdgeInsets.only(top: 25.0),
                          child: new Center(
                            child: new Text(
                              "loading.. wait...",
                              style: new TextStyle(
                                color: Colors.white
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
    return Scaffold(
      key: _scaffoldKey,
      body: _isLoading ? bodyProgress :list
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
    ref
        .getDownloadURL()
        .then((loc) => setState(() => _imageUrl = loc))
        .catchError((err) {
      _imageUrl = null;
    });
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
                  child: (_imageUrl == null && _image == null)
                      ? (Icon(
                          Icons.account_circle,
                          size: 180.0,
                          color: Colors.blue,
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
                    // _onLoading(context);
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
                  leading: StatusTag.fromString(snapshot.data['status']),
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
      _imageUrl = null;
      _image = image;
      print('Image Path $_image');
    });
  }

  // void _onLoading(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     child: new Dialog(
  //       child: new Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           new CircularProgressIndicator(),
  //           new Text("Loading"),
  //         ],
  //       ),
  //     ),
  //   );
  //   new Future.delayed(new Duration(seconds: 1), () {
  //     Navigator.pop(context); //pop dialog
  //     uploadPic(context);
  //   });
  // }

  Future uploadPic(BuildContext context) async {
    StorageReference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('user')
        .child(widget.userId)
        .child('profile.jpg');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    uploadTask.events.listen((event) {
      setState(() {
        _isLoading = true;
      });
    }).onError((error) {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(error.toString()),
        backgroundColor: Colors.red,
      ));
    });
    uploadTask.onComplete.then((snapshot) {
      // setState(() {
      //   _isLoading = false;
      // });
      setState(() {
        _isLoading = false;
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
    });
    // StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    // setState(() {
    //   _image = null;
    //   var ref = FirebaseStorage.instance
    //       .ref()
    //       .child('user')
    //       .child(widget.userId)
    //       .child('profile.jpg');
    //   ref.getDownloadURL().then((loc) => setState(() => _imageUrl = loc));
    //   print("Profile Picture uploaded");
    //   Scaffold.of(context)
    //       .showSnackBar(SnackBar(content: Text('Profile Picture Uploaded')));
    // });
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