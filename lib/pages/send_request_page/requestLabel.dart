import 'package:flutter/material.dart';
import 'send_request_refactored.dart';
import '../details.dart';

class RequestLabel extends StatefulWidget {
  final Text label;
  bool selectState;
  Request request;

  RequestLabel(this.label, this.selectState, this.request);

  @override
  _RequestLabelState createState() => _RequestLabelState();
}

class _RequestLabelState extends State<RequestLabel> {
  //_LabelWidgetState();
  Color myColor = Colors.grey;
  bool selected = false;
  Color selectedColor = Colors.blue;

  @override
  void initState() {
    if (widget.selectState) {
      selected = true;
      myColor = selectedColor;
    }
    super.initState();
  }

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
          if (myColor == selectedColor) {
            myColor = Colors.grey; //unselected
            selected = false;
          } else {
            myColor = selectedColor; //selected
            selected = true;
          }
        });
        _buttonValue(widget.label, selected);
      },
    );
  }

  _buttonValue(Text label, bool selected) {
    switch (label.data) {
      case 'Backend':
        widget.request.backend = selected;
        break;
      case 'Frontend':
        widget.request.frontend = selected;
        break;
      case 'AI&ML':
        widget.request.aiml = selected;
        break;
      case 'Data':
        widget.request.data = selected;
        break;
      case 'App':
        widget.request.app = selected;
        break;
      case 'Other':
        widget.request.others = selected;
        break;
    }
  }
}