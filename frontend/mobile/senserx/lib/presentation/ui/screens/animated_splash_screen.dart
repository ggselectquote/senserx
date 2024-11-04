import 'package:senserx/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class AnimatedSplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const AnimatedSplashScreen({super.key, required this.nextScreen});

  @override
  _AnimatedSplashScreenState createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _controller2 = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _controller3 = AnimationController(vsync: this, duration: const Duration(seconds: 5));

    _controller1.addStatusListener(_checkAndNavigate);
    _controller2.addStatusListener(_checkAndNavigate);
    _controller3.addStatusListener(_checkAndNavigate);

    _controller1.forward();
    Future.delayed(const Duration(milliseconds: 500), () => _controller2.forward());
    Future.delayed(const Duration(seconds: 1), () => _controller3.forward());
  }

  void _checkAndNavigate(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        _controller1.isCompleted &&
        _controller2.isCompleted &&
        _controller3.isCompleted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => widget.nextScreen),
      );
    }
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.themeData.primaryColor,
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: MediaQuery.of(context).size.width * 0.1,
            child: Lottie.asset(
              'assets/animations/splash.json',
              controller: _controller1,
              width: 100,
              height: 100,
              onLoaded: (composition) {
                FlutterNativeSplash.remove();
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: MediaQuery.of(context).size.width * 0.4,
            child: Lottie.asset(
              'assets/animations/splash.json',
              controller: _controller2,
              width: 120,
              height: 120,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.32,
            right: MediaQuery.of(context).size.width * 0.1,
            child: Lottie.asset(
              'assets/animations/splash.json',
              controller: _controller3,
              width: 80,
              height: 80,
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'SenseRx',
                style: AppTheme.themeData.textTheme.displayLarge?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}