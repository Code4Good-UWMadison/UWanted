import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'status_tag.dart';
import 'package:thewanted/services/authentication.dart';
import 'package:thewanted/models/user.dart';
import 'package:thewanted/models/skills.dart';
import 'apply_button.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

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
  double leastRating;
  int maximumApplicants;
  int numberOfApplicants;

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
    @required this.leastRating,
    @required
        this.maximumApplicants, // set to negative if don't want this limit
    this.numberOfApplicants,
  });
}

class DetailedPage extends StatefulWidget {
  DetailedPage(
      {@required this.title,
      @required this.id,
      @required this.currUserId,
      @required this.auth,
      @required this.withdrawlButton});
  // userId = FirebaseAuth.instance
  //       .currentUser()
  //       .then((FirebaseUser user) => user.uid);

  // final Future<String> userId;
  final title;
  final id;
  final String currUserId;
  final BaseAuth auth;
  bool withdrawlButton;

  @override
  _DetailedPageState createState() => _DetailedPageState();

//final description;

  // static Request getReqInfoForUpdate(String id) {
  //   Request req;
  //   print("id of request: " + id);
  //   Firestore.instance
  //       .collection('tasks')
  //       .document(id)
  //       .get()
  //       .then((DocumentSnapshot document) {
  //     if (document.data == null) {
  //       return showDialog(
  //           builder: (_) => new AlertDialog(
  //                 content: new Text(
  //                   'Request does not exist.',
  //                   textAlign: TextAlign.center,
  //                 ),
  //               ));
  //     } else {
  //       print("request is valid, retrieving info");
  //       req = new Request(
  //         userId: document.data['userId'],
  //         contact: document.data['contact'],
  //         description: document.data['description'],
  //         aiml: document.data['AI&ML'],
  //         backend: document.data['Backend'],
  //         frontend: document.data['Frontend'],
  //         data: document.data['Data'],
  //         app: document.data['App'],
  //         others: document.data['Other'],
  //         status: document['status'],
  //         requestTitle: document.data['title'],
  //         leastRating: document.data['leastRating'],
  //         maximumApplicants: document.data['maximumApplicants'],
  //         numberOfApplicants:
  //       );
  //       return req;
  //     }
  //   });
  // }
}

class _DetailedPageState extends State<DetailedPage> {
  Request request;
  num numOfApplicants = 0;
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

  refresh(bool apply) {
    if (this.mounted) {
      setState(() {
        if (apply) {
          this.numOfApplicants++;
        } else {
          // withdraw
          this.numOfApplicants--;
        }
      });
    }
  }

