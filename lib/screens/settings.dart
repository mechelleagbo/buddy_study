import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
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
    final ctrl = TextEditingController(text: prov.pomodoroMinutes.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
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
                      controller: ctrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Pomodoro minutes',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TweenAnimationBuilder(
                    tween:
                        Tween<Offset>(begin: Offset(0, 0.3), end: Offset(0, 0)),
                    duration: Duration(milliseconds: 700),
                    curve: Curves.easeOut,
                    builder: (context, Offset offset, child) {
                      return Transform.translate(
                        offset: Offset(0, offset.dy * 50),
                        child: child,
                      );
                    },
                    child: SwitchListTile(
                      title: Text(
                        'Sound/Alerts',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      value: prov.soundOn,
                      onChanged: (v) {
                        prov.soundOn = v;
                        prov.saveSetting('sound_on', v ? '1' : '0');
                        prov.notifyListeners();
                      },
                    ),
                  ),
                  SizedBox(height: 20),
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
                            onPressed: () async {
                              final m = int.tryParse(ctrl.text.trim()) ??
                                  prov.pomodoroMinutes;
                              prov.pomodoroMinutes = m;
                              await prov.saveSetting(
                                  'pomodoro_minutes', m.toString());
                              prov.notifyListeners();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Saved')));
                            },
                            child: Text(
                              'Save',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12),
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
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      'To reset logs: delete the database file or add a clear action.')));
                            },
                            child: Text(
                              'Reset logs (manual)',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
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
