import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'details.dart';

class UpdateRequestPage extends StatefulWidget {
  final title;
  final id; //post id
  UpdateRequestPage({@required this.title, @required this.id});

  @override
  _UpdateRequestPageState createState() => _UpdateRequestPageState();
}

class _UpdateRequestPageState extends State<UpdateRequestPage> {
  Request request;
  TextEditingController _controllerDes;
  TextEditingController _controllerDetail;
  TextEditingController _controllerLabel;
  TextEditingController _controllerContact;

  @override
  void initState() {
    super.initState();
    _controllerDes = TextEditingController();
    _controllerDetail = TextEditingController();
    _controllerLabel = TextEditingController();
    _controllerContact = TextEditingController();
    _getRequest(widget.id);
  }

  @override
  void dispose() {
    super.dispose();
    _controllerDes.dispose();
    _controllerDetail.dispose();
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
            others: document.data['Other']);

        setState(() {
          this.request = req;
        });
      }
    });
  }
  Color textColor = Color(0xFF39220F);
  @override
  Widget build(BuildContext context) {
    // des = _controllerDes.text;
    // details = _controllerDetail.text;
    return Stack(
      children: <Widget>[
        //clipper: CustomShapeClipper(),
        Container(
          height: 500.0,
          decoration: BoxDecoration(color: Colors.brown),
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
                    color: Colors.white,
                    decoration: TextDecoration.none),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50.0),
              // FloatingActionButton(
              //   onPressed: () {_controllerDes.text = "";}),
              Text(
                "Short Description:",
                style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
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
                    onChanged: (text) {
                      des = text;
                    },
                    controller: _controllerDes,
                    decoration: new InputDecoration(
                      hintText: 'Type description',
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
                    color: textColor,
                    decoration: TextDecoration.none),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 20.0),
              Container(
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
                      onChanged: (text) {
                        details = text;
                      },
                      controller: _controllerDetail,
                      decoration: new InputDecoration(
                        hintText:
                            'Be specific as much as possible, including techinical details and the purpose',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 13.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              Text(
                "Labels:",
                style: TextStyle(
                    fontSize: 18.0,
                    color: textColor,
                    decoration: TextDecoration.none),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new SizedBox(
                    width: 90,
                    height: 30,
                    child: LabelWidget(Text(
                      'Backend',
                      style: TextStyle(color: Colors.white),
                    )),
                  ),
                  new SizedBox(
                    width: 100,
                    height: 30,
                    child: LabelWidget(Text(
                      'Frontend',
                      style: TextStyle(color: Colors.white),
                    )),
                  ),
                  new SizedBox(
                    width: 90,
                    height: 30,
                    child: LabelWidget(Text(
                      'AI&ML',
                      style: TextStyle(color: Colors.white),
                    )),
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
                      child: LabelWidget(Text(
                        'Data',
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                    new SizedBox(
                      width: 100,
                      height: 30,
                      child: LabelWidget(Text(
                        'App',
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                    new SizedBox(
                      width: 90,
                      height: 30,
                      child: LabelWidget(Text(
                        'Other',
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30.0),
              Text(
                "Contact Info:",
                style: TextStyle(
                    fontSize: 18.0,
                    color: textColor,
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
                    onChanged: (text) {
                      contact = text;
                    },
                    controller: _controllerContact,
                    decoration: new InputDecoration(
                      hintText: 'Email will be preferred',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 13.0),
                    ),
                  ), //TextField
                ), //Material
              ), //padding
            ]),
      ],
    );
  }
}
