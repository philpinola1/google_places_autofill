import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';

class TaskDetails {
  // late String id = const Uuid().v4();
  String id;
  String? title;
  String? location;
  TimeOfDay? time;
  bool anyTime;

  TaskDetails(this.id, this.title, this.location, this.time, this.anyTime);
}
