import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thewanted/models/skills.dart';

class User {
  String userName;
  UserRole userRole;
  String lab;
  String major;
  Skills skills;
  List<String> posts;

  User(
      {this.userName,
      this.userRole,
      this.lab,
      this.major,
      this.skills,
      this.posts});

  User.clone(User user)
      : this(
          userName: user.userName,
          userRole: user.userRole,
          lab: user.lab,
          major: user.major,
          skills: Skills.clone(user.skills),
          posts: List.from(user.posts, growable: true),
        );

  User.fromDocument(DocumentSnapshot document)
      : userName = document['name'],
        userRole = document['student']
            ? UserRole.Student
            : (document['faculty'] ? UserRole.Faculty : null),
        lab = document['lab'],
        major = document['major'],
        skills = Skills(
          backend: document['Backend'],
          frontend: document['Frontend'],
          aiml: document['AI&ML'],
          data: document['Data'],
          app: document['App'],
          others: document['Others'],
        ),
        posts = List.from(document['posts'], growable: true);

  // userRole could be null, that user haven't made a choice
  String userRoleToString() => userRole?.toString()?.substring(9) ?? '';

  static final initialUserData = {
    'name': '',
    'faculty': false,
    'student': false,
    'lab': '',
    'major': '',
    'Backend': false,
    'Frontend': false,
    'AI&ML': false,
    'Data': false,
    'App': false,
    'Others': false,
    'posts': List<String>(),
    'created': Timestamp.now(),
    'updated': Timestamp.now(),
  };
}

enum UserRole {
  Student,
  Faculty,
}