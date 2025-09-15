import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:settings_ui/settings_ui.dart';
import '../data/database_service.dart';
import '../data/models.dart';

class GoalsSetPage extends StatefulWidget {
  const GoalsSetPage({super.key});

  @override
  State<GoalsSetPage> createState() => _GoalsSetPageState();
}

class _GoalsSetPageState extends State<GoalsSetPage> {
  List<ActivityCategory> categories = [];
  String goals_type = 'Weekly';
  int? goals_hours;
  int? confirmed_category_id;

  String? selectedValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await DatabaseService().activitiesCategories();
    setState(() {
      categories = cats;
    });
  }

  Color parseColor(String color) {
    String hex = color.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    return Color(int.parse(hex, radix: 16));
  }

  String colorToHex(Color color) {
    // color.value je ARGB int
    int argb = color.value;
    int r = (argb >> 16) & 0xFF;
    int g = (argb >> 8) & 0xFF;
    int b = argb & 0xFF;

    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  Future<void> _addCategory(String newCategory, Color pickedColor) async {
    if (newCategory.isNotEmpty) {
      // prevedieme na hex kód #RRGGBB
      String hexColor = colorToHex(pickedColor);

      await DatabaseService().insertActivityCategory(
        ActivityCategory(category: newCategory, goal_hours: 0, color: hexColor),
      );

      await _loadCategories();
      print(await DatabaseService().activitiesCategories());
    }
  }

  @override
  Widget build(BuildContext Context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set your goals")),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              onTap: (index) {
                setState(() {
                  goals_type = index == 0 ? 'Weekly' : 'Monthly';
                });
                print(goals_type);
              },
              tabs: [
                Tab(child: Text('Weekly Goals')),
                Tab(child: Text('Monthly Goals')),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView.builder(
                    itemCount: categories.length > 1
                        ? categories.length - 1
                        : 0,
                    itemBuilder: (context, index) {
                      final cat = categories[index + 1];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: parseColor(cat.color),
                        ),
                        title: Text(cat.category),
                        trailing: Text(
                          cat.goal_hours == 0
                              ? 'Not set'
                              : cat.goal_hours.toString(),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              int enteredHours = 0;
                              Color selectedColor = parseColor(cat.color);

                              return AlertDialog(
                                title: Text(cat.category),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: 'Enter hours',
                                        ),
                                        onChanged: (value) {
                                          enteredHours =
                                              int.tryParse(value) ?? 0;
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      Text("Pick a color"),
                                      BlockPicker(
                                        pickerColor: selectedColor,
                                        onColorChanged: (color) {
                                          selectedColor = color;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Close"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        cat.goal_hours = enteredHours;
                                      });
                                      print(
                                        "potvrdena kategoria $cat s hodinami $enteredHours",
                                      );
                                      await DatabaseService()
                                          .updateActivityCategory(cat);
                                      print(
                                        await DatabaseService()
                                            .activitiesCategories(),
                                      );

                                      if (!mounted) return;
                                      
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Save"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Delete ${cat.category}?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await DatabaseService()
                                          .removeActivityCategory(cat.category);

                                      setState(() {
                                        categories.remove(cat);
                                      });

                                      if (!mounted) return;

                                      Navigator.pop(context);
                                    },
                                    child: Text("Confirm"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  ListView.builder(
                    itemCount: categories.length > 1
                        ? categories.length - 1
                        : 0,
                    itemBuilder: (context, index) {
                      final cat = categories[index + 1];
                      return ListTile(
                        title: Text(cat.category),
                        trailing: Text(
                          cat.goal_hours == 0
                              ? 'Not set'
                              : (cat.goal_hours * 4).toString(),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              int enteredHours = 0;
                              Color selectedColor = parseColor(cat.color);

                              return AlertDialog(
                                title: Text(cat.category),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'Enter hours',
                                      ),
                                      onChanged: (value) {
                                        enteredHours = int.tryParse(value) ?? 0;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    Text("Pick a color"),
                                    BlockPicker(
                                      pickerColor: selectedColor,
                                      onColorChanged: (color) {
                                        selectedColor = color;
                                      },
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Close"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        cat.goal_hours = (enteredHours / 4)
                                            .round();
                                      });
                                      print(
                                        "potvrdena kategoria $cat s hodinami $enteredHours",
                                      );
                                      await DatabaseService()
                                          .updateActivityCategory(cat);

                                      print(
                                        await DatabaseService()
                                            .activitiesCategories(),
                                      );

                                      if (!mounted) return;

                                      Navigator.pop(context);
                                    },
                                    child: const Text("Save"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String newCategory = "";
              Color pickedColor = Colors.black;

              return AlertDialog(
                title: const Text("Add category"),
                content: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(hintText: "New category"),
                      onChanged: (value) {
                        newCategory = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text("Pick a color"),
                    BlockPicker(
                      pickerColor: pickedColor,
                      onColorChanged: (color) {
                        pickedColor = color;
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _addCategory(newCategory, pickedColor);

                        if (!mounted) return;

                        Navigator.pop(context);
                      },
                      child: Text("Save category"),
                    ),
                  ],
                ),
              );
            },
          );
        },
        label: Text("Add category"),
      ),
    );
  }
}