  void _getRequest(rid) {
    print("current size get request: " + rid.toString());
    Request req;
    Firestore.instance
        .collection('tasks')
        .document(widget.id)
        .get()
        .then((DocumentSnapshot document) {
      if (document.data == null) {
        // return showDialog(
        //     context: context,
        //     builder: (_) => new AlertDialog(
        //           content: new Text(
        //             'Request does not exist.',
        //             textAlign: TextAlign.center,
        //           ),
        //         ));
        print("ERROR*********************\n");
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
          leastRating: document.data['leastRating'],
          maximumApplicants: document.data['maximumApplicants'],
          numberOfApplicants: document.data['numberOfApplicants'],
        );

        setState(() {
          this.numOfApplicants = req.numberOfApplicants;
          this.request = req;
        });
      }
    });
  }

  // Future<int> countDocuments(id) async {
  //   // var size;
  //   // QuerySnapshot querySnapshot = await Firestore.instance.collection('task').document(id).collection('applicants').getDocuments();
  //   // List<DocumentSnapshot> list = querySnapshot.documents;
  //   //print(id);
  //   int size = 0;
  //   await Firestore.instance
  //         .collection('tasks')
  //         .document(id)
  //         .collection('applicants')
  //         .getDocuments()
  //         .then((QuerySnapshot snapshot) {
  //             size = snapshot.documents.length;
  //         });
  //   //print("doc size" + size.toString());
  //   return size;
  // }

  // checkCount(id) async {
  //   int val = await countDocuments(id);
  //   return val;
  // }

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
        Container(
//          alignment: Alignment.center,
//          margin: EdgeInsets.only(top: 10, left: 10, bottom: 15),
//          //decoration: myBoxDecoration(),
//          padding: new EdgeInsets.all(10),
//          width: 300,
//          height: 45,
//          child: Wrap(
//            alignment: WrapAlignment.start,
//          crossAxisAlignment: WrapCrossAlignment.center,
//          children: <Widget>[
//            Text(
//              widget.title,
//              style: TextStyle(
//                fontSize: 20,
//                fontStyle: FontStyle.normal,
//              ),
//            ),
//            StatusTag.fromString(this.request.status),
//          ],
//          ),
            )
      ],
    );

    var details = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10, top: 10),
          child: Text('Request Details',
              style: Theme.of(context).textTheme.subtitle2),
        ),
        SizedBox(height: 10.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Material(
            shadowColor: Colors.blueAccent,
            elevation: 5.0,
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ),
            child: Container(
//            decoration: BoxDecoration(
//                border: Border.all(width: 1.0),
//                borderRadius: BorderRadius.all(Radius.circular(15))),
                margin: EdgeInsets.only(top: 10, left: 10),
                padding: new EdgeInsets.all(10),
//              width: 280,
//              height: 250,
                child: SingleChildScrollView(
                  child: Text(
                    this.request.description,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )),
          ),
        )
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
                  padding: EdgeInsets.only(left: 10, bottom: 10, top: 20),
                  child: Text('Labels',
                      style: Theme.of(context).textTheme.subtitle),
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

    final GlobalKey<ScaffoldState> _scaffoldKey =
        new GlobalKey<ScaffoldState>();

    var contactInfo = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10, bottom: 10),
          child: Text('Contact Info',
              style: Theme.of(context).textTheme.subtitle2),
        ),

        Material(
          shadowColor: Colors.blueAccent,
          elevation: 5.0,
          borderRadius: BorderRadius.all(
            Radius.circular(30.0),
          ),
          child: Container(
            //margin: EdgeInsets.only(left: 10, bottom: 15),
            //decoration: myBoxDecoration(),
            alignment: Alignment.center,
            padding: new EdgeInsets.all(10),
            width: 260,
            height: 45,
            child: Text(
              this.request.contact,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        ),

          widget.currUserId == this.request.userId
            ? Text("")
            : ApplyButton(
                taskId: widget.id,
                status: this.request.status,
                context: context,
                parentKey: _scaffoldKey,
                request: this.request,
                notifyParent: refresh,
              )
//        FlatButton(
//          onPressed: () {
//            Navigator.push(
//                context,
//                MaterialPageRoute(
//                    builder: (context) =>
//                        userProfileInfoPage(this.request.userId)));
//          },
//          child: Text(
//            "See User Profile",
//            style: TextStyle(color: Colors.black),
//          ),
//        )
      ],
    );

    var rating = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10, top: 10),
          child: Text(
              "Minimum Rating Required: " + this.request.leastRating.toString(),
              style: Theme.of(context).textTheme.bodyText1),
        ),
        SizedBox(height: 10.0),
        Padding(
          padding: EdgeInsets.only(left: 10, top: 10),
          child: Text(
              "Applicants Capacity: " +
                  ((this.request.maximumApplicants != -1)
                      ? this.numOfApplicants.toString() +
                          " / " +
                          this.request.maximumApplicants.toString()
                      : "No limit"),
              style: Theme.of(context).textTheme.bodyText1),
        ),
        SizedBox(height: 20.0),
      ],
    );

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Text(widget.title + " "),
              StatusTag.fromString(this.request.status),
            ],
          ),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              request,
              details,
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: labels,
              ),
              rating,
              contactInfo,
            ],
          ),
        ));
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
      myColor = Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    _getColor();
    print(myColor);
    return RaisedButton(
      onPressed: () {},
      color: myColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: widget.label,
    );
  }
}
