import 'package:flutter/material.dart';
import 'dart:async';
import 'result_screen.dart';

class CompetitionScreen extends StatefulWidget {
  @override
  _CompetitionScreenState createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  bool gameStarted = false;
  bool isHolding = false;
  bool isEliminated = false;
  int countdown = 3;
  int durationSeconds = 0;
  int activePlayers = 50; // Simülasyon
  Timer? durationTimer;
  Timer? playerReduceTimer;
  AnimationController? _animController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      lowerBound: 1.0,
      upperBound: 1.2,
    );

    startCountdown();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    durationTimer?.cancel();
    playerReduceTimer?.cancel();
    _animController?.dispose();
    super.dispose();
  }

  void startCountdown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown == 0) {
        setState(() {
          gameStarted = true;
        });
        timer.cancel();
        startPlayerSimulation();
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  void startPlayerSimulation() {
    playerReduceTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (activePlayers > 1) {
        setState(() {
          activePlayers -= 1 + (activePlayers > 10 ? 2 : 0);
        });
      } else {
        timer.cancel();
      }
    });
  }

  void onHoldStart() {
    if (!gameStarted || isEliminated) return;
    setState(() {
      isHolding = true;
    });
    _animController?.forward();
    durationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        durationSeconds++;
      });
    });
  }

  void onHoldEnd() {
    if (!gameStarted || isEliminated) return;
    setState(() {
      isHolding = false;
      isEliminated = true;
    });
    _animController?.reverse();
    durationTimer?.cancel();
    navigateToResult();
  }

  void navigateToResult() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(duration: durationSeconds, eliminated: isEliminated)),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && isHolding) {
      setState(() {
        isEliminated = true;
      });
      durationTimer?.cancel();
      navigateToResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Yarışma")),
      body: Center(
        child: gameStarted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Süre: $durationSeconds sn", style: TextStyle(fontSize: 22)),
                  Text("Aktif Oyuncular: $activePlayers", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 40),
                  GestureDetector(
                    onLongPressStart: (_) => onHoldStart(),
                    onLongPressEnd: (_) => onHoldEnd(),
                    child: ScaleTransition(
                      scale: _animController!,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                        child: Center(
                          child: Text("BASILI TUT", style: TextStyle(color: Colors.white, fontSize: 20)),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                "$countdown",
                style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
