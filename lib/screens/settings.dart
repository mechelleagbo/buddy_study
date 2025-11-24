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
  final int _numParticles = 35;
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
        color: Colors.deepPurpleAccent
            .withOpacity(0.15 + _random.nextDouble() * 0.3),
      ),
    );

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 60))
          ..addListener(_updateParticles)
          ..repeat();
  }

  void _updateParticles() {
    for (var p in _particles) {
      p.y -= p.speed;
      if (p.y < 0) {
        p.y = 1.0;
        p.x = _random.nextDouble();
      }
    }
    setState(() {});
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
        title: const Text('Settings'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 8,
      ),
      body: Stack(
        children: [
          CustomPaint(
            painter: ParticlePainter(_particles),
            size: Size.infinite,
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  // ================= MINUTES TEXTFIELD =================
                  TweenAnimationBuilder(
                    tween: Tween<Offset>(
                        begin: const Offset(0, 0.4), end: Offset.zero),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    builder: (context, Offset offset, child) {
                      return Transform.translate(
                        offset: Offset(0, offset.dy * 60),
                        child: child,
                      );
                    },
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: TextField(
                          controller: ctrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Pomodoro minutes',
                            prefixIcon: const Icon(Icons.timer),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= SOUND SWITCH =================
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.9, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                    builder: (context, double scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          'Sound / Alerts',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        secondary: const Icon(Icons.volume_up),
                        value: prov.soundOn,
                        onChanged: (v) {
                          prov.soundOn = v;
                          prov.saveSetting('sound_on', v ? '1' : '0');
                          prov.notifyListeners();
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ================= SAVE BUTTON =================
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.8, end: 1),
                    duration: const Duration(milliseconds: 550),
                    curve: Curves.elasticOut,
                    builder: (_, double scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                            ),
                            onPressed: () async {
                              final m = int.tryParse(ctrl.text.trim()) ??
                                  prov.pomodoroMinutes;
                              prov.pomodoroMinutes = m;
                              await prov.saveSetting(
                                  'pomodoro_minutes', m.toString());
                              prov.notifyListeners();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Saved')),
                              );
                            },
                            child: const Text(
                              'Save Settings',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // ================= RESET BUTTON =================
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.8, end: 1),
                    duration: const Duration(milliseconds: 550),
                    curve: Curves.elasticOut,
                    builder: (_, double scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'To reset logs: delete the database file or add a clear action.'),
                                ),
                              );
                            },
                            child: const Text(
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

// ---------- PARTICLES ----------
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
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
