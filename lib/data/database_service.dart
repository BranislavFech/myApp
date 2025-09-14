import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models.dart';

class DatabaseService {
  static late final Future<Database> database;
  static late final Future<Database> databaseActivities;
  static late final Future<Database> databaseActivitiesCategory;

  static Future<void> init() async {
    final pathActivities = join(
      await getDatabasesPath(),
      'test_activities_db_v1.db',
    );
    final pathActivitiesCategories = join(
      await getDatabasesPath(),
      'test_activities_categories_db_v3.db',
    );

    // vymaže celú databázu
    //await deleteDatabase(pathActivities);
    //await deleteDatabase(pathActivitiesCategories);

    database = openDatabase(
      join(await getDatabasesPath(), 'test_db_v1.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE days (date TEXT PRIMARY KEY, cleanedTeethEvening INTEGER, cleanedTeethMorning INTEGER)',
        );
      },
      version: 1,
    );

    databaseActivities = openDatabase(
      join(await getDatabasesPath(), 'test_activities_db_v1.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE activities (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, duration INTEGER, category TEXT, FOREIGN KEY(date) REFERENCES days(date))',
        );
      },
      version: 1,
    );

    databaseActivitiesCategory = openDatabase(
      join(await getDatabasesPath(), 'test_activities_categories_db_v4.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE activities_categories (id INTEGER PRIMARY KEY AUTOINCREMENT, category TEXT, goal_hours INTEGER, color TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertMyDay(MyDay myDay) async {
    final db = await database;

    await db.insert(
      'days',
      myDay.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<DateTime, List<Map<String, dynamic>>>> activitiesData() async {
    final db = await databaseActivities;

    final result = await db.rawQuery('''
    SELECT category, duration, date
    FROM activities
  ''');

    final Map<DateTime, List<Map<String, dynamic>>> activities = {};

    for (final row in result) {
      final date = DateTime.parse(row['date'] as String);

      final activity = {
        'category': row['category'] as String,
        'duration': row['duration'] as int,
      };

      activities.putIfAbsent(date, () => []);
      activities[date]!.add(activity);
    }
    return activities;
  }

  Color parseColor(String color) {
    String hex = color.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    return Color(int.parse(hex, radix: 16));
  }

  Future<Map<String, Color>> categoryColors() async {
    final db = await databaseActivitiesCategory;

    final result = await db.rawQuery('''
    SELECT category, color
    FROM activities_categories
  ''');

    final Map<String, Color> catColors = {};

    for (final row in result) {
      final category = row['category'] as String;
      final colorString = row['color'] as String;
      final color = parseColor(colorString);

      catColors[category] = color;
    }
    return catColors;
  }

  Future<Map<String, Map<String, int>>> totalHoursPerCategory() async {
    final db = await databaseActivities;
    final today = DateTime.now();

    final monday = today.subtract(Duration(days: today.weekday - 1));
    final weekStart = monday.toIso8601String().split('T').first;
    final end = today.toIso8601String().split('T').first;

    final weekResult = await db.rawQuery(
      '''
    SELECT category, SUM(duration) as total_hours
    FROM activities
    WHERE date BETWEEN ? AND ?
    GROUP BY category
  ''',
      [weekStart, end],
    );

    final Map<String, int> weekTotals = {};
    for (final row in weekResult) {
      weekTotals[row['category'] as String] = row['total_hours'] as int;
    }

    final firstDayOfMonth = DateTime(today.year, today.month, 1);
    final monthStart = firstDayOfMonth.toIso8601String().split('T').first;

    final monthResult = await db.rawQuery(
      '''
    SELECT category, SUM(duration) as total_hours
    FROM activities
    WHERE date BETWEEN ? AND ?
    GROUP BY category
  ''',
      [monthStart, end],
    );

    final Map<String, int> monthTotals = {};
    for (final row in monthResult) {
      monthTotals[row['category'] as String] = row['total_hours'] as int;
    }

    return {"week": weekTotals, "month": monthTotals};
  }

  Future<List<MyDay>> days() async {
    final db = await database;
    final List<Map<String, Object?>> dayMaps = await db.query('days');

    return dayMaps.map((map) {
      return MyDay(
        date: map['date'] as String,
        cleanedTeethMorning: (map['cleanedTeethMorning'] as int) == 1,
        cleanedTeethEvening: (map['cleanedTeethEvening'] as int) == 1,
      );
    }).toList();
  }

  Future<void> insertActivity(Activity activity) async {
    final db = await databaseActivities;

    await db.insert(
      'activities',
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Activity>> activities() async {
    final db = await databaseActivities;
    final List<Map<String, Object?>> activityMaps = await db.query(
      'activities',
    );

    return activityMaps.map((map) {
      return Activity(
        id: map['id'] as int,
        date: map['date'] as String,
        duration: map['duration'] as int,
        category: map['category'] as String,
      );
    }).toList();
  }

  Future<void> insertActivityCategory(ActivityCategory cateogry) async {
    final db = await databaseActivitiesCategory;

    await db.insert(
      'activities_categories',
      cateogry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateActivityCategory(ActivityCategory cateogry) async {
    final db = await databaseActivitiesCategory;

    await db.update(
      'activities_categories',
      cateogry.toMap(),
      where: 'category = ?',
      whereArgs: [cateogry.category],
    );
  }

  Future<void> removeActivityCategory(String cateogry) async {
    final dbCategories = await databaseActivitiesCategory;

    await dbCategories.delete(
      'activities_categories',
      where: 'category = ?',
      whereArgs: [cateogry],
    );

    final dbActivities = await databaseActivities;

    await dbActivities.update(
      'activities',
      {'category': 'Not specified'},
      where: 'category = ?',
      whereArgs: [cateogry],
    );
  }

  Future<List<ActivityCategory>> activitiesCategories() async {
    final db = await databaseActivitiesCategory;
    final List<Map<String, Object?>> activityCategoryMaps = await db.query(
      'activities_categories',
    );

    return activityCategoryMaps.map((map) {
      return ActivityCategory(
        id: map['id'] as int,
        category: map['category'] as String,
        goal_hours: map['goal_hours'] as int,
        color: map['color'] as String,
      );
    }).toList();
  }

  Future<void> ensureDefaultCategories() async {
    final db = await databaseActivitiesCategory;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM activities_categories'),
    );
    print("Count bol $count");
    if (count == 0) {
      print("Vkladam kategorie");
      final List<Map<String, dynamic>> defaults = [
        {'category': 'Not specified', 'color': '#9E9E9E'},
        {'category': 'School', 'color': '#2196F3'},
        {'category': 'Work', 'color': '#4CAF50'},
        {'category': 'House chores', 'color': '#FF9800'},
        {'category': 'Exercise', 'color': '#F44336'},
      ];

      for (final cat in defaults) {
        await insertActivityCategory(
          ActivityCategory(
            category: cat['category'],
            goal_hours: 0,
            color: cat['color'],
          ),
        );
      }
    }
  }
}
