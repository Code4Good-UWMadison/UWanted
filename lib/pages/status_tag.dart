import 'package:flutter/material.dart';

class StatusTag extends StatelessWidget {
  StatusTag({@required this.status});
  final Status status;

  Color _buildColor() {
    switch (this.status) {
      case Status.open:
        return Colors.green;
        break;
      case Status.inprogress:
        return Colors.yellow[800];
        break;
      case Status.finished:
        return Colors.red;
        break;
      default:
        return Colors.lightBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: new BoxDecoration(
        color: _buildColor(),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Container(
        child: Text(
          this.status.toString().substring(7),
          style: TextStyle(color: Colors.white),
        ),
        padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
      ),
    );
  }
}

enum Status {
  open,
  finished,
  inprogress,
}
