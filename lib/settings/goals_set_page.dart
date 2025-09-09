import 'package:flutter/material.dart';
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
                    itemCount: categories.length - 1,
                    itemBuilder: (context, index) {
                      final cat = categories[index + 1];
                      return ListTile(
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
                                        cat.goal_hours = enteredHours;
                                      });
                                      print(
                                        "potvrdena kategoria $cat s hodinami $enteredHours",
                                      );
                                      await DatabaseService().updateActivityCategory(cat);
                                      print(
                                        await DatabaseService()
                                            .activitiesCategories(),
                                      );
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
                  ListView.builder(
                    itemCount: categories.length - 1,
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
                                      await DatabaseService().updateActivityCategory(cat);

                                      print(
                                        await DatabaseService()
                                            .activitiesCategories(),
                                      );
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
    );
  }
}
