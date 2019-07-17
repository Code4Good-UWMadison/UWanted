import 'package:flutter/material.dart';
import 'package:thewanted/pages/send_request.dart';
import '../services/authentication.dart';
import '../pages/profile.dart';
import '../pages/send_request.dart';
import './dashboard.dart';
import '../pages/drawer.dart';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  int _selectedIndex;
  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
    _selectedIndex = 0;
    _getUserProfileFromFirebase();
  }

// check if the user is registered or not, if not, skip to profile page instead of dashboard *changed from Profile.dart
  void _getUserProfileFromFirebase() {
    Firestore.instance
        .collection('users')
        .document(widget.userId)
        .get()
        .then(_initializeRemoteUserDataIfNotExist);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _initializeRemoteUserDataIfNotExist(DocumentSnapshot document) {
    if (!document.exists || document.data['name'] == "") {
      print("add Profile!");
      setState(() {
        _selectedIndex = 2;
      });
      showInSnackBar();
    } 
  }

  void showInSnackBar() {
    _scaffoldKey.currentState.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
          'Please fill out your information first if you want to publish requests'),
      duration: const Duration(minutes: 5),
      action: SnackBarAction(
        label: 'I\'ll do that later',
        onPressed: () {
          _scaffoldKey.currentState.removeCurrentSnackBar();
        },
      ),
    ));
  }

  bool _isEmailVerified = false;

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }

  void _resentVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Please verify account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resent link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content:
              new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  _newTask() async {
    setState(() {
      _selectedIndex = 1;
      _getUserProfileFromFirebase();
    });
  }

  final List<String> entries = <String>['A', 'B', 'C'];
  final List<int> colorCodes = <int>[600, 500, 100];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if(_selectedIndex == 1){
        _getUserProfileFromFirebase();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _pageOptions = [
      DashboardPage(userId: widget.userId, auth: widget.auth),
      SendRequest(userId: widget.userId, auth: widget.auth),
      ProfilePage(userId: widget.userId, auth: widget.auth),
    ];
    final _pageName = ["Dashboard", "Send Request", "Profile"];
    return new Scaffold(
      key: _scaffoldKey, // used to add snackbar
      appBar: new AppBar(
        // automaticallyImplyLeading: false,
        title: new Text(_pageName[_selectedIndex]),
        actions: <Widget>[
          new FlatButton(
            child: new Text('Logout',
                style: new TextStyle(fontSize: 17.0, color: Colors.white)),
            onPressed: _signOut,
          )
        ],
      ),
      body: _pageOptions[_selectedIndex],
      drawer: Drawer(
        child: DrawerPage(userId: widget.userId, auth: widget.auth),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _newTask, // generate a new task
        tooltip: 'Request',
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Dashboard'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            title: Text('Send Request'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            title: Text('Profile'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
