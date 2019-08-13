import 'package:flutter/material.dart';
import '../../services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../details.dart';
import 'requestLabel.dart';

class RequestForm extends StatefulWidget {
  RequestForm(
      {Key key,
      this.auth,
      this.userId,
      this.needUpdate,
      this.postId,
      this.goToDashBoard})
      : super(key: key);
  final BaseAuth auth;
  final String userId;
  final bool
      needUpdate; //indicator of whether to update request instead of creating new one
  final String postId;
  final Function() goToDashBoard;

  @override
  State<StatefulWidget> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  Request myRequest;
  bool validRequest;
  TextEditingController _controllerRequestTitle;
  TextEditingController _controllerDetail;
  TextEditingController _controllerContact;

  @override
  void initState() {
    _initController();
    if (widget.needUpdate) {
      _getRequest(widget.postId);
    }
    if (!widget.needUpdate) {
      _initRequestFields();
    }
    super.initState();
  }

  _initController() {
    _controllerRequestTitle = TextEditingController();
    _controllerDetail = TextEditingController();
    _controllerContact = TextEditingController();
  }

  _clearController() {
    _controllerContact.clear();
    _controllerDetail.clear();
    _controllerRequestTitle.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _controllerRequestTitle.dispose();
    _controllerDetail.dispose();
    _controllerContact.dispose();
  }

  _initRequestFields() {
    myRequest = new Request(
      userId: widget.userId,
      contact: "",
      description: "",
      aiml: false,
      backend: false,
      frontend: false,
      data: false,
      app: false,
      others: false,
      status: "open",
      requestTitle: "",
    );
  }

  _addOrUpdateRequestInfo() {
    if (widget.needUpdate == true) {
      //update request info in database
      Firestore.instance
          .collection('tasks')
          .document(widget.postId)
          .updateData({
        'title': myRequest.requestTitle,
        'description': myRequest.description,
        'contact': myRequest.contact,
        'AI&ML': myRequest.aiml,
        'Backend': myRequest.backend,
        'Frontend': myRequest.frontend,
        'Data': myRequest.data,
        'App': myRequest.app,
        'Other': myRequest.others,
        'updated': DateTime.now(),
      })
            ..then((_) {
              showDialog(
                  context: context,
                  builder: (_) => new AlertDialog(
                        content: new Text(
                          'Request submitted.',
                          textAlign: TextAlign.center,
                        ),
                      ));
            })
            ..catchError((e) {
              showDialog(
                  context: context,
                  builder: (_) => new AlertDialog(
                        content: new Text(
                          'Please retry $e',
                          textAlign: TextAlign.center,
                        ),
                      ));
            });
    } else {
      //create and store new request in database
      DocumentReference docRef =
          Firestore.instance.collection('tasks').document();
      String uidOfTask = docRef.documentID;
      docRef.setData({
        'userId': widget.userId, //record id of user who posted the request
        'title': myRequest.requestTitle,
        'description': myRequest.description,
        'contact': myRequest.contact,
        'AI&ML': myRequest.aiml,
        'Backend': myRequest.backend,
        'Frontend': myRequest.frontend,
        'Data': myRequest.data,
        'App': myRequest.app,
        'Other': myRequest.others,
        'created': DateTime.now(),
        'updated': DateTime.now(),
        'status': 'open',
      }).then((foo) {
        Firestore.instance
            .collection('users')
            .document(widget.userId)
            .get()
            .then((DocumentSnapshot document) {
          List<String> updatedPosts =
              List<String>.from(document['posts'], growable: true);
          updatedPosts.addAll([uidOfTask]);
          Firestore.instance
              .collection('users')
              .document(widget.userId)
              .updateData({
            'posts': updatedPosts,
          });
        });
      }).catchError((e) {
        showDialog(
            context: context,
            builder: (_) => new AlertDialog(
                  content: new Text(
                    'Please retry $e',
                    textAlign: TextAlign.center,
                  ),
                ));
      });

//      Firestore.instance
//          .collection('users')
//          .document(widget.userId)
//          .get()
//          .then((DocumentSnapshot document) {
//        List<String> updatedPosts =
//            List<String>.from(document['posts'], growable: true);
//        updatedPosts.addAll([uidOfTask]);
//        Firestore.instance
//            .collection('users')
//            .document(widget.userId)
//            .updateData({
//          'posts': updatedPosts,
//        });
//      }).catchError((e){
//        showDialog(
//            builder: (_) => new AlertDialog(
//              content: new Text(
//                'Please retry $e',
//                textAlign: TextAlign.center,
//              ),
//            ));
//      });
    }
  }

