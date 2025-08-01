import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'result_screen.dart';

class CompetitionScreen extends StatefulWidget {
  @override
  _CompetitionScreenState createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  bool gameStarted = false;
  bool isEliminated = false;
  bool userJoined = false;
  int countdown = 10;
  int durationSeconds = 0;
  int activePlayers = 50;
  int rewardCoins = 250000; // Ödül Havuzu (örnek)
  Offset fingerPosition = Offset(-100, -100);
  Offset? targetPosition;
  bool showTarget = false;
  int targetCountdown = 5;
  Timer? gameTimer;
  Timer? playerReduceTimer;
  Timer? targetTimer;
  Random random = Random();
  final AudioPlayer audioPlayer = AudioPlayer();
  AnimationController? _animController;
  AnimationController? targetAnimController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      lowerBound: 0.8,
      upperBound: 1.2,
    );

    targetAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showRulesDialog();
    });

    startCountdown();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    gameTimer?.cancel();
    playerReduceTimer?.cancel();
    targetTimer?.cancel();
    _animController?.dispose();
    targetAnimController?.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> playSound(String file) async {
    await audioPlayer.play(AssetSource('sounds/$file'));
  }

  void showRulesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("Kurallar"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("• Parmağınızı alttaki alana koyun ve asla kaldırmayın."),
            Text("• 2. parmak koymak diskalifiye sebebidir."),
            Text("• Hedef çıkarsa parmağınızı sürükleyin."),
            SizedBox(height: 12),
            Row(
              children: [
                Image.asset("assets/images/coin.png", width: 30),
                SizedBox(width: 8),
                Text("Ödül: $rewardCoins Coin"),
              ],
            ),
            SizedBox(height: 8),
            Text("Katılım Ücreti: 100 Coin"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Tamam"),
          ),
        ],
      ),
    );
  }

  void startCountdown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown == 0) {
        playSound('start_bell.mp3');
        setState(() => gameStarted = true);
        timer.cancel();
        startGame();
      } else {
        playSound('countdown_beep.mp3');
        setState(() => countdown--);
      }
    });
  }

  void startGame() {
    if (!userJoined) {
      eliminatePlayer("Zamanında katılmadın");
      return;
    }

    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() => durationSeconds++);
    });

    playerReduceTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (activePlayers > 1) {
        setState(() => activePlayers -= 1 + (activePlayers > 10 ? 2 : 0));
      } else {
        timer.cancel();
      }
    });

    scheduleNextTarget();
  }

  void scheduleNextTarget() {
    if (isEliminated) return;
    Future.delayed(Duration(seconds: 5 + random.nextInt(5)), () {
      if (!isEliminated && gameStarted && !showTarget) {
        showNewTarget();
      }
    });
  }

  void showNewTarget() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double x = random.nextDouble() * (screenWidth * 0.7) + screenWidth * 0.15;
    double y = random.nextDouble() * (screenHeight * 0.6) + screenHeight * 0.2;

    setState(() {
      targetPosition = Offset(x, y);
      showTarget = true;
      targetCountdown = 5;
    });

    playSound('target_ding.mp3');
    targetAnimController?.forward(from: 0);

    targetTimer?.cancel();
    targetTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (targetCountdown == 0) {
        timer.cancel();
        if (showTarget) eliminatePlayer("Görev başarısız");
      } else {
        setState(() => targetCountdown--);
      }
    });
  }

  void checkTargetReached() {
    if (targetPosition != null) {
      double dx = (fingerPosition.dx - targetPosition!.dx).abs();
      double dy = (fingerPosition.dy - targetPosition!.dy).abs();

      if (dx < 50 && dy < 50) {
        setState(() {
          showTarget = false;
          targetPosition = null;
        });
        targetTimer?.cancel();
        scheduleNextTarget();
      }
    }
  }

  void eliminatePlayer(String reason) {
    playSound('fail_buzzer.mp3');
    setState(() => isEliminated = true);
    gameTimer?.cancel();
    playerReduceTimer?.cancel();
    targetTimer?.cancel();
    navigateToResult();
  }

  void navigateToResult() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ResultScreen(duration: durationSeconds, eliminated: isEliminated),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && gameStarted) {
      eliminatePlayer("Uygulama arka plana geçti");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.blue.shade100, Colors.blue.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
          ),
          child: Column(
            children: [
              // Üst bilgi kutusu
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 6)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Süre: $durationSeconds sn",
                          style: TextStyle(fontSize: 18)),
                      Text("Aktif Oyuncular: $activePlayers",
                          style: TextStyle(fontSize: 18)),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Image.asset("assets/images/coin.png", width: 28),
                          SizedBox(width: 6),
                          Text("Ödül: $rewardCoins Coin",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              Expanded(
                child: Container(
                  margin: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.lightBlueAccent]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 8)
                    ],
                  ),
                  child: GestureDetector(
                    onScaleStart: (details) {
                      if (isEliminated) return;
                      if (details.pointerCount > 1) {
                        eliminatePlayer("Başka parmak algılandı");
                        return;
                      }
                      if (!gameStarted && countdown == 0) {
                        eliminatePlayer("Zamanında katılmadın");
                        return;
                      }
                      userJoined = true;
                      fingerPosition = details.focalPoint;
                      _animController?.forward();
                    },
                    onScaleUpdate: (details) {
                      if (isEliminated || !userJoined) return;
                      if (details.pointerCount > 1) {
                        eliminatePlayer("Başka parmak algılandı");
                        return;
                      }
                      setState(() => fingerPosition = details.focalPoint);
                      checkTargetReached();
                    },
                    onScaleEnd: (_) {
                      if (!isEliminated && userJoined) {
                        eliminatePlayer("Parmağı kaldırdın");
                      }
                    },
                    child: Stack(
                      children: [
                        if (!gameStarted)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("$countdown",
                                    style: TextStyle(
                                        fontSize: 80,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                SizedBox(height: 12),
                                Text("Parmağınızı alttaki alana koyun ve basılı tutun!",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        if (gameStarted && showTarget && targetPosition != null)
                          Positioned(
                            left: targetPosition!.dx - 40,
                            top: targetPosition!.dy - 40,
                            child: FadeTransition(
                              opacity: targetAnimController!,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 3),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("$targetCountdown",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                    Text("Sürükle",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14))
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
