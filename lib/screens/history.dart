import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
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
        color: Colors.purpleAccent
            .withOpacity(0.2 + _random.nextDouble() * 0.3), // subtle opacity
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

    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
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
          // Animated background particles
          CustomPaint(
            size: Size.infinite,
            painter: ParticlePainter(_particles),
          ),
          prov.sessions.isEmpty
              ? Center(
                  child: Text(
                    'No sessions yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: prov.sessions.length,
                  itemBuilder: (_, i) {
                    final s = prov.sessions[i];
                    // Animate each card
                    return TweenAnimationBuilder(
                      tween:
                          Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0)),
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
                                  horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                title: Text(
                                  '${s.subjectName ?? 'No subject'}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple),
                                ),
                                subtitle: Text(
                                  '${s.durationMinutes} min — ${s.startedAt.toLocal()}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
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
