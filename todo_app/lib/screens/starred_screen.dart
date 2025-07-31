import 'package:flutter/material.dart';

class StarredScreen extends StatelessWidget {
  const StarredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/star_image.jpg', height: 200),
            const SizedBox(height: 20),
            const Text("No starred tasks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              "Mark important tasks with a star so that you can easily find them here",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}