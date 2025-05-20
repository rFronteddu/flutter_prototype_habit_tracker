import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/habit.dart';

class HabitDatabase extends ChangeNotifier {
  /*
  S E T U P
  */
  // Init DB
  static final HabitDatabase instance = HabitDatabase._init();
  static Database? _database;

  HabitDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('habits.db');
    return _database!;
  }

  Future<Database> _initDB(String filepath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filepath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE habits(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      completed_days TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE app_info (
      key TEXT PRIMARY KEY,
      value TEXT
    )
  ''');
  }

  Future<void> ensureFirstStartTimeSaved() async {
    final db = await database;
    final existing = await db.query(
      'app_info',
      where: 'key = ?',
      whereArgs: ['first_start'],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert('app_info', {
        'key': 'first_start',
        'value': DateTime.now().toIso8601String(),
      });
    }
  }

  // Save First date of app
  Future<void> saveFirstStartTime(DateTime time) async {
    final db = await database;
    await db.insert(
      'app_info',
      {'key': 'first_start', 'value': time.toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.ignore, // prevent overwrite
    );
  }

  // get first date of app start
  Future<DateTime?> getFirstStartTime() async {
    final db = await database;
    final result = await db.query(
      'app_info',
      where: 'key = ?',
      whereArgs: ['first_start'],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return DateTime.parse(result.first['value'] as String);
    } else {
      return null;
    }
  }

  /*
  C R U D
  */

  final List<Habit> currentHabits = [];

  // C - add new habit
  Future<void> insertHabit(String habitName) async {
    final newHabit = Habit(name: habitName, completedDays: []);

    final db = await database;
    await db.insert(
      'habits',
      newHabit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    getHabits();
  }

  // R - read saved habits from db
  Future<void> getHabits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('habits');
    currentHabits.clear();
    currentHabits.addAll(
      List.generate(maps.length, (i) {
        return Habit.fromMap(maps[i]);
      }),
    );

    notifyListeners();
  }

  // U - toggle habit
  Future<void> toggleHabitCompletion(int id, bool isCompleted) async {
    final db = await database;

    // fetch habit by id
    final result = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return; // habit not found

    // convert map to habit
    final habit = Habit.fromMap(result.first);

    // modify completed days
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);
    final updatedDays = List<DateTime>.from(habit.completedDays);

    if (isCompleted) {
      if (!updatedDays.any((d) => _isSameDay(d, dateOnly))) {
        updatedDays.add(dateOnly);
      }
    } else {
      updatedDays.removeWhere((d) => _isSameDay(d, dateOnly));
    }

    // create updated habit
    final updatedHabit = Habit(
      id: habit.id,
      name: habit.name,
      completedDays: updatedDays,
    );

    // update db
    await db.update(
      'habits',
      updatedHabit.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );

    getHabits();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // U - edit habit name
  Future<void> updateHabitName(int habitId, String newName) async {
    final db = await database;
    await db.update(
      'habits',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [habitId],
    );
    getHabits();
  }

  // D - delete habit
  Future<void> deleteHabit(int habitId) async {
    final db = await database;
    await db.delete('habits', where: 'id = ?', whereArgs: [habitId]);
    getHabits();
  }
}
