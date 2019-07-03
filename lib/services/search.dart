import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  searchByName(String searchField) {
    return Firestore.instance
        .collection('tasks')
        .where('title',
        isEqualTo: searchField)
        .snapshots();
  }
}