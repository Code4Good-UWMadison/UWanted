import 'package:flutter/material.dart';
import './details.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      this.id});
  final title;
  final ai;
  final app;
  final be;
  final data;
  final fe;
  final ot;
  final id;
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
    ScreenUtil.instance = ScreenUtil(width: 640, height: 1136)..init(context);
    var labels = this._getNewList();
    return Card(
        child: Container(
            padding: const EdgeInsets.only(top: 5.0),
            child: Column(
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                      fontSize: ScreenUtil.getInstance().setSp(40),
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: labels.map((label) {
                      return new Container(
                        width: ScreenUtil.getInstance().setWidth(150),
                        height: ScreenUtil.getInstance().setHeight(30),
                        child: Label(new Text(
                          label,
                          style: TextStyle(
                              fontSize: ScreenUtil.getInstance().setSp(20),
                              decoration: TextDecoration.none,
                              ),
                          textAlign: TextAlign.center,
                        )),
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
        padding: new EdgeInsets.only(left:5.0),
        child: DecoratedBox(
        decoration: new BoxDecoration(
          color: Colors.lightBlue,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child:label,
      ),
      ),
    );
  }
}

