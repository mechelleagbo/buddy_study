import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/session_log.dart';

class LocalDb {
  static Database? _db;
  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'study_buddy.db');
    return openDatabase(path, version: 1, onCreate: (db, v) async {
      await db.execute('''
        CREATE TABLE sessions_local (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          subject_id INTEGER,
          subject_name TEXT,
          duration_minutes INTEGER,
          started_at TEXT
        )
      ''');
    });
  }

  static Future<int> insertSession(SessionLog s) async {
    final d = await db;
    return d.insert('sessions_local', {
      'subject_id': s.subjectId,
      'subject_name': s.subjectName,
      'duration_minutes': s.durationMinutes,
      'started_at': s.startedAt.toIso8601String(),
    });
  }

  static Future<List<SessionLog>> getSessions() async {
    final d = await db;
    final rows = await d.query('sessions_local', orderBy: 'started_at DESC');
    return rows
        .map((r) => SessionLog(
              id: r['id'] as int?,
              subjectId: r['subject_id'] as int?,
              subjectName: r['subject_name'] as String?,
              durationMinutes: r['duration_minutes'] as int,
              startedAt: DateTime.parse(r['started_at'] as String),
            ))
        .toList();
  }
}
