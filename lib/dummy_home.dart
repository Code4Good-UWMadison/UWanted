import 'package:flutter/material.dart';
import './pages/card.dart';


class HomePage extends StatefulWidget {
  HomePage({Key key})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  _newTask() async {}

  final List<String> entries = <String>['A', 'B', 'C'];
  final List<int> colorCodes = <int>[600, 500, 100];
  Widget _showTodoList() {
    return Text("loaded");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Dashboard'),
      ),
      body: _showTodoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _newTask, // generate a new task
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }
}
