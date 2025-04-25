// lib/widgets/todo_filters.dart
import 'package:flutter/material.dart';

class TodoFilters extends StatelessWidget {
  final String searchQuery;
  final String filterStatus;
  final Function(String) onSearchChanged;
  final Function(String?) onFilterChanged;

  const TodoFilters({
    Key? key,
    required this.searchQuery,
    required this.filterStatus,
    required this.onSearchChanged,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Field
        TextField(
          decoration: InputDecoration(
            hintText: 'Cari todo...',
            prefixIcon: Icon(Icons.search, color: Colors.teal),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.teal, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 16),
          ),
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 16),

        // Filter Dropdown
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.filter_list, color: Colors.teal),
                  SizedBox(width: 8),
                  Text('Filter:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Theme.of(context).cardColor,
                ),
                child: DropdownButton<String>(
                  value: filterStatus,
                  elevation: 2,
                  underline: Container(),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.teal),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Semua')),
                    DropdownMenuItem(value: 'done', child: Text('Selesai')),
                    DropdownMenuItem(
                        value: 'undone', child: Text('Belum Selesai')),
                  ],
                  onChanged: onFilterChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
