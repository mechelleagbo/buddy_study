import 'package:flutter/foundation.dart';
import '../models/subject.dart';
import '../models/session_log.dart';
import '../services/api_service.dart';
import '../services/local_db.dart';

class AppProvider extends ChangeNotifier {
  List<SubjectModel> subjects = [];
  List<SessionLog> sessions = [];
  int pomodoroMinutes = 25;
  bool soundOn = true;

  Future<void> init() async {
    // load settings and data
    try {
      final settings = await ApiService.fetchSettings();
      pomodoroMinutes =
          int.tryParse(settings['pomodoro_minutes'] ?? '25') ?? 25;
      soundOn = (settings['sound_on'] ?? '1') == '1';
    } catch (_) {}

    await loadSubjects();
    // load sessions from local db first
    sessions = await LocalDb.getSessions();
    // then try to fetch from server and merge
    try {
      final remote = await ApiService.fetchSessions();
      sessions = remote;
    } catch (_) {}
    notifyListeners();
  }

  Future<void> loadSubjects() async {
    try {
      subjects = await ApiService.fetchSubjects();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addSubject(String name) async {
    final s = await ApiService.addSubject(name);
    subjects.insert(0, s);
    notifyListeners();
  }

  Future<void> addSession(SessionLog s) async {
    // store locally
    await LocalDb.insertSession(s);
    sessions.insert(0, s);
    notifyListeners();
    // try to save to server but don't fail the app if network fails
    try {
      await ApiService.addSession(s);
    } catch (_) {}
  }

  Future<void> saveSetting(String key, String value) async {
    try {
      await ApiService.saveSetting(key, value);
    } catch (_) {}
  }
}
