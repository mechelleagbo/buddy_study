import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../models/session_log.dart';
import '../providers/app_provider.dart';

class PomodoroScreen extends StatefulWidget {
  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with SingleTickerProviderStateMixin {
  SubjectModel? selectedSubject;
  Timer? _timer;
  Duration remaining = Duration.zero;
  bool running = false;

  late AnimationController _controller;
  final Random _random = Random();
  final int _numParticles = 30;
  late List<Particle> _particles;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg != null && arg is SubjectModel) selectedSubject = arg;
    final prov = Provider.of<AppProvider>(context, listen: false);
    remaining = Duration(minutes: prov.pomodoroMinutes);
  }

  @override
  void initState() {
    super.initState();
    _particles = List.generate(
      _numParticles,
      (index) => Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 4 + 2,
        speed: _random.nextDouble() * 0.002 + 0.001,
        color:
            Colors.purpleAccent.withOpacity(0.2 + _random.nextDouble() * 0.3),
      ),
    );

    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 60))
          ..addListener(_updateParticles)
          ..repeat();
  }

  void _updateParticles() {
    setState(() {
      for (var p in _particles) {
        p.y -= p.speed;
        if (p.y < 0) {
          p.y = 1.0;
          p.x = _random.nextDouble();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void startTimer() {
    if (running) return;
    setState(() => running = true);
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        if (remaining.inSeconds > 0)
          remaining -= Duration(seconds: 1);
        else {
          _timer?.cancel();
          running = false;
          onSessionComplete();
        }
      });
    });
  }

  void stopTimer() {
    _timer?.cancel();
    setState(() => running = false);
  }

  Future<void> onSessionComplete() async {
    final prov = Provider.of<AppProvider>(context, listen: false);
    final now = DateTime.now();
    final s = SessionLog(
        subjectId: selectedSubject?.id,
        subjectName: selectedSubject?.name,
        durationMinutes: prov.pomodoroMinutes,
        startedAt: now);
    await prov.addSession(s);

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Session complete'),
              content: Text(
                  'Saved session for ${selectedSubject?.name ?? 'No Subject'}'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context), child: Text('OK'))
              ],
            ));

    setState(() => remaining = Duration(minutes: prov.pomodoroMinutes));
  }

  String fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pomodoro'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 6,
      ),
      body: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: ParticlePainter(_particles),
          ),
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                TweenAnimationBuilder(
                  tween:
                      Tween<Offset>(begin: Offset(0, 0.3), end: Offset(0, 0)),
                  duration: Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  builder: (context, Offset offset, child) {
                    return Transform.translate(
                      offset: Offset(0, offset.dy * 50),
                      child: child,
                    );
                  },
                  child: DropdownButtonFormField<SubjectModel?>(
                    value: selectedSubject,
                    hint: Text('Select subject (optional)'),
                    items: [null, ...prov.subjects]
                        .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s == null ? 'No Subject' : s.name)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedSubject = v),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Expanded(
                  child: Center(
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.8, end: 1.0),
                      duration: Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, double scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Text(fmt(remaining),
                              style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple)),
                        );
                      },
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: running ? null : startTimer,
                      child: Text('Start Session'),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: running ? stopTimer : null,
                      child: Text('Stop'),
                    ),
                  ],
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Particle classes
class Particle {
  double x;
  double y;
  double size;
  double speed;
  Color color;

  Particle(
      {required this.x,
      required this.y,
      required this.size,
      required this.speed,
      required this.color});
}

class ParticlePainter extends CustomPainter {
  List<Particle> particles;
  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var p in particles) {
      paint.color = p.color;
      canvas.drawCircle(
          Offset(p.x * size.width, p.y * size.height), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
