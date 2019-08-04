import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thewanted/pages/status_tag.dart';
import 'package:thewanted/services/authentication.dart';
import 'package:thewanted/models/user.dart';
import 'package:thewanted/models/skills.dart';
import 'package:thewanted/pages/details_components/apply_button.dart';

class Request {
  //String userName;
  String contact;
  String description;
  String userId;
  String requestTitle;
  bool backend;
  bool frontend;
  bool aiml;
  bool data;
  bool app;
  bool others;
  final String status;

  Request({
    this.userId,
    this.contact,
    this.description,
    this.aiml,
    this.app,
    this.backend,
    this.data,
    this.frontend,
    this.others,
    this.requestTitle,
    @required this.status,
  });
}

class DetailedPage extends StatefulWidget {
  DetailedPage(
      {@required this.title,
      @required this.id,
      @required this.currUserId,
      @required this.auth,
      @required this.cancelButton});

  final title;
  final id;
  final String currUserId;
  final BaseAuth auth;
  bool cancelButton;

  @override
  _DetailedPageState createState() => _DetailedPageState();

//final description;

  static Request getReqInfoForUpdate(String id) {
    Request req;
    print("id of request: " + id);
    Firestore.instance
        .collection('tasks')
        .document(id)
        .get()
        .then((DocumentSnapshot document) {
      if (document.data == null) {
        return showDialog(
            builder: (_) => new AlertDialog(
                  content: new Text(
                    'Request does not exist.',
                    textAlign: TextAlign.center,
                  ),
                ));
      } else {
        print("request is valid, retrieving info");
        req = new Request(
          userId: document.data['userId'],
          contact: document.data['contact'],
          description: document.data['description'],
          aiml: document.data['AI&ML'],
          backend: document.data['Backend'],
          frontend: document.data['Frontend'],
          data: document.data['Data'],
          app: document.data['App'],
          others: document.data['Other'],
          status: document['status'],
          requestTitle: document.data['title'],
        );
        return req;
      }
    });
  }
}

class _DetailedPageState extends State<DetailedPage> {
  Request request;

