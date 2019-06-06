import 'package:flutter/material.dart';
import '../services/authentication.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key) {
//    get user profile from server
  }
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    this.user = User("Kyle Wang", UserRole.Student, "", "Computer Science",
        [Skills.AIML, Skills.Data, Skills.App]);
    // this.user.userName = "Kyle Wang";
    // this.user.userRole = UserRole.Student;
    // this.user.lab = "";
    // this.user.major = "Computer Science";
    // this.user.skills = [Skills.AIML, Skills.Data, Skills.App];
  }

  // final BaseAuth auth;
  // final VoidCallback onSignedOut;
  // final String userId;

  User user;
  // String userName = "Kyle Wang";
  // UserRole userRole = UserRole.Student;
  // String lab = "";
  // String major = "Computer Science";
  // List<Skills> skills = [Skills.AIML, Skills.Data, Skills.App];

  @override
  Widget build(BuildContext context) {
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
        onTap: () async {
          User user = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditProfilePage(this.user)),
          );
          setState(() {
            this.user = User.copy(user);
          });
        },
      );
}

class EditProfilePage extends StatefulWidget {
  final User user;

  EditProfilePage(this.user);
  @override
  EditProfilePageState createState() {
    return EditProfilePageState();
  }
}

class EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController;
  TextEditingController roleController;
  TextEditingController labController;
  TextEditingController majorController;
  TextEditingController skillsController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.user.userName);
    roleController = TextEditingController(
        text: widget.user.userRole.toString().substring(9));
    labController = TextEditingController(text: widget.user.lab);
    majorController = TextEditingController(text: widget.user.major);
    skillsController =
        TextEditingController(text: widget.user.skills.toString());
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  TextFormField _buildForm(
      TextEditingController controller, String label, Function validator) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Name cannot be empty!';
        }
      },
    );
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      Navigator.pop(
          context,
          User(nameController.text, UserRole.Student, labController.text,
              majorController.text, [Skills.AIML, Skills.Data, Skills.App]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildForm(nameController, "Name", null),
            _buildForm(roleController, "Role", null),
            _buildForm(labController, "Lab", null),
            _buildForm(majorController, "Major", null),
            _buildForm(skillsController, "Skills", null),
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
}

class User {
  String userName;
  UserRole userRole;
  String lab;
  String major;
  List<Skills> skills;

  User(this.userName, this.userRole, this.lab, this.major, this.skills);

  User.copy(User user) {
    this.userName = user.userName;
    this.userRole = user.userRole;
    this.lab = user.lab;
    this.major = user.major;
    this.skills = user.skills;
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
