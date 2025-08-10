import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models.dart';


class DatabaseService {
  static late final Future<Database> database;
  static late final Future<Database> databaseActivities;

  static Future<void> init() async {
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
  }


  Future<void> insertMyDay(MyDay myDay) async {
    final db = await database;

    await db.insert(
      'days',
      myDay.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
    final List<Map<String, Object?>> activityMaps = await db.query('activities');

    return activityMaps.map((map) {
      return Activity(
        id: map['id'] as int,
        date: map['date'] as String,
        duration: map['duration'] as int,
        category: map['category'] as String,
      );
    }).toList();
  }
}