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
            const TabBar(
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
                      return ListTile(title: Text(cat.category));
                    },
                  ),
                  ListView.builder(
                    itemCount: categories.length - 1,
                    itemBuilder: (context, index) {
                      final cat = categories[index + 1];
                      return ListTile(title: Text(cat.category));
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
