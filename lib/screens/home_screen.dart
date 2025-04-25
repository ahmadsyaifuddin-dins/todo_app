import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/helpers/notification_service.dart';
import '../models/todo_model.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _todoBox = Hive.box<Todo>('todos');
  final _controller = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'all'; // bisa: all, done, undone

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTodo(String title) async {
    if (title.trim().isEmpty) return;

    // Menampilkan date picker untuk memilih tanggal deadline
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      // Membuat Todo baru dengan deadline yang dipilih
      final newTodo = Todo(
        title: title,
        deadline: picked, // simpan deadline
      );

      final id = DateTime.now()
          .millisecondsSinceEpoch
          .remainder(100000); // random id untuk notification

      // Menambahkan Todo ke dalam Hive box
      _todoBox.add(newTodo);
      _controller.clear();

      // Set reminder jam 5 pagi pada tanggal deadline
      DateTime reminderTime =
          DateTime(picked.year, picked.month, picked.day, 5);

      // Mengecek apakah reminderTime lebih dari waktu sekarang
      if (reminderTime.isAfter(DateTime.now())) {
        // Menampilkan reminder jika waktu deadline valid
        NotificationService.showReminder(id, title, reminderTime);
      }
    }
  }

  void _deleteTodo(int index) {
    _todoBox.deleteAt(index);
  }

  void _toggleCheck(Todo todo) {
    todo.isDone = !todo.isDone;
    todo.save(); // karena extend HiveObject
  }

  void _editTodo(int index, Todo todo) {
    final editController = TextEditingController(text: todo.title);
    DateTime? newDeadline = todo.deadline;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editController,
                decoration: const InputDecoration(hintText: 'Judul baru...'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(newDeadline == null
                    ? 'Pilih Deadline'
                    : 'Ubah Deadline (${newDeadline!.toLocal().toString().split(' ')[0]})'),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: newDeadline ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => newDeadline = picked);
                  }
                },
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final newTitle = editController.text.trim();
                if (newTitle.isNotEmpty) {
                  todo.title = newTitle;
                  todo.deadline = newDeadline;
                  todo.save(); // simpan
                }
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dins Todo App 🐝'),
        centerTitle: true,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return Switch(
                value: themeProvider.isDarkMode,
                onChanged: themeProvider.toggleTheme,
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input field + Add button
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari todo...',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Filter Dropdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filter:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: _filterStatus,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Semua')),
                        DropdownMenuItem(value: 'done', child: Text('Selesai')),
                        DropdownMenuItem(
                            value: 'undone', child: Text('Belum Selesai')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _filterStatus = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Add Todo Field + Button
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Tambah tugas...',
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _addTodo(_controller.text),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: const CircleBorder(),
                        backgroundColor: Colors.teal,
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // List Todo
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _todoBox.listenable(),
                builder: (context, Box<Todo> box, _) {
                  if (box.isEmpty) {
                    return const Center(child: Text('Belum ada todo 😴'));
                  }

                  final filteredList = box.values.where((todo) {
                    final matchesSearch =
                        todo.title.toLowerCase().contains(_searchQuery);
                    final matchesFilter = _filterStatus == 'all' ||
                        (_filterStatus == 'done' && todo.isDone) ||
                        (_filterStatus == 'undone' && !todo.isDone);
                    return matchesSearch && matchesFilter;
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final todo = filteredList[index];

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          subtitle: todo.deadline != null
                              ? Text(
                                  'Deadline: ${todo.deadline!.toLocal().toString().split(' ')[0]}',
                                  style: TextStyle(
                                    color: todo.deadline!
                                                .isBefore(DateTime.now()) &&
                                            !todo.isDone
                                        ? Colors.red
                                        : Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              : null,
                          leading: Checkbox.adaptive(
                            value: todo.isDone,
                            onChanged: (_) => _toggleCheck(todo),
                          ),
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              fontSize: 16,
                              decoration: todo.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.blueAccent),
                                onPressed: () => _editTodo(index, todo),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTodo(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
