import 'package:cloud_firestore/cloud_firestore.dart';

class TodoModel {
  String id;
  String title;
  Timestamp time;
  bool completed;

  TodoModel({
    required this.id,
    required this.title,
    required this.time,
    required this.completed,
  });
}
