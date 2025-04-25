import 'package:hive/hive.dart';

part 'todo_model.g.dart'; // auto-generated file

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isDone;

  @HiveField(2)
  DateTime? deadline; // 🆕 field baru

  Todo({required this.title, this.isDone = false, this.deadline});
}
