import 'package:flutter/material.dart';
import 'package:thewanted/services/authentication.dart';
import './details.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewanted/pages/status_tag.dart';

class Task extends StatelessWidget {
  // Task({@required this.title, this.description});
  Task({
    @required this.title,
    this.ai,
    this.app,
    this.be,
    this.data,
    this.fe,
    this.ot,
    this.id,
    this.request,
    this.remain,
    this.already,
    @required this.status,
    @required this.userId,
    @required this.auth,
  });
  final title;
  final ai;
  final app;
  final be;
  final data;
  final fe;
  final ot;
  final id;
  final request;
  final remain;
  final already;
  final String status;
  final String userId;
  final BaseAuth auth;
  List _getNewList() {
    List<String> list = new List();
    if (ai) {
      list.add('AI&ML');
    }
    if (app) {
      list.add('App');
    }
    if (be) {
      list.add('Backend');
    }
    if (data) {
      list.add('Data');
    }
    if (fe) {
      list.add('Frontend');
    }
    if (ot) {
      list.add('Other');
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    // ScreenUtil.instance = ScreenUtil(width: 640, height: 1136)..init(context);
    var labels = this._getNewList();
    return Card(
        child: Container(
            padding: const EdgeInsets.only(top: 5.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    StatusTag.fromString(this.status),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: labels.map((label) {
                      return new Container(
                        child: Flexible(
                          child: Container(
                            padding:
                                const EdgeInsets.only(left: 3.0, right: 3.0),
                            width: 140,
                            height: 30,
                            child: Label(new Text(
                              label,
                              style: TextStyle(
                                fontSize: 20,
                                decoration: TextDecoration.none,
                              ),
                              textAlign: TextAlign.center,
                            )),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10, top: 10),
                      child: Text(
                          "Minimum Rating Required: " +
                              this.request.toString(),
                          style: Theme.of(context).textTheme.body2),
                    ),
                    //SizedBox(height: 5.0),
                    Padding(
                      padding: EdgeInsets.only(left: 10, top: 10),
                      child: Text(
                          "Applicants Capacity: " +
                              ((this.remain != -1)
                                  ?  this.already.toString() +
                                      " / " +
                                      this.remain.toString()
                                  : "No limit"),
                          style: Theme.of(context).textTheme.body2),
                    ),
                  ],
                ),
                FlatButton(
                    child: Text("See More"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailedPage(
                                    title: title,
                                    id: id,
                                    currUserId: userId,
                                    auth: auth,
                                    withdrawlButton: false,
                                  )));
                    }),
              ],
            )));
  }
}

class Label extends StatelessWidget {
  final Text label;
  const Label(this.label);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: new EdgeInsets.only(left: 5.0),
        child: DecoratedBox(
          decoration: new BoxDecoration(
            color: Colors.lightBlue,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          child: label,
        ),
      ),
    );
  }
}
