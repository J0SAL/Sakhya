/// DatabaseHelper — offline-first SQLite storage for Sakhya.
/// Uses sqflite. Stores users and daily summaries locally.
/// GameController calls this for all persistence instead of SharedPreferences.

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/user_profile.dart';
import '../models/day_summary.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'sakhya.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE day_summaries (
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        data TEXT NOT NULL,
        PRIMARY KEY (user_id, date)
      )
    ''');
  }

  // ── Users ──────────────────────────────────────────────────────────────────
  Future<List<UserProfile>> loadUsers() async {
    final db = await database;
    final rows = await db.query('users');
    return rows.map((r) => UserProfile.fromJson(jsonDecode(r['data'] as String))).toList();
  }

  Future<void> saveUser(UserProfile user) async {
    final db = await database;
    await db.insert(
      'users',
      {'id': user.id, 'data': jsonEncode(user.toJson())},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveAllUsers(List<UserProfile> users) async {
    final db = await database;
    if (users.isEmpty) {
      // If empty list, use deleteAllUsers instead
      await deleteAllUsers();
      return;
    }
    final batch = db.batch();
    for (final u in users) {
      batch.insert(
        'users',
        {'id': u.id, 'data': jsonEncode(u.toJson())},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Permanently deletes ALL users and ALL summaries from the database.
  Future<void> deleteAllUsers() async {
    final db = await database;
    await db.delete('day_summaries');
    await db.delete('users');
  }

  // ── Day Summaries ─────────────────────────────────────────────────────────
  Future<DaySummary?> loadSummary(String userId, String date) async {
    final db = await database;
    final rows = await db.query(
      'day_summaries',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
    );
    if (rows.isEmpty) return null;
    return DaySummary.fromJson(jsonDecode(rows.first['data'] as String));
  }

  Future<void> saveSummary(String userId, DaySummary summary) async {
    final db = await database;
    await db.insert(
      'day_summaries',
      {
        'user_id': userId,
        'date': summary.date,
        'data': jsonEncode(summary.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteSummary(String userId, String date) async {
    final db = await database;
    await db.delete(
      'day_summaries',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
    );
  }

  /// Loads the most recent pending summary (from any date) for a user.
  Future<DaySummary?> loadLatestSummary(String userId) async {
    final db = await database;
    final rows = await db.query(
      'day_summaries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DaySummary.fromJson(jsonDecode(rows.first['data'] as String));
  }
}
