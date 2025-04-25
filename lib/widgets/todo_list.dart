// lib/widgets/todo_list.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo_model.dart';
import '../services/todo_service.dart';
import 'todo_item.dart';

class TodoList extends StatelessWidget {
  final String searchQuery;
  final String filterStatus;
  final TodoService todoService;

  const TodoList({
    Key? key,
    required this.searchQuery,
    required this.filterStatus,
    required this.todoService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: todoService.todoBox.listenable(),
      builder: (context, Box<Todo> box, _) {
        if (box.isEmpty) {
          return _buildEmptyState();
        }

        final filteredList =
            todoService.getFilteredTodos(searchQuery, filterStatus);

        if (filteredList.isEmpty) {
          return _buildNoMatchState();
        }

        return ListView.builder(
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final todo = filteredList[index];
            // Find the actual index in the Hive box to support delete operations
            final boxIndex = box.values.toList().indexOf(todo);
            return TodoItem(
              todo: todo,
              index: boxIndex,
              todoService: todoService,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task, size: 80, color: Colors.teal.withOpacity(0.5)),
          SizedBox(height: 16),
          Text(
            'Belum ada todo 😴',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tambahkan tugas baru untuk memulai',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMatchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Tidak ada tugas yang sesuai',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
