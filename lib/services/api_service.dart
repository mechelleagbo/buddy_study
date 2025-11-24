import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/subject.dart';
import '../models/session_log.dart';

class ApiService {
  static String API_BASE_URL = 'http://192.168.200.10/study_buddy_2/api';
  // <-- UPDATE

  // Subjects
  static Future<List<SubjectModel>> fetchSubjects() async {
    final res = await http.get(Uri.parse('$API_BASE_URL/subjects.php'));
    if (res.statusCode == 200) {
      final list = json.decode(res.body) as List;
      return list.map((e) => SubjectModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load subjects');
  }

  static Future<SubjectModel> addSubject(String name) async {
    final res = await http.post(Uri.parse('$API_BASE_URL/subjects.php'),
        body: json.encode({'name': name}),
        headers: {'Content-Type': 'application/json'});
    if (res.statusCode == 200) {
      final j = json.decode(res.body);
      return SubjectModel(
          id: int.tryParse(j['id'].toString()), name: j['name']);
    }
    throw Exception('Failed to add subject');
  }

  // Sessions
  static Future<List<SessionLog>> fetchSessions() async {
    final res = await http.get(Uri.parse('$API_BASE_URL/sessions.php'));
    if (res.statusCode == 200) {
      final list = json.decode(res.body) as List;
      return list.map((e) => SessionLog.fromJson(e)).toList();
    }
    throw Exception('Failed to load sessions');
  }

  static Future<void> addSession(SessionLog s) async {
    final res = await http.post(Uri.parse('$API_BASE_URL/sessions.php'),
        body: json.encode(s.toJson()),
        headers: {'Content-Type': 'application/json'});
    if (res.statusCode != 200)
      throw Exception('Failed to save session to server');
  }

  // Settings
  static Future<Map<String, String>> fetchSettings() async {
    final res = await http.get(Uri.parse('$API_BASE_URL/settings.php'));
    if (res.statusCode == 200) {
      final j = json.decode(res.body) as Map<String, dynamic>;
      return j.map((k, v) => MapEntry(k, v.toString()));
    }
    return {};
  }

  static Future<void> saveSetting(String key, String value) async {
    final res = await http.post(Uri.parse('$API_BASE_URL/settings.php'),
        body: json.encode({'key': key, 'value': value}),
        headers: {'Content-Type': 'application/json'});
    if (res.statusCode != 200) throw Exception('Failed to save setting');
  }
}
