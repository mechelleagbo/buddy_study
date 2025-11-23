class SessionLog {
  final int? id;
  final int? subjectId;
  final String? subjectName;
  final int durationMinutes;
  final DateTime startedAt;

  SessionLog(
      {this.id,
      this.subjectId,
      this.subjectName,
      required this.durationMinutes,
      required this.startedAt});

  factory SessionLog.fromJson(Map<String, dynamic> j) => SessionLog(
        id: j['id'] != null ? int.tryParse(j['id'].toString()) : null,
        subjectId: j['subject_id'] != null
            ? int.tryParse(j['subject_id'].toString())
            : null,
        subjectName: j['subject_name'],
        durationMinutes: int.parse(j['duration_minutes'].toString()),
        startedAt: DateTime.parse(j['started_at'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject_id': subjectId,
        'subject_name': subjectName,
        'duration_minutes': durationMinutes,
        'started_at': startedAt.toIso8601String(),
      };
}
