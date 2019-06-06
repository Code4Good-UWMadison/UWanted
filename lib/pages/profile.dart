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
      body: ListView(
        children: <Widget>[
          _buildListTile("Name", this.userName, null),
          _buildListTile("Role", this.userRole.toString().substring(9), null),
          _buildListTile("Lab", this.lab, null),
          _buildListTile("Major", this.major, null),
          _buildListTile("Technical Skills", this.skills.toString(), null),
        ],
      ),
    );
  }

  ListTile _buildListTile(String title, String trailing, Function onTap) =>
      ListTile(
        title: Text(title),
        trailing: Text(trailing),
        onTap: onTap,
      );
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
