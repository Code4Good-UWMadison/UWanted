import 'package:flutter/material.dart';
import '../../services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thewanted/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:thewanted/pages/components/avatar.dart';
import './faculty_edit_profile.dart';

class FacultyDrawerPage extends StatefulWidget {
  FacultyDrawerPage(
      {Key key,
      @required this.auth,
      @required this.userId,
      this.isInDrawer = true})
      : super(key: key);

  final BaseAuth auth;
  final String userId;
  final bool isInDrawer;

  @override
  _FacultyDrawerPageState createState() => _FacultyDrawerPageState();
}

class _FacultyDrawerPageState extends State<FacultyDrawerPage> {
  User user;
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
            _buildDrawerHeader(),
            _buildListTile("Role", this.user.userRoleToString()),
            _buildListTile("Lab", this.user.lab),
            _buildButton(),
            AboutListTile(icon: null),
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

  _initializeRemoteUserDataIfNotExist(DocumentSnapshot document) {
    if (!document.exists) {
      Firestore.instance
          .collection('users')
          .document(widget.userId)
          .setData(User.initialUserData);
    }
  }

  _getRemoteUserData(_) {
    Firestore.instance
        .collection('users')
        .document(widget.userId)
        .get()
        .then(_setLocalUserData);
  }

  _setLocalUserData(DocumentSnapshot document) {
    if (this.mounted) {
      setState(() {
        this.user = User.fromDocument(document);
      });
    }
  }

  UserAccountsDrawerHeader _buildDrawerHeader() {
    return new UserAccountsDrawerHeader(
      decoration: BoxDecoration(color: Colors.blue),
      // accountName: Padding(
      //   padding: EdgeInsets.fromLTRB(10, 30, 0, 0),
      //   child: Text(this.user.userName,
      //   style: TextStyle(fontSize: 20.0),
      // ),),
      accountName: new Container(
        child: new Text(
          "Hi," + this.user.userName,
          style: TextStyle(fontSize: 20.0),
        ),
      ),
      accountEmail: new Container(child: new Text("Enjoy your day~ ")),
      currentAccountPicture: Avatar(userId: widget.userId, radius: 30),
      // onDetailsPressed: () {},
    );
  }

  //  Future uploadPic(BuildContext context) async{
  //     String fileName = "profile";
  //      StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
  //      StorageUploadTask uploadTask = firebaseStorageRef.putFile(_img);
  //      StorageTaskSnapshot taskSnapshot=await uploadTask.onComplete;
  //      setState(() {
  //         print("Profile Picture uploaded");
  //         Scaffold.of(context).showSnackBar(SnackBar(content: Text('Profile Picture Uploaded')));
  //      });
  //   }

  ListTile _buildListTile(String title, String trailing) => ListTile(
        title: Text(title),
        trailing: Text(trailing),
      );

  ListTile _buildButton() => ListTile(
        title: Text("Edit Profile"),
        trailing: Icon(Icons.edit),
        onTap: _navigateToProfileEditingPage,
      );

  void _navigateToProfileEditingPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FacultyEditProfilePage(
              auth: widget.auth,
              userId: widget.userId,
              user: User.clone(this.user))),
    );

    _getRemoteUserData(null);
  }
  //   leading: Icon(Icons.edit),
  // title: Text('Edit Profile'),
  // trailing: Icon(Icons.arrow_forward),
  // onTap: _navigateToProfileEditingPage,
}
