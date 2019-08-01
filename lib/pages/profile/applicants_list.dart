import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thewanted/pages/profile/application_detail.dart';

class ApplicantsList extends StatefulWidget {
  ApplicantsList({@required this.taskId});

  final String taskId;

  @override
  _ApplicantsListState createState() => _ApplicantsListState();
}

class _ApplicantsListState extends State<ApplicantsList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Applicants List'),
      ),
      body: _buildApplicantsList(),
    );
  }

  StreamBuilder<QuerySnapshot> _buildApplicantsList() =>
      StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('tasks')
            .document(widget.taskId)
            .collection('applicants')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              return ListView(
                children: snapshot.data.documents
                    .map(_buildListTileFromDocument)
                    .toList(),
              );
          }
        },
      );

  ListTile _buildListTileFromDocument(DocumentSnapshot document) => ListTile(
        leading: (document['accepted'] as bool)
            ? Icon(Icons.check_box)
            : Icon(Icons.check_box_outline_blank),
        title: _buildTitleFromUsername(document.documentID),
        trailing: Icon(Icons.arrow_forward),
        onTap: _navigateToApplicationDetail(document.documentID),
      );

  FutureBuilder<DocumentSnapshot> _buildTitleFromUsername(String uid) =>
      FutureBuilder<DocumentSnapshot>(
        future: Firestore.instance.collection('users').document(uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              return Text(snapshot.data['name']);
          }
        },
      );

  VoidCallback _navigateToApplicationDetail(String applicantId) => () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ApplicationDetail(
              taskId: widget.taskId,
              applicantId: applicantId,
            ),
          ),
        );
      };
}