  ///Retrieve existing request info from database
  Future<void> _getRequest(String id) async {
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
          status: document.data['status'],
          requestTitle: document.data["title"],
        );
        setState(() {
          myRequest = req;
          _controllerRequestTitle.text = myRequest.requestTitle;
          _controllerDetail.text = myRequest.description;
          _controllerContact.text = myRequest.contact;
        });
      }
    });
  }

  ///Check if the request info has been filled correctly, no empty field
  bool _validSubmission() {
    validRequest = false;
    if (myRequest.backend ||
        myRequest.aiml ||
        myRequest.frontend ||
        myRequest.others ||
        myRequest.data ||
        myRequest.app) {
      if (myRequest.requestTitle != "" &&
          myRequest.description != "" &&
          myRequest.contact != "") {
        validRequest = true;
      }
    }
    return validRequest;
  }

  @override
  Widget build(BuildContext context) {
    _controllerRequestTitle.addListener(() {
      myRequest.requestTitle = _controllerRequestTitle.text;
    });
    _controllerDetail.addListener(() {
      myRequest.description = _controllerDetail.text;
    });
    _controllerContact.addListener(() {
      myRequest.contact = _controllerContact.text;
    });
    if (myRequest == null && widget.needUpdate == true) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: widget.needUpdate
          ? AppBar(
              title: Text("Edit Post"),
            )
          : null,
      body: ListView(
        // mainAxisSize: MainAxisSize.max,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildFirstHalfRequest(),
          _buildSecondHalfRequest(),
//          SizedBox(
//            height: 50.0,
//          ),
        ],
      ),
    );
  }

  _snackBar(String msg) {
    return SnackBar(
      content: Text(msg),
    );
  }

  Stack _buildFirstHalfRequest() => Stack(
        children: <Widget>[
          Container(
            height: 450.0,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 50.0,
                ),
                Text(
                  "SEND REQUEST",
                  style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.black,
                      decoration: TextDecoration.none),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50.0),
                Text(
                  "Request Title(Short Description):",
                  style: TextStyle(
                      fontSize: 18.0,
                      //color: textColor,
                      decoration: TextDecoration.none),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.0,
                  ),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                    child: TextField(
                      maxLength: 21,
                      controller: _controllerRequestTitle,
                      decoration: new InputDecoration(
                        hintText: widget.needUpdate ? null : 'Type description',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 13.0),
                      ),
                    ), //TextField
                  ), //Material
                ), //padding
                SizedBox(height: 30.0),
                Text(
                  "Details:",
                  style: TextStyle(
                      fontSize: 18.0,
                      //color: textColor,
                      decoration: TextDecoration.none),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 20.0),
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  height: 100,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.0,
                    ),
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        controller: _controllerDetail,
                        decoration: new InputDecoration(
                          labelText: "Enter Request Detail",
                          hintText:
                              'Be specific as much as possible, including techinical details and the purpose',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 15.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      );

  Column _buildSecondHalfRequest() => Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Labels:",
              style: TextStyle(fontSize: 18.0, decoration: TextDecoration.none),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new SizedBox(
                  width: 90,
                  height: 30,
                  child: RequestLabel(
                      Text(
                        'Backend',
                        style: TextStyle(color: Colors.white),
                      ),
                      widget.needUpdate ? myRequest.backend : false,
                      myRequest),
                ),
                new SizedBox(
                  width: 100,
                  height: 30,
                  child: RequestLabel(
                      Text(
                        'Frontend',
                        style: TextStyle(color: Colors.white),
                      ),
                      widget.needUpdate ? myRequest.frontend : false,
                      myRequest),
                ),
                new SizedBox(
                  width: 90,
                  height: 30,
                  child: RequestLabel(
                      Text(
                        'AI&ML',
                        style: TextStyle(color: Colors.white),
                      ),
                      widget.needUpdate ? myRequest.aiml : false,
                      myRequest),
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
                    child: RequestLabel(
                        Text(
                          'Data',
                          style: TextStyle(color: Colors.white),
                        ),
                        widget.needUpdate ? myRequest.data : false,
                        myRequest),
                  ),
                  new SizedBox(
                    width: 100,
                    height: 30,
                    child: RequestLabel(
                        Text(
                          'App',
                          style: TextStyle(color: Colors.white),
                        ),
                        widget.needUpdate ? myRequest.app : false,
                        myRequest),
                  ),
                  new SizedBox(
                    width: 90,
                    height: 30,
                    child: RequestLabel(
                        Text(
                          'Other',
                          style: TextStyle(color: Colors.white),
                        ),
                        widget.needUpdate ? myRequest.others : false,
                        myRequest),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.0),
            Text(
              "Contact Info:",
              style: TextStyle(
                  fontSize: 18.0,
                  //color: textColor,
                  decoration: TextDecoration.none),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 32.0,
              ),
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.all(
                  Radius.circular(30.0),
                ),
                child: TextField(
                  controller: _controllerContact,
                  decoration: new InputDecoration(
                    hintText: 'Email will be preferred',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
                  ),
                ), //TextField
              ), //Material
            ),
            SizedBox(height: 25.0), //padding
            MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              elevation: 5,
              //minWidth: 30,
              color: Colors.blue,
              textColor: Colors.white,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              // padding: EdgeInsets.all(8.0),
              splashColor: Colors.blueAccent,
              onPressed: () {
                if (_validSubmission()) {
                  _addOrUpdateRequestInfo();
                  _initRequestFields();
                  if (widget.needUpdate) {
                    Navigator.of(context).pop();
                  } else {
                    Scaffold.of(context).showSnackBar(
                        _snackBar("Request submitted successfully."));
                    _clearController();
                    widget.goToDashBoard();
                  }
                } else {
                  showDialog(
                      context: context,
                      builder: (_) => new AlertDialog(
                            content: new Text(
                              'Request is incomplete. \nPlease finish all fields before submitting.',
                              textAlign: TextAlign.center,
                            ),
                          ));
                }
              },
              child: Text(
                "Submit",
              ),
            ),
          ]);
}
