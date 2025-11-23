import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/subject_tile.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
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
              color: Colors.purpleAccent.withOpacity(
                  0.2 + _random.nextDouble() * 0.3), // subtle colors
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Study Buddy'),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.history, color: Colors.deepPurple),
              title: Text('History'),
              onTap: () => Navigator.pushNamed(context, '/history'),
            ),
            ListTile(
              leading: Icon(Icons.show_chart, color: Colors.deepPurple),
              title: Text('Progress'),
              onTap: () => Navigator.pushNamed(context, '/progress'),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.deepPurple),
              title: Text('Settings'),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background particles
          CustomPaint(
            size: Size.infinite,
            painter: ParticlePainter(_particles),
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Select Subject',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/add-subject'),
                      child: Text('Add Subject'),
                    )
                  ],
                ),
              ),
              Expanded(
                child: prov.subjects.isEmpty
                    ? Center(
                        child: Text(
                          'No subjects yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: prov.subjects.length,
                        itemBuilder: (_, i) {
                          return TweenAnimationBuilder(
                            tween: Tween<Offset>(
                                begin: Offset(1, 0), end: Offset(0, 0)),
                            duration: Duration(milliseconds: 400 + (i * 100)),
                            curve: Curves.easeOut,
                            builder: (context, Offset offset, child) {
                              return Transform.translate(
                                offset:
                                    offset * MediaQuery.of(context).size.width,
                                child: Opacity(
                                  opacity: 1 - offset.dx,
                                  child: Card(
                                    elevation: 4,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {},
                                      child: SubjectTile(
                                          subject: prov.subjects[i]),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              )
            ],
          ),
        ],
      ),
      floatingActionButton: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.8, end: 1.0),
        duration: Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, double scale, child) {
          return Transform.scale(
            scale: scale,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.deepPurple,
              label: Text('Start Session'),
              icon: Icon(Icons.timer),
              onPressed: () => Navigator.pushNamed(context, '/pomodoro'),
            ),
          );
        },
      ),
    );
  }
}

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
