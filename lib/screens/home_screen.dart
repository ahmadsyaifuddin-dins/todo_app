// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/theme_provider.dart';
import '../services/todo_service.dart';
import '../widgets/add_todo_form.dart';
import '../widgets/todo_filters.dart';
import '../widgets/todo_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TodoService _todoService = TodoService();
  final TextEditingController _controller = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, done, undone

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: _buildAppBar(themeProvider),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: themeProvider.isDarkMode
                ? [
                    Colors.grey.shade900,
                    Colors.black87,
                  ]
                : [
                    Colors.teal.shade50,
                    Colors.white,
                  ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Input card with search, filter and add todo
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search and filter widgets
                      TodoFilters(
                        searchQuery: _searchQuery,
                        filterStatus: _filterStatus,
                        onSearchChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                        onFilterChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _filterStatus = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Add Todo form
                      AddTodoForm(
                        controller: _controller,
                        todoService: _todoService,
                        onTodoAdded: () {
                          setState(() {
                            // Reset search if needed
                            // _searchQuery = '';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Todo List
              Expanded(
                child: TodoList(
                  searchQuery: _searchQuery,
                  filterStatus: _filterStatus,
                  todoService: _todoService,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(ThemeProvider themeProvider) {
    return AppBar(
      elevation: 0,
      title: Row(
        children: [
          Icon(Icons.task_alt, color: Colors.teal),
          SizedBox(width: 8),
          Text(
            'Dins Todo App 🐝',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color:
                    themeProvider.isDarkMode ? Colors.amber : Colors.blueGrey,
              ),
              onPressed: () {
                themeProvider.toggleTheme(themeProvider.isDarkMode);
              },
              tooltip: themeProvider.isDarkMode ? 'Mode Terang' : 'Mode Gelap',
            );
          },
        ),
        SizedBox(width: 8),
      ],
    );
  }
}
