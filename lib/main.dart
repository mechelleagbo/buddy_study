import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/dashboard.dart';
import 'screens/add_subject.dart';
import 'screens/pomodoro.dart';
import 'screens/history.dart';
import 'screens/progress.dart';
import 'screens/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final provider = AppProvider();
  await provider.init();
  runApp(MyApp(provider: provider));
}

class MyApp extends StatelessWidget {
  final AppProvider provider;
  const MyApp({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(
        title: 'Study Buddy',
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        initialRoute: '/',
        routes: {
          '/': (_) => DashboardScreen(),
          '/add-subject': (_) => AddSubjectScreen(),
          '/pomodoro': (_) => PomodoroScreen(),
          '/history': (_) => HistoryScreen(),
          '/progress': (_) => ProgressScreen(),
          '/settings': (_) => SettingsScreen(),
        },
      ),
    );
  }
}
