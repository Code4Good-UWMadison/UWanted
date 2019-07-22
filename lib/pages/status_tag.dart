import 'package:flutter/material.dart';

class StatusTag extends StatelessWidget {
  final Status status;

  StatusTag({@required this.status});

  StatusTag.fromString(String status) : status = getStatusFromString(status);

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

  static Status getStatusFromString(String status) {
    status = status.replaceAll(' ', '').toLowerCase();
    switch (status) {
      case 'open':
        return Status.open;
        break;
      case 'inprogress':
        return Status.inprogress;
        break;
      case 'finished':
        return Status.finished;
        break;
      default:
        return Status.undefined;
    }
  }

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
}

enum Status {
  open,
  inprogress,
  finished,
  undefined,
}
