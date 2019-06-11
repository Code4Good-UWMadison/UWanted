import 'dart:async';
import 'package:flutter/material.dart';
import '../services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.auth, this.userId}) : super(key: key);

  final BaseAuth auth;
  final String userId;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User user;

  @override
  void initState() {
    super.initState();
    _getUserProfileFromFirebase();
  }

  void _getUserProfileFromFirebase() {
    User user;
    Firestore.instance
        .collection('users')
        .document(widget.userId)
        .get()
        .then((DocumentSnapshot document) {
      user = User(
        userName: document['name'],
        userRole: document['student']
            ? UserRole.Student
            : (document['faculty'] ? UserRole.Faculty : null),
        lab: document['lab'],
        major: document['major'],
        skills: Skills(
          backend: document['Backend'],
          frontend: document['Frontend'],
          aiml: document['AI&ML'],
          data: document['Data'],
          app: document['App'],
          others: document['Others'],
        ),
      );
      setState(() {
        this.user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (this.user == null)
      return Center(
        child: Text("loading"),
      );
    return Scaffold(
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            _buildListTile("Name", this.user.userName, context),
            _buildListTile(
                "Role", this.user.userRole.toString().substring(9), context),
            _buildListTile("Lab", this.user.lab, context),
            _buildListTile("Major", this.user.major, context),
            _buildListTile(
                "Technical Skills", this.user.skills.toString(), context),
          ],
        ).toList(),
      ),
    );
  }

  ListTile _buildListTile(
          String title, String trailing, BuildContext context) =>
      ListTile(
        title: Text(title),
        trailing: Text(trailing),
        onTap: _navigateToEditingPage,
      );

  void _navigateToEditingPage() async {
    User user = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditProfilePage(
              auth: widget.auth, userId: widget.userId, user: this.user)),
    );
    setState(() {
      this.user = (user != null ? user : this.user);
    });
  }
}

class EditProfilePage extends StatefulWidget {
  EditProfilePage({Key key, this.auth, this.userId, this.user})
      : super(key: key);

