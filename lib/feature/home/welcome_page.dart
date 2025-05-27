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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _startGame(context, 'easy'),
              child: const Text("Easy (8x8, 10 mines)"),
            ),
            ElevatedButton(
              onPressed: () => _startGame(context, 'medium'),
              child: const Text("Medium (12x8, 20 mines)"),
            ),
            ElevatedButton(
              onPressed: () => _startGame(context, 'hard'),
              child: const Text("Hard (16x10, 30 mines)"),
            ),
          ],
        ),
      ),
    );
  }
}
