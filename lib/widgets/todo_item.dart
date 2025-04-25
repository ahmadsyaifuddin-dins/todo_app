// lib/widgets/todo_item.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/todo_model.dart';
import '../services/todo_service.dart';
import '../main.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final int index;
  final TodoService todoService;

  const TodoItem({
    Key? key,
    required this.todo,
    required this.index,
    required this.todoService,
  }) : super(key: key);

  void _toggleCheck(BuildContext context, Todo todo) {
    HapticFeedback.lightImpact();
    todoService.toggleTodoStatus(todo);

    if (todo.isDone) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Tugas selesai!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
    }
  }

  void _deleteTodo(BuildContext context, int index) async {
    // Store a reference to the todo before deleting
    final deletedTodo = todo;

    // Delete the todo
    await todoService.deleteTodoAtIndex(index);

    // Use the global scaffold messenger key to show the SnackBar
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('Tugas "${deletedTodo.title}" dihapus'),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'BATAL',
          textColor: Colors.white,
          onPressed: () {
            todoService.undoDelete();
          },
        ),
      ),
    );
  }

  void _editTodo(BuildContext context, Todo todo) {/* unchanged */}

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = todo.deadline != null &&
        todo.deadline!.isBefore(DateTime.now()) &&
        !todo.isDone;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isOverdue
              ? BorderSide(color: Colors.red.withOpacity(0.5), width: 2)
              : todo.isDone
                  ? BorderSide(color: Colors.green.withOpacity(0.5), width: 2)
                  : BorderSide.none,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _toggleCheck(context, todo),
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.teal.withOpacity(0.2),
            child: Container(
              decoration: BoxDecoration(
                gradient: todo.isDone
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green.withOpacity(0.05),
                          Colors.teal.withOpacity(0.05),
                        ],
                      )
                    : isOverdue
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.red.withOpacity(0.05),
                              Colors.orange.withOpacity(0.05),
                            ],
                          )
                        : null,
              ),
              child: ListTile(
                leading: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: todo.isDone
                          ? Colors.green
                          : isOverdue
                              ? Colors.red
                              : Colors.teal,
                      width: 2,
                    ),
                  ),
                  child: Checkbox(
                    value: todo.isDone,
                    onChanged: (_) => _toggleCheck(context, todo),
                    shape: CircleBorder(),
                    activeColor: Colors.green,
                    checkColor: Colors.white,
                  ),
                ),
                title: Text(
                  todo.title,
                  style: TextStyle(
                    decoration: todo.isDone ? TextDecoration.lineThrough : null,
                    color: todo.isDone
                        ? Colors.grey
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                subtitle: todo.deadline == null
                    ? null
                    : Text(
                        '${todo.deadline!.day}/${todo.deadline!.month}/${todo.deadline!.year} ${todo.deadline!.hour.toString().padLeft(2, '0')}:${todo.deadline!.minute.toString().padLeft(2, '0')}' +
                            (isOverdue ? '  (Terlambat!)' : ''),
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: isOverdue ? Colors.red : Colors.grey,
                        ),
                      ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      tooltip: 'Edit Tugas',
                      onPressed: () => _editTodo(context, todo),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      tooltip: 'Hapus Tugas',
                      onPressed: () => _deleteTodo(context, index),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
