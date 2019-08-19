import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thewanted/services/authentication.dart';
import 'package:thewanted/models/user.dart';

class FacultyEditProfilePage extends StatefulWidget {
  FacultyEditProfilePage(
      {Key key,
      @required this.auth,
      @required this.userId,
      @required this.user})
      : super(key: key);

  final BaseAuth auth;
  final String userId;
  final User user;

  @override
  _FacultyEditProfilePageState createState() => _FacultyEditProfilePageState();
}

class _FacultyEditProfilePageState extends State<FacultyEditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _nameController;
  TextEditingController _labController;
  // TextEditingController _majorController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.user.userName);
    _labController = TextEditingController(text: widget.user.lab);
    // _majorController = TextEditingController(text: widget.user.major);
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
            onPressed: _isSubmitting ? null : _submit,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            _buildNameForm(),
            _buildRoleCheckboxs(),
            _buildLabForm(),
            // _buildMajorForm(),
            // _buildSkillsCheckboxs(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                onPressed: _isSubmitting ? null : _submit,
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
    // _majorController.dispose();
  }

  _buildNameForm() => _buildForm(
      _nameController, "Name", 'Name cannot be empty', _nameValidator);

  _buildLabForm() =>
      _buildForm(_labController, "Lab", 'Lab can be empty', null);

  // _buildMajorForm() => _buildForm(
      // _majorController, "Major", 'Major cannot be empty', _majorValidator);

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

  String _nameValidator(String value) {
    if (value.isEmpty) return 'Name cannot be empty!';
    return null;
  }

  // String _majorValidator(String value) {
  //   if (value.isEmpty) return 'Major cannot be empty!';
  //   return null;
  // }

  // Column _buildSkillsCheckboxs() => Column(
  //       children: <Widget>[
  //         ListTile(
  //           title: Text('Skills'),
  //         ),
  //         Row(
  //           children: <Widget>[
  //             _buildSkillsCheckbox("Backend"),
  //             _buildSkillsCheckbox("Frontend"),
  //           ],
  //         ),
  //         Row(
  //           children: <Widget>[
  //             _buildSkillsCheckbox("AI&ML"),
  //             _buildSkillsCheckbox("Data"),
  //           ],
  //         ),
  //         Row(
  //           children: <Widget>[
  //             _buildSkillsCheckbox("App"),
  //             _buildSkillsCheckbox("Others"),
  //           ],
  //         ),
  //       ],
  //     );

  // Flexible _buildSkillsCheckbox(String title) => Flexible(
  //       child: CheckboxListTile(
  //         value: widget.user.skills.get(title),
  //         title: Text(title),
  //         onChanged: (bool) {
  //           setState(() {
  //             widget.user.skills.set(title, bool);
  //           });
  //         },
  //       ),
  //     );

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

  bool _isSubmitting = false;

  void _submit() {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      Firestore.instance
          .collection('users')
          .document(widget.userId)
          .updateData(formateEditedData())
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
                      // major: _majorController.text,
                      // skills: widget.user.skills,
                      posts: widget.user.posts));
              setState(() {
                _isSubmitting = false;
              });
            })
            ..catchError((e) {
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text('Please retry! $e'),
              ));
              setState(() {
                _isSubmitting = false;
              });
            });
    }
  }

  Map<String, dynamic> formateEditedData() {
    return {
      'name': _nameController.text,
      'faculty': widget.user.userRole == UserRole.Faculty ? true : false,
      'student': widget.user.userRole == UserRole.Student ? true : false,
      'lab': _labController.text,
      // 'major': _majorController.text,
      // 'Backend': widget.user.skills.backend,
      // 'Frontend': widget.user.skills.frontend,
      // 'AI&ML': widget.user.skills.aiml,
      // 'Data': widget.user.skills.data,
      // 'App': widget.user.skills.app,
      // 'Others': widget.user.skills.others,
      'updated': Timestamp.now(),
    };
  }
}