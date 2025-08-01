import 'package:flutter/material.dart';
import 'dart:async';

class SpectatorScreen extends StatefulWidget {
  @override
  _SpectatorScreenState createState() => _SpectatorScreenState();
}

class _SpectatorScreenState extends State<SpectatorScreen> {
  int activePlayers = 50;
  int durationSeconds = 0;
  Timer? timer;
  String? selectedReason;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        durationSeconds++;
        if (activePlayers > 1) {
          activePlayers -= 1;
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void submitSurvey() {
    if (selectedReason != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Teşekkürler! Cevabınız: $selectedReason")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Yarışmayı İzle")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Aktif Oyuncular: $activePlayers", style: TextStyle(fontSize: 20)),
            Text("Geçen Süre: $durationSeconds sn", style: TextStyle(fontSize: 18)),
            SizedBox(height: 30),
            Text("Anket: Neden elendiniz?", style: TextStyle(fontSize: 18)),
            RadioListTile<String>(
              title: Text("Parmağı kaldırdım"),
              value: "Parmağı kaldırdım",
              groupValue: selectedReason,
              onChanged: (val) => setState(() => selectedReason = val),
            ),
            RadioListTile<String>(
              title: Text("Görevi kaçırdım"),
              value: "Görevi kaçırdım",
              groupValue: selectedReason,
              onChanged: (val) => setState(() => selectedReason = val),
            ),
            RadioListTile<String>(
              title: Text("Diğer"),
              value: "Diğer",
              groupValue: selectedReason,
              onChanged: (val) => setState(() => selectedReason = val),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitSurvey,
              child: Text("Gönder"),
            ),
          ],
        ),
      ),
    );
  }
}
