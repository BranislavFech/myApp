import 'package:flutter/material.dart';
import 'package:myapp/data/database_service.dart';
import 'package:myapp/data/models.dart';

class CategoryDropdown extends StatefulWidget {
  final String? selectedValue;
  final Function(String?) onChanged;

  const CategoryDropdown({
    super.key,
    this.selectedValue,
    required this.onChanged,
  });

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  List<ActivityCategory> categories = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await DatabaseService().activitiesCategories();
    setState(() {
      categories = [
        ...cats,
        ActivityCategory(id: -1, category: '+ Add category'),
      ];
    });
  }

  Future<void> _addCategory() async {
    String input = "";

    String? newCategory = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add new category"),
          content: TextField(
            onChanged: (value) {
              input = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, input),
              child: const Text("Add"),
            ),
          ],
        );
      },
    );

    if (newCategory != null && newCategory.isNotEmpty) {
      await DatabaseService().insertActivityCategory(
        ActivityCategory(category: newCategory),
      );
      await _loadCategories();
      widget.onChanged(newCategory);

      print(await DatabaseService().activitiesCategories());
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        hint: Text('Select category', style: TextStyle(fontSize: 14)),
        items: categories
            .map(
              (cat) => DropdownMenuItem<String>(
                value: cat.category,
                child: Text(cat.category, style: const TextStyle(fontSize: 14)),
              ),
            )
            .toList(),
        value: widget.selectedValue,
        onChanged: (String? value) async {
          if (value != '+ Add category') {
            widget.onChanged(value);
          } else {
            await _addCategory();
          }
        },
      ),
    );
  }
}