  final BaseAuth auth;
  final String userId;
  final User user;

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _nameController;
  TextEditingController _labController;
  TextEditingController _majorController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.user.userName);
    _labController = TextEditingController(text: widget.user.lab);
    _majorController = TextEditingController(text: widget.user.major);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Edit Profile"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _submit();
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            _buildForm(_nameController, "Name", 'Name cannot be empty',
                (value) {
              if (value.isEmpty) return 'Name cannot be empty!';
            }),
            _buildRoleCheckboxs(),
            _buildForm(_labController, "Lab", 'Lab can be empty', null),
            _buildForm(_majorController, "Major", 'Major cannot be empty',
                (value) {
              if (value.isEmpty) return 'Major cannot be empty!';
            }),
            _buildSkillsCheckboxs(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                onPressed: () {
                  _submit();
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _nameController.dispose();
    _labController.dispose();
    _majorController.dispose();
  }

  Container _buildForm(TextEditingController controller, String label,
      String helper, Function validator) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
        ),
        validator: validator,
      ),
    );
  }

  Column _buildSkillsCheckboxs() => Column(
        children: <Widget>[
          ListTile(
            title: Text('Skills'),
          ),
          Row(
            children: <Widget>[
              _buildSkillsCheckbox("Backend"),
              _buildSkillsCheckbox("Frontend"),
            ],
          ),
          Row(
            children: <Widget>[
              _buildSkillsCheckbox("AI&ML"),
              _buildSkillsCheckbox("Data"),
            ],
          ),
          Row(
            children: <Widget>[
              _buildSkillsCheckbox("App"),
              _buildSkillsCheckbox("Others"),
            ],
          ),
        ],
      );

  Flexible _buildSkillsCheckbox(String title) => Flexible(
        child: CheckboxListTile(
          value: widget.user.skills.get(title),
          title: Text(title),
          onChanged: (bool) {
            setState(() {
              widget.user.skills.set(title, bool);
            });
          },
        ),
      );

  Row _buildRoleCheckboxs() => Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 0, 0),
            child: Text(
              'Role',
              style: TextStyle(fontSize: 17),
            ),
          ),
          Flexible(
            child: RadioListTile<UserRole>(
              value: UserRole.Student,
              title: Text('Student'),
              groupValue: widget.user.userRole,
              onChanged: (value) {
                setState(() {
                  widget.user.userRole = value;
                });
              },
            ),
          ),
          Flexible(
            child: RadioListTile<UserRole>(
              value: UserRole.Faculty,
              title: Text('Faculty'),
              groupValue: widget.user.userRole,
              onChanged: (value) {
                setState(() {
                  widget.user.userRole = value;
                });
              },
            ),
          ),
        ],
      );

  void _submit() {
    if (_formKey.currentState.validate()) {
      Firestore.instance
          .collection('users')
          .document(widget.userId)
          .updateData(getData())
            ..then((_) async {
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text('Success!'),
              ));
              await new Future.delayed(const Duration(milliseconds: 1000));
              Navigator.pop(
                  context,
                  User(
                      userName: _nameController.text,
                      userRole: widget.user.userRole,
                      lab: _labController.text,
                      major: _majorController.text,
                      skills: widget.user.skills));
            })
            ..catchError((e) {
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text('Please retry! $e'),
              ));
            });
    }
  }

  Map<String, dynamic> getData() {
    return {
      'name': _nameController.text,
      'faculty': widget.user.userRole == UserRole.Faculty ? true : false,
      'student': widget.user.userRole == UserRole.Student ? true : false,
      'lab': _labController.text,
      'major': _majorController.text,
      'Backend': widget.user.skills.backend,
      'Frontend': widget.user.skills.frontend,
      'AI&ML': widget.user.skills.aiml,
      'Data': widget.user.skills.data,
      'App': widget.user.skills.app,
      'Others': widget.user.skills.others,
    };
  }
}

class User {
  String userName;
  UserRole userRole;
  String lab;
  String major;
  Skills skills;

  User({this.userName, this.userRole, this.lab, this.major, this.skills});
}

enum UserRole {
  Student,
  Faculty,
}

enum Skill {
  Backend,
  Frontend,
  AIML,
  Data,
  App,
  Others,
}

class Skills {
  bool backend;
  bool frontend;
  bool aiml;
  bool data;
  bool app;
  bool others;

  Skills(
      {this.backend = false,
      this.frontend = false,
      this.aiml = false,
      this.data = false,
      this.app = false,
      this.others = false});

  void set(String skill, bool bool) {
    switch (skill) {
      case 'Backend':
        this.backend = bool;
        break;
      case 'Frontend':
        this.frontend = bool;
        break;
      case 'AI&ML':
        this.aiml = bool;
        break;
      case 'Data':
        this.data = bool;
        break;
      case 'App':
        this.app = bool;
        break;
      case 'Others':
        this.others = bool;
        break;
      default:
    }
  }

  bool get(String skill) {
    switch (skill) {
      case 'Backend':
        return this.backend;
        break;
      case 'Frontend':
        return this.frontend;
        break;
      case 'AI&ML':
        return this.aiml;
        break;
      case 'Data':
        return this.data;
        break;
      case 'App':
        return this.app;
        break;
      case 'Others':
        return this.others;
        break;
      default:
        return null;
    }
  }

  @override
  String toString() {
    String str = '';
    str += (this.backend ? 'Backend, ' : '') +
        (this.frontend ? 'Frontend, ' : '') +
        (this.aiml ? 'AI&ML, ' : '') +
        (this.data ? 'Data, ' : '') +
        (this.app ? 'APP, ' : '') +
        (this.others ? 'Others, ' : '');
    return str.length > 0 ? str.substring(0, str.length - 2) : str;
  }
}
