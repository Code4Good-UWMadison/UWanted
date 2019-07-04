import 'dart:async';
import 'package:flutter/material.dart';
import '../services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './details.dart';

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
  Widget build(BuildContext context) {
    if (this.user == null)
      return Center(
        child: CircularProgressIndicator(),
      );
    return Scaffold(
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            _buildListTile("Name", this.user.userName),
            _buildListTile("Role", this.user.userRoleToString()),
            _buildListTile("Lab", this.user.lab),
            _buildListTile("Major", this.user.major),
            _buildListTile("Technical Skills", this.user.skills.toString()),
            _buildMyPostsListTile(),
          ],
        ).toList(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
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
          .setData(_initialUserData);
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

  ListTile _buildListTile(String title, String trailing) => ListTile(
        title: Text(title),
        trailing: Text(trailing),
        onTap: _navigateToEditingPage,
      );

  _navigateToEditingPage() async {
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

  ListTile _buildMyPostsListTile() => ListTile(
        title: Text('My Posts'),
        trailing: Text(this.user.posts.length.toString()),
        onTap: () {
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
        },
      );
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
            _buildMajorForm(),
            _buildSkillsCheckboxs(),
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
    _majorController.dispose();
  }

  _buildNameForm() => _buildForm(
      _nameController, "Name", 'Name cannot be empty', _nameValidator);

  _buildLabForm() =>
      _buildForm(_labController, "Lab", 'Lab can be empty', null);

  _buildMajorForm() => _buildForm(
      _majorController, "Major", 'Major cannot be empty', _majorValidator);

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

  String _majorValidator(String value) {
    if (value.isEmpty) return 'Major cannot be empty!';
    return null;
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
                      major: _majorController.text,
                      skills: widget.user.skills,
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
      'major': _majorController.text,
      'Backend': widget.user.skills.backend,
      'Frontend': widget.user.skills.frontend,
      'AI&ML': widget.user.skills.aiml,
      'Data': widget.user.skills.data,
      'App': widget.user.skills.app,
      'Others': widget.user.skills.others,
      'updated': Timestamp.now(),
    };
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

var _initialUserData = {
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

  Skills.clone(Skills skills)
      : this(
          backend: skills.backend,
          frontend: skills.frontend,
          aiml: skills.aiml,
          data: skills.data,
          app: skills.app,
          others: skills.others,
        );

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

class MyPostsPage extends StatefulWidget {
  MyPostsPage({Key key, this.auth, this.userId, this.posts}) : super(key: key);

  final BaseAuth auth;
  final String userId;
  final List<String> posts;

  @override
  _MyPostsPageState createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  Map<String, String> posts = Map<String, String>();

  @override
  void initState() {
    super.initState();
    _getPostsFromRemote();
  }

  @override
  Widget build(BuildContext context) {
    if (this.posts == null)
      return Center(
        child: CircularProgressIndicator(),
      );
    return Scaffold(
      appBar: AppBar(
        title: Text("My Posts"),
      ),
      body: ListView(
        children: this.posts.entries.map(_buildListTileFromPosts).toList(),
      ),
    );
  }

  void _getPostsFromRemote() {
    widget.posts.forEach((String uid) {
      Firestore.instance
          .collection('tasks')
          .document(uid)
          .get()
          .then((DocumentSnapshot document) {
        setState(() {
          this.posts[uid] = document['title'];
        });
      });
    });
  }

  ListTile _buildListTileFromPosts(MapEntry<String, String> entry) {
    return ListTile(
      title: Text(entry.value),
      trailing: Icon(Icons.arrow_forward),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailedPage(
                  title: entry.value,
                  id: entry.key,
                ),
          ),
        );
      },
    );
  }
}
