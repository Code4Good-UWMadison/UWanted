import 'package:flutter/material.dart';

// void main() =>runApp(MyApp());

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Send Request',
        home: new Request(),
        theme: new ThemeData(primarySwatch: Colors.brown) //themeData
        ); //Material app
  }
}

class Request extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TopPart(),
          BottomPart(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //submit and go to another page
        },
        backgroundColor: Colors.brown,
        child: Text(
          "Submit",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

Color textColor = Color(0xFFDBC1AC);

class TopPart extends StatefulWidget {
  @override
  _TopPartState createState() => _TopPartState();
}

class _TopPartState extends State<TopPart> {
  @override
  Widget build(BuildContext context) {
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
                      controller: TextEditingController(),
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
                        controller: TextEditingController(),
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
                controller: TextEditingController(),
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
