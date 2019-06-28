import 'package:flutter/material.dart';
import '../services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// void main() =>runApp(MyApp());

// class App extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         title: 'Send Request',
//         home: new Request(),
//         // theme: new ThemeData(primarySwatch: Colors.brown) //themeData
//         ); //Material app
//   }
// }


String des="";
String details="";
String label="";
String contact="";


class SendRequest extends StatelessWidget {
  SendRequest({Key key, this.auth, this.userId}) : super(key: key);
  final BaseAuth auth;
  final String userId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        // mainAxisSize: MainAxisSize.max,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TopPart(),
          BottomPart(),
          SizedBox(
            height: 50.0,
          ),
          FloatingActionButton(
            onPressed: () {
              print(userId);
              _addItem(des,details,label,contact);
              //Navigator.of(context).pop();
            },
            backgroundColor: Colors.brown,
            child: Text(
              "Submit",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  _addItem(String des, String details, String label, String contact) {
    Firestore.instance
        .collection('task').document(userId).setData({
    'title' : des,
    'description' : details,
      'contact' : contact,


    });

    // .add({'description': des, 'details': details, 'label': label, 'contact':contact});
  }
}

Color textColor = Color(0xFFDBC1AC);

class TopPart extends StatefulWidget {
  @override
  _TopPartState createState() => _TopPartState();
}

class _TopPartState extends State<TopPart> {
  TextEditingController _controllerDes;
  TextEditingController _controllerDetail;

  @override
  void initState() {
    super.initState();
    _controllerDes=TextEditingController();
    _controllerDetail = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _controllerDes.dispose();
    _controllerDetail.dispose();
  }

  @override
  Widget build(BuildContext context) {
    des=_controllerDes.text;
    details=_controllerDetail.text;
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: CustomShapeClipper(),
          child: Container(
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
                Text(
                  "Short Description:",
                  style: TextStyle(
                      fontSize: 18.0,
                      color: textColor,
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
                        controller:_controllerDetail,
                        decoration: new InputDecoration(
                          hintText:
                          'Be specific as much as possible, including techinical details and the purpose',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 13.0),
                        ),
                      ), //TextField
                    ), //Material
                  ), //padding
                ),
              ], //<Widget>
            ),
          ),
        ),
      ], //<widget>
    ); //stack
  }
}

class LabelWidget extends StatefulWidget {
  final Text label;
  const LabelWidget(this.label);
  @override
  _LabelWidgetState createState() => _LabelWidgetState();
}

class _LabelWidgetState extends State<LabelWidget> {
  _LabelWidgetState();
  Color myColor = Color(0xFF38220F);
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: widget.label,
      color: myColor,
      onPressed: () {
        label=widget.label.toString();
        /*TODO*/
        setState(() {
          if (myColor == Color(0xFF38220F)) {
            myColor = Color(0x967259);
          } else {
            myColor = Color(0xFF38220F);
          }
        });
      },
    );
  }
}

class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0.0, size.height);

    var firstEndPoint = Offset(size.width * 0.5, size.height - 30.0);
    var firstControlPoint = Offset(size.width * 0.25, size.height - 50.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 80.0);
    var secondControlPoint = Offset(size.width * 0.75, size.height - 10.0);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => true;
}

class BottomPart extends StatefulWidget {
  @override
  BottomPartState createState() {
    return new BottomPartState();
  }
}

class BottomPartState extends State<BottomPart> {
  TextEditingController _controllerLabel;
  TextEditingController _controllerContact;

  @override
  void initState() {
    super.initState();
    _controllerLabel=TextEditingController();
    _controllerContact = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _controllerLabel.dispose();
    _controllerContact.dispose();
  }

  Color textColor = Color(0xFF39220F);

  @override
  Widget build(BuildContext context) {
    return Column(
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
                controller: _controllerContact,
                decoration: new InputDecoration(
                  hintText: 'Email will be preferred',
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
                ),
              ), //TextField
            ), //Material
          ), //padding
        ]);
  }
}

