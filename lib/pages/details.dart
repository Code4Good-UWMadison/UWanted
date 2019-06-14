import 'package:flutter/material.dart';
//mport 'package:firebase_database/firebase_database.dart';

class DetailedPage extends StatelessWidget {
  DetailedPage({@required this.title, @required this.id});
  final title;
  
  //final description;
  BoxDecoration myBoxDecoration(){
    return BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        )
    );
  }
  final id;

  @override
  Widget build(BuildContext context) {
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
            'Request description....',
            style:
            TextStyle(fontSize: 20),
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
            child:
            SingleChildScrollView(
              child:
              Text(
                'We need someone to help us to build ' +
                    'a database for our lab’s website. ' +
                    'Any database type is fine. It doesn’t' +
                    ' need to be complicated as we only' +
                        ' need to store subjects’ registration' +
                        ' information.',
                style: TextStyle(

                    fontSize: 20
                ),
              ),
            )

        ),





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
                      child: LabelWidget(Text('Backend')),
                    ),
                    new SizedBox(
                      width: 90,
                      height: 30,
                      child: LabelWidget(Text('Frontend')),
                    ),
                    new SizedBox(
                      width: 90,
                      height: 30,
                      child: LabelWidget(Text('AI&ML')),
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
                        child: LabelWidget(Text('Data')),
                      ),
                      new SizedBox(
                        width: 90,
                        height: 30,
                        child: LabelWidget(Text('App')),
                      ),
                      new SizedBox(
                        width: 90,
                        height: 30,
                        child: LabelWidget(Text('Other')),
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
            'xxxxxx@wisc.edu',
            style:
            TextStyle(fontSize: 20),
          ),
        )
      ],
    );

    return Scaffold(
        appBar: AppBar(
          title: Text(title),
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
  final Text label;
  const LabelWidget(this.label);
  @override
  _LabelWidgetState createState() => _LabelWidgetState();
}

class _LabelWidgetState extends State<LabelWidget> {
  _LabelWidgetState();
  Color myColor = Colors.grey;
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
          if (myColor == Colors.grey) {
            myColor = Colors.redAccent;
          } else {
            myColor = Colors.grey;
          }
        });
      },
    );
  }
}
