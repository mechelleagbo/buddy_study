import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class AddSubjectScreen extends StatefulWidget {
  @override
  _AddSubjectScreenState createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  bool _loading = false;

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
                  .withOpacity(0.2 + _random.nextDouble() * 0.3),
            ));
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
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Subject'),
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
          // Background particles
          CustomPaint(
            size: Size.infinite,
            painter: ParticlePainter(_particles),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
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
                    child: TextField(
                      controller: _ctrl,
                      decoration: InputDecoration(
                        labelText: 'Subject name',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.8, end: 1.0),
                    duration: Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    builder: (context, double scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _loading
                                ? null
                                : () async {
                                    final name = _ctrl.text.trim();
                                    if (name.isEmpty) return;
                                    setState(() => _loading = true);
                                    try {
                                      await prov.addSubject(name);
                                      Navigator.pop(context);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text('Failed: $e')));
                                    }
                                    setState(() => _loading = false);
                                  },
                            child: _loading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'Save',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Particle classes same as dashboard
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