  @override
  void initState() {
    super.initState();
    _getRequest(widget.id);
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ));
  }

  void _getRequest(String id) {
    Request req;
    Firestore.instance
        .collection('tasks')
        .document(id)
        .get()
        .then((DocumentSnapshot document) {
      if (document.data == null) {
        return showDialog(
            context: context,
            builder: (_) => new AlertDialog(
                  content: new Text(
                    'Request does not exist.',
                    textAlign: TextAlign.center,
                  ),
                ));
      } else {
        req = new Request(
          userId: document.data['userId'],
          contact: document.data['contact'],
          description: document.data['description'],
          aiml: document.data['AI&ML'],
          backend: document.data['Backend'],
          frontend: document.data['Frontend'],
          data: document.data['Data'],
          app: document.data['App'],
          others: document.data['Other'],
          status: document['status'],
          requestTitle: widget.title,
        );

        setState(() {
          this.request = req;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (this.request == null)
      return Center(
        child: CircularProgressIndicator(),
      );

    var request = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10, top: 10),
          child: Text('Request',
              style: new TextStyle(
                fontSize: 20.0,
              )),
        ),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 10, left: 10, bottom: 15),
          //decoration: myBoxDecoration(),
          padding: new EdgeInsets.all(10),
          width: 300,
          height: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                widget.title,
                style: TextStyle(
                    decoration: TextDecoration.underline, fontSize: 20),
              ),
              StatusTag.fromString(this.request.status),
            ],
          ),
        )
      ],
    );

    var details = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text('Details',
              style: new TextStyle(
                fontSize: 20.0,
              )),
        ),
        Container(
            margin: EdgeInsets.only(top: 10, left: 10),
            padding: new EdgeInsets.all(10),
            width: 280,
            height: 150,
            child: SingleChildScrollView(
              child: Text(
                this.request.description,
                style: TextStyle(
                    decoration: TextDecoration.underline, fontSize: 20),
              ),
            )),
      ],
    );

    var labels = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10, bottom: 10),
                  child: Text('Labels',
                      style: new TextStyle(
                        fontSize: 20.0,
                      )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    new SizedBox(
                      width: 90,
                      height: 30,
                      child: LabelWidget(Text('Backend'), this.request.backend),
                    ),
                    new SizedBox(
                      width: 90,
                      height: 30,
                      child:
                          LabelWidget(Text('Frontend'), this.request.frontend),
                    ),
                    new SizedBox(
                      width: 90,
                      height: 30,
                      child: LabelWidget(Text('AI&ML'), this.request.aiml),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new SizedBox(
                        width: 90,
                        height: 30,
                        child: LabelWidget(Text('Data'), this.request.data),
                      ),
                      new SizedBox(
                        width: 90,
                        height: 30,
                        child: LabelWidget(Text('App'), this.request.app),
                      ),
                      new SizedBox(
                        width: 90,
                        height: 30,
                        child: LabelWidget(Text('Other'), this.request.others),
                      ),
                    ],
                  ),
                )
              ]),
        )
      ],
    );

    var contactInfo = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10, bottom: 10),
          child: Text('Contact Info',
              style: new TextStyle(
                fontSize: 20.0,
              )),
        ),
        Container(
          margin: EdgeInsets.only(left: 10, bottom: 15),
          //decoration: myBoxDecoration(),
          alignment: Alignment.center,
          padding: new EdgeInsets.all(10),
          width: 260,
          height: 45,
          child: Text(
            this.request.contact,
            style:
                TextStyle(decoration: TextDecoration.underline, fontSize: 20),
          ),
        ),
        FlatButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        userProfileInfoPage(this.request.userId)));
          },
          child: Text(
            "See User Profile",
            style: TextStyle(color: Colors.black),
          ),
        )
      ],
    );

    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
        appBar: AppBar(),
        body: Center(
          child: ListView(
            children: <Widget>[
              request,
              details,
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: labels,
              ),
              contactInfo,
<<<<<<< HEAD
              widget.cancelButton
                  ? _buildCancelButton()
                  : ApplyButton(
                      taskId: widget.id,
                      status: this.request.status,
                      context: context)
=======
              ApplyButton(
                  taskId: widget.id,
                  status: this.request.status,
                  context: context,
                  parentKey: _scaffoldKey),
>>>>>>> 278d22b4ea8b0131cd6e0b1244cec9d41ff6d425
            ],
          ),
        ));
  }

  _buildCancelButton() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: RaisedButton(
          color: Colors.red,
          onPressed: () {
            _deleteAppliedTask();
          },
          child: Text("Cancel Application"),
        ),
      );

  _deleteAppliedTask() async {
    List list;
    await Firestore.instance
        .collection("users")
        .document(widget.currUserId)
        .get()
        .then((DocumentSnapshot doc) {
      list = List<String>.from(doc['applied'], growable: true);
      list.remove(widget.id);
      //appliedList.removeWhere((item) => item == widget.id);
    });
    await Firestore.instance
        .collection("tasks")
        .document(widget.id)
        .collection('applicants')
        .document(widget.currUserId)
        .delete();
    await Firestore.instance
        .collection('users')
        .document(widget.currUserId)
        .updateData({
      "applied": list
      //FieldValue.arrayRemove(new List)
    });

  }
}

class userProfileInfoPage extends StatefulWidget {
  User user;
  final String userIdNum;

  userProfileInfoPage(this.userIdNum);

  @override
  _userProfileInfoPageState createState() => _userProfileInfoPageState();
}

class _userProfileInfoPageState extends State<userProfileInfoPage> {
  @override
  void initState() {
    Firestore.instance
        .collection('users')
        .document(widget.userIdNum)
        .get()
        .then((DocumentSnapshot document) {
      if (document.data == null) {
        //TODO: add warning message
        print("null found");
        print("userid is " + widget.userIdNum);
      } else {
        var u = User(
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
            ));
        setState(() {
          widget.user = u;
        });
      }
    });
    super.initState();
  }

  ListTile _buildListTile(String title, String trailing) => ListTile(
        title: Text(title),
        trailing: Text(trailing),
      );

  @override
  Widget build(BuildContext context) {
    if (widget.user != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("User Profile"),
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              _buildListTile("Name", widget.user.userName),
              _buildListTile("Role", widget.user.userRoleToString()),
              _buildListTile("Lab", widget.user.lab),
              _buildListTile("Major", widget.user.major),
              _buildListTile("Technical Skills", widget.user.skills.toString()),
            ],
          ).toList(),
        ),
      );
    } else
      return new Center(
        child: CircularProgressIndicator(),
      );
  }
}

class LabelWidget extends StatefulWidget {
  Text label;
  bool selected;

  LabelWidget(Text label, bool selected) {
    this.label = label;
    this.selected = selected;
  }

  @override
  _LabelWidgetState createState() => _LabelWidgetState();
}

class _LabelWidgetState extends State<LabelWidget> {
  Color myColor = Colors.grey;

  @override
  void initState() {
    super.initState();
  }

  _getColor() {
    if (widget.selected) {
      myColor = Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    _getColor();
    print(myColor);
    return RaisedButton(
      disabledColor: myColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: widget.label,
    );
  }
}
