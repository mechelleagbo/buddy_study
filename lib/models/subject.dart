class SubjectModel {
  final int? id;
  final String name;
  SubjectModel({this.id, required this.name});
  factory SubjectModel.fromJson(Map<String, dynamic> j) => SubjectModel(
      id: j['id'] != null ? int.tryParse(j['id'].toString()) : null,
      name: j['name']);
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
