import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationDetail extends StatefulWidget {
  ApplicationDetail({@required this.taskId, @required this.applicantId});

  final String taskId;
  final String applicantId;

  @override
  _ApplicationDetailState createState() => _ApplicationDetailState();
}

class _ApplicationDetailState extends State<ApplicationDetail> {
  bool _acceptPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('data'),
      ),
      body: _buildApplicationDetail(),
    );
  }

  FutureBuilder<DocumentSnapshot> _buildApplicationDetail() =>
      FutureBuilder<DocumentSnapshot>(
        future: Firestore.instance
            .collection('tasks')
            .document(widget.taskId)
            .collection('applicants')
            .document(widget.applicantId)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              return ListView(
                children: <Widget>[
                  ListTile(
                    title: Text('Application Message'),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                    child: Text(snapshot.data['msg']),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                      onPressed: this._acceptPressed
                          ? null
                          : _buildOnpressed(snapshot.data['accepted']),
                      child: _buildText(snapshot.data['accepted']),
                    ),
                  ),
                ],
              );
          }
        },
      );

  VoidCallback _buildOnpressed(bool accepted) => () {
        Firestore.instance
            .collection('tasks')
            .document(widget.taskId)
            .collection('applicants')
            .document(widget.applicantId)
            .updateData({'accepted': !accepted}).then(
                _changeTaskStatusFromAccepteds);
      };

  _changeTaskStatusFromAccepteds(_) {
    Firestore.instance
        .collection('tasks')
        .document(widget.taskId)
        .collection('applicants')
        .where('accepted', isEqualTo: true)
        .getDocuments()
        .then((QuerySnapshot query) {
      Firestore.instance.collection('tasks').document(widget.taskId).updateData(
          {'status': query.documents.isNotEmpty ? 'inprogress' : 'open'});
    });
  }

  Text _buildText(bool accepted) => Text(accepted ? 'Accepted' : 'Accept');
}
