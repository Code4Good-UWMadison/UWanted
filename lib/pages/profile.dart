import 'package:flutter/material.dart';
import '../services/authentication.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key) {
//    get user profile from server
    this.userName = "Kyle Wang";
    this.userRole = UserRole.Student;
    this.lab = "";
    this.major = "Computer Science";
    this.skills = [Skills.AIML, Skills.Data, Skills.App];
  }

  final title = "Profile";

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  String userName;
  UserRole userRole;
  String lab;
  String major;
  List<Skills> skills;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text("Name"),
            trailing: Text(this.userName),
            onTap: () {},
          ),
          ListTile(
            title: Text("Role"),
            trailing: Text(this.userRole.toString().substring(9)),
            onTap: () {},
          ),
          ListTile(
            title: Text("Lab"),
            trailing: Text(this.lab),
            onTap: () {},
          ),
          ListTile(
            title: Text("Major"),
            trailing: Text(this.major),
            onTap: () {},
          ),
          ListTile(
            title: Text("Technical Skills"),
            trailing: Text(this.skills.toString()),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

enum UserRole {
  Student,
  Faculty,
}

enum Skills {
  Backend,
  Frontend,
  AIML,
  Data,
  App,
  Others,
}