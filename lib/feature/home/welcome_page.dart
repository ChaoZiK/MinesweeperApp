import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minesweeperapp/core/route/app_route_name.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void _startGame(BuildContext context, String difficulty) {
    context.pushNamed(AppRouteName.home, extra: difficulty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "🎮 Game Mode",
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _startGame(context, 'easy'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: TextStyle(fontSize: 20),
              ),
              child: const Text("Easy (8x8, 10 mines)"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _startGame(context, 'medium'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: TextStyle(fontSize: 20),
              ),
              child: const Text("Medium (12x8, 20 mines)"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _startGame(context, 'hard'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: TextStyle(fontSize: 20),
              ),
              child: const Text("Hard (16x10, 30 mines)"),
            ),
          ],
        ),
      ),
    );
  }
}
