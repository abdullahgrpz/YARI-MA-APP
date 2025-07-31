import 'package:flutter/material.dart';
import 'competition_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ana Sayfa")),
      body: Center(
        child: ElevatedButton(
          child: Text("Yarışmaya Katıl"),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CompetitionScreen()));
          },
        ),
      ),
    );
  }
}
