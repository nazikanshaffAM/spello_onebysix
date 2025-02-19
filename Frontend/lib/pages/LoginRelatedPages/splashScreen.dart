// main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadAssets();
  }

  Future<void> _preloadAssets() async {
    // Preload both images
    await Future.wait([
      precacheImage(AssetImage('assets/start.png'), context),
      precacheImage(AssetImage('assets/spello.png'), context),
    ]);

    if (mounted) {
      setState(() {
        _isLoaded = true;
      });
      _initAnimation();
    }
  }

  void _initAnimation() {
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 600.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Small delay to ensure smooth start
    Future.delayed(Duration(milliseconds: 90), () {
      if (mounted) {
        _controller.forward();
      }
    });

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LogoScreen()),
        );
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
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 186, 198, 225),
      body: !_isLoaded
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _animation.value),
                  child: Center(
                    child: Image.asset(
                      'assets/astronaut.png',
                      width: 300,
                      height: 300,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class LogoScreen extends StatefulWidget {
  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainAppScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 230, 234, 237),
      body: Center(
        child: Image.asset(
          'assets/spello.png',
          width: 450,
          height: 450,
        ),
      ),
    );
  }
}

class MainAppScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'login Screen place holder',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}