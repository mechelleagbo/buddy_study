import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ProgressScreen extends StatefulWidget {
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final int _numParticles = 30;
  late List<Particle> _particles;

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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);
    final today = DateTime.now();
    final sessionsToday = prov.sessions
        .where((s) =>
            s.startedAt.year == today.year &&
            s.startedAt.month == today.month &&
            s.startedAt.day == today.day)
        .toList();
    final totalMinutesToday =
        sessionsToday.fold<int>(0, (p, c) => p + c.durationMinutes);

    final Map<String, int> perSubject = {};
    for (var s in prov.sessions) {
      final k = s.subjectName ?? 'No subject';
      perSubject[k] = (perSubject[k] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Progress'),
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
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.8, end: 1.0),
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  builder: (context, double scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Text(
                        'Today total: $totalMinutesToday minutes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Sessions per subject:',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: perSubject.entries.length,
                    itemBuilder: (_, i) {
                      final e = perSubject.entries.elementAt(i);
                      return TweenAnimationBuilder(
                        tween: Tween<Offset>(
                            begin: Offset(1, 0), end: Offset(0, 0)),
                        duration: Duration(milliseconds: 400 + (i * 100)),
                        curve: Curves.easeOut,
                        builder: (context, Offset offset, child) {
                          return Transform.translate(
                            offset: offset * MediaQuery.of(context).size.width,
                            child: Opacity(
                              opacity: 1 - offset.dx,
                              child: Card(
                                elevation: 4,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 6),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  title: Text(
                                    e.key,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple),
                                  ),
                                  trailing: Text(
                                    '${e.value}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700]),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
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
