// lib/services/todo_service.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo_model.dart';
import '../services/notification_service.dart';

class TodoService {
  // Simpen sementara Todo & key-nya tiap kali dihapus
  Todo? _lastDeletedTodo;
  dynamic _lastDeletedKey;

  // Akses box (pastikan Hive.openBox('todos') di main.dart sudah dipanggil)
  Box<Todo> get todoBox => Hive.box<Todo>('todos');

  // Tambah todo baru
  Future<bool> addTodo(
    BuildContext context,
    String title,
    DateTime deadline,
  ) async {
    if (title.trim().isEmpty) return false;

    final box = todoBox;
    final newTodo = Todo(title: title, deadline: deadline);
    await box.add(newTodo);

    // Reminder jam 5 pagi
    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    final reminderTime = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
      5,
      0,
    );
    if (reminderTime.isAfter(DateTime.now())) {
      NotificationService.showReminder(id, title, reminderTime);
    }

    return true;
  }

  // Delete + simpen data untuk Undo
  Future<void> deleteTodoAtIndex(int index) async {
    final box = todoBox;
    if (index < 0 || index >= box.length) return;

    // Ambil key & value sebelum delete
    final key = box.keyAt(index);
    _lastDeletedKey = key;
    _lastDeletedTodo = box.get(key);

    await box.delete(key);
  }

  // Undo delete
  Future<void> undoDelete() async {
    if (_lastDeletedKey != null && _lastDeletedTodo != null) {
      await todoBox.put(_lastDeletedKey, _lastDeletedTodo!);

      // Reset cache
      _lastDeletedKey = null;
      _lastDeletedTodo = null;
    }
  }

  // Toggle status
  Future<void> toggleTodoStatus(Todo todo) async {
    todo.isDone = !todo.isDone;
    await todo.save();
  }

  // Update todo
  Future<void> updateTodo(
    Todo todo,
    String newTitle,
    DateTime newDeadline,
  ) async {
    if (newTitle.trim().isEmpty) return;
    todo.title = newTitle;
    todo.deadline = newDeadline;
    await todo.save();
  }

  // Filter todo
  List<Todo> getFilteredTodos(
    String searchQuery,
    String filterStatus,
  ) {
    return todoBox.values.where((todo) {
      final matchesSearch =
          todo.title.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFilter = filterStatus == 'all' ||
          (filterStatus == 'done' && todo.isDone) ||
          (filterStatus == 'undone' && !todo.isDone);
      return matchesSearch && matchesFilter;
    }).toList();
  }
}
