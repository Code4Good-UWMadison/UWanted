import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../services/authentication.dart';
import '../pages/profile.dart';
import 'send_request_page/send_request_refactored.dart';
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
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  int _selectedIndex;

  bool _disableNavi = false;
  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
    _selectedIndex = 0;
    _getUserProfileFromFirebase();
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        print(data);
        _saveDeviceToken();
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken();
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        // final snackbar = SnackBar(
        //   content: Text(message['notification']['title']),
        //   action: SnackBarAction(
        //     label: 'Go',
        //     onPressed: () => null,
        //   ),
        // );

        // Scaffold.of(context).showSnackBar(snackbar);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.amber,
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  @override
  void dispose() {
    if (iosSubscription != null) iosSubscription.cancel();
    super.dispose();
  }

  /// Get the token, save it to the database for current user
  _saveDeviceToken() async {
    // Get the current user
    String uid = widget.userId;
    // FirebaseUser user = await _auth.currentUser();

    // Get the token for this device
    _fcm.getToken().then((String fcmToken) {
      if (fcmToken != null) {
        print(fcmToken);
        DocumentReference tokens = _db
            .collection('users')
            .document(uid)
            .collection('tokens')
            .document(fcmToken);

        tokens.setData({
          'token': fcmToken,
          'createdAt': DateTime.now(), // optional
          'platform': Platform.operatingSystem // optional
        });
      }
    });
    // Save it to Firestore
  }

  // /// Subscribe the user to a topic
// _subscribeToTopic() async {
//     // Subscribe the user to a topic
//     _fcm.subscribeToTopic('puppies');
//   }
// }

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

  // _newTask() async {
  //   setState(() {
  //     _selectedIndex = 1;
  //     _getUserProfileFromFirebase();
  //   });
  // }

  void _onItemTapped(int index) {
    if (_disableNavi == false) {
      setState(() {
        _selectedIndex = index;
        if (_selectedIndex == 1) {
          _getUserProfileFromFirebase();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _pageOptions = [
      DashboardPage(userId: widget.userId, auth: widget.auth),
      RequestForm(
        userId: widget.userId,
        auth: widget.auth,
        needUpdate: false,
      ),
      ProfilePage(
          userId: widget.userId,
          auth: widget.auth,
          uploading: () {
            setState(() {
              _disableNavi = true;
            });
          },
          finishUploading: () {
            setState(() {
              _disableNavi = false;
            });
          }),
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _newTask, // generate a new task
      //   tooltip: 'Request',
      //   child: Icon(Icons.add),
      // ),
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
