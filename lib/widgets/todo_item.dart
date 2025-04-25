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

  void _editTodo(BuildContext context, Todo todo) {
    final editController = TextEditingController(text: todo.title);
    DateTime? newDeadline = todo.deadline;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Theme.of(context).dialogBackgroundColor,
            title: Row(
              children: [
                Icon(Icons.edit, color: Colors.teal),
                SizedBox(width: 10),
                Text('Edit Todo'),
              ],
            ),
            content: Container(
              constraints: BoxConstraints(maxWidth: 400),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul baru
                    Text('Judul Tugas',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.teal)),
                    SizedBox(height: 5),
                    TextField(
                      controller: editController,
                      decoration: InputDecoration(
                        hintText: 'Judul baru...',
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.task),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Deadline date picker
                    Text('Pengaturan Deadline',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.teal)),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: newDeadline ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                          builder: (c, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Colors.teal,
                                onPrimary: Colors.white,
                                onSurface: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color ??
                                    Colors.black,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            newDeadline = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              newDeadline?.hour ?? 9,
                              newDeadline?.minute ?? 0,
                            );
                          });
                        }
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.teal.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.teal),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                newDeadline == null
                                    ? 'Pilih Tanggal'
                                    : 'Tanggal: ${newDeadline!.day}/${newDeadline!.month}/${newDeadline!.year}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Time picker
                    InkWell(
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: newDeadline != null
                              ? TimeOfDay(
                                  hour: newDeadline!.hour,
                                  minute: newDeadline!.minute)
                              : TimeOfDay(hour: 9, minute: 0),
                          builder: (c, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Colors.teal,
                                onSurface: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color ??
                                    Colors.black,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (pickedTime != null && newDeadline != null) {
                          setState(() {
                            newDeadline = DateTime(
                              newDeadline!.year,
                              newDeadline!.month,
                              newDeadline!.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.teal.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.teal),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                newDeadline == null
                                    ? 'Pilih Waktu'
                                    : 'Waktu: ${newDeadline!.hour.toString().padLeft(2, '0')}:${newDeadline!.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton.icon(
                icon: Icon(Icons.close),
                label: Text('Batal'),
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Simpan'),
                onPressed: () {
                  final newTitle = editController.text.trim();
                  if (newTitle.isNotEmpty && newDeadline != null) {
                    todoService.updateTodo(todo, newTitle, newDeadline!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tugas berhasil diperbarui'),
                        backgroundColor: Colors.teal,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          );
        });
      },
    );
  }

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
