import 'package:flutter/material.dart';
import 'package:thewanted/pages/components/details.dart';
import 'package:flutter/services.dart';

class Filter extends StatefulWidget {
  Filter({@required this.myRequest, @required this.maxAppController});

  final Request myRequest;
  final TextEditingController maxAppController;

  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          "Filter:",
          style: TextStyle(fontSize: 18.0),
        ),
        SizedBox(height: 10),
        Text(
          "Applicants should have rating at least",
          style: TextStyle(fontSize: 15.0),
        ),
        DropdownButton<double>(
          value: widget.myRequest.leastRating,
          onChanged: (double newValue) {
            setState(() {
              widget.myRequest.leastRating = newValue;
            });
          },
          items: <double>[0, 1, 2, 3, 4, 5]
              .map<DropdownMenuItem<double>>((double value) {
            return DropdownMenuItem<double>(
              value: value,
              child: Text(value.toString()),
            );
          }).toList(),
        ),
        Text('Maximum applicants'),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ),
            child: TextField(
              keyboardType: TextInputType.number,
              controller: widget.maxAppController,
              decoration: new InputDecoration(
                hintText: 'Enter a number, e.g. 7, ',
                helperText:
                    'Keep this empty or negative if you don\'t want this limit.',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
              ),
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly
              ],
            ),
          ),
        ),
      ],
    );
  }
}
