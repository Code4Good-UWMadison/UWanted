import 'package:flutter/material.dart';
import './details.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thewanted/pages/status_tag.dart';

class Task extends StatelessWidget {
  // Task({@required this.title, this.description});
  Task(
      {@required this.title,
      this.ai,
      this.app,
      this.be,
      this.data,
      this.fe,
      this.ot,
      this.id,
      @required this.status});
  final title;
  final ai;
  final app;
  final be;
  final data;
  final fe;
  final ot;
  final id;
  final String status;
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
                FlatButton(
                    child: Text("See More"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailedPage(
                                    title: title,
                                    id: id,
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
