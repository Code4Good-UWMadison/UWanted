
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//import 'package:firebase_database/firebase_database.dart';
class Request {

  String userName;
  String contact;
  String description;

  bool backend;
  bool frontend;
  bool aiml;
  bool data;
  bool app;
  bool others;

  Request(
      {
        //this.userName,
        this.contact,
        this.description,
        this.aiml,
        this.app,
        this.backend,
        this.data,
        this.frontend,
        this.others,
        });


}


class DetailedPage extends StatefulWidget {

  DetailedPage({@required this.title, @required this.id});
  final title;
  final id;
  // void _getRequestData() async {
  //var requestInfo = await Firestore.instance.collection('tasks').document(id).get();
  //   request = Request.fromSnapshot(requestInfo);
  // }
  @override
  _DetailedPageState createState() => _DetailedPageState();
  //final description;

}

class _DetailedPageState extends State<DetailedPage>{
  Request request;
  @override
  void initState() {
    super.initState();
    _getRequest();
  }
  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ));
  }

  void _getRequest() {

    Request req;
    Firestore.instance.collection('tasks').document(
        'L5xMayjnkh3kZxy75dpn').get().then((DocumentSnapshot document) {
      if (document.data == null) {
        print('failed');
      }
      else{
        req = new Request(
            contact: document.data['contact'],
            description: document.data['description'],
            aiml: document.data['AI&ML'],
            backend: document.data['Backend'],
            frontend: document.data['Frontend'],
            data: document.data['Data'],
            app: document.data['App'],
            others: document.data['Other']);

        setState(() {
          this.request = req;
        });
        print(document.data);
        print(req.description);
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    if (this.request == null)
      return Center(
        child: Text("loading"),
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
          margin: EdgeInsets.only(top: 10, left: 10, bottom: 15),
          decoration: myBoxDecoration(),
          padding: new EdgeInsets.all(10),
          width: 300,
          height: 45,
          child: Text(
           widget.title,
            style: TextStyle(fontSize: 20),
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
            decoration: myBoxDecoration(),
            padding: new EdgeInsets.all(10),
            width: 280,
            height: 150,
            child: SingleChildScrollView(
              child: Text(
                this.request.description,
                style: TextStyle(fontSize: 20),
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
          decoration: myBoxDecoration(),
          padding: new EdgeInsets.all(10),
          width: 260,
          height: 45,
          child: Text(
            this.request.contact,
            style: TextStyle(fontSize: 20),
          ),
        )
      ],
    );

    return Scaffold(
        appBar: AppBar(
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              request,
              details,
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: labels,
              ),
              contactInfo,
            ],
          ),
        ));
  }



}


class LabelWidget extends StatefulWidget {
  Text label;
 bool selected;
  LabelWidget(Text label, bool selected){
    this.label = label;
    this.selected = selected;
  }
  @override
  _LabelWidgetState createState() => _LabelWidgetState();
}

class _LabelWidgetState extends State<LabelWidget> {
  Color myColor = Colors.grey;
  @override
  void initState(){
    super.initState();
  }
  _getColor(){
    if(widget.selected){
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
