import 'package:flutter/material.dart';
import './services/authentication.dart';
import './pages/root_page.dart';

// import './pages/send_request.dart';

// import './dummy_home.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'UWanted',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new RootPage(auth: new Auth()));
        // home: new App());
  }
}
