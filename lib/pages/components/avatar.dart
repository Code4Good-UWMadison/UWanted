import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class Avatar extends StatefulWidget {
  Avatar({@required this.userId, this.radius, this.image});

  final String userId;
  final double radius;
  final File image;

  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          Firestore.instance.collection('users').document(widget.userId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (widget.image != null) return _buildAvaterFromFile();
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return snapshot.data['avatarUrl'] != null
                ? _buildAvatarFromUrl(snapshot)
                : _buildAvatarFromInitial(snapshot);
        }
      },
    );
  }

  CircleAvatar _buildAvatarFromInitial(
      AsyncSnapshot<DocumentSnapshot> snapshot) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: Colors.brown.shade800,
      child: Text(
        _buildInitialFromName(snapshot.data['name']),
        style: widget.radius != null
            ? TextStyle(fontSize: 14 * widget.radius / 20)
            : null,
      ),
    );
  }

  CircleAvatar _buildAvatarFromUrl(AsyncSnapshot<DocumentSnapshot> snapshot) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundImage: NetworkImage(snapshot.data['avatarUrl']),
    );
  }

  CircleAvatar _buildAvaterFromFile() {
    return CircleAvatar(
      radius: widget.radius,
      backgroundImage: FileImage(widget.image),
    );
  }

  String _buildInitialFromName(String name) => name.isNotEmpty
      ? name
          .split(' ')
          .map((String part) => part.substring(0, 1).toUpperCase())
          .join()
      : '';
}
