import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../providers/app_provider.dart';

class SubjectTile extends StatelessWidget {
  final SubjectModel subject;
  const SubjectTile({Key? key, required this.subject}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(subject.name),
      onTap: () {
        // set selected in provider temporarily by pushing Pomodoro with chosen subject via route args
        Navigator.pushNamed(context, '/pomodoro', arguments: subject);
      },
    );
  }
}
