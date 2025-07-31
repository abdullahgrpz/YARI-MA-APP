import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final int duration;
  final bool eliminated;
  ResultScreen({required this.duration, required this.eliminated});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sonuç")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            eliminated
                ? Text("Diskalifiye Oldunuz!", style: TextStyle(fontSize: 24, color: Colors.red))
                : Text("Süreniz: $duration saniye", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Tekrar Oyna"),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            )
          ],
        ),
      ),
    );
  }
}
