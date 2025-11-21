import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/animations/page_transitions.dart';


class AnimationTestPage extends StatelessWidget {
  const AnimationTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animation Test'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Test Page Transitions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 40),
            
            _buildAnimationButton(
              'Slide Right',
              () => AnimatedGet.toWithSlideRight(const TestDestinationPage(title: 'Slide Right')),
              Colors.blue,
            ),
            
            _buildAnimationButton(
              'Slide Up',
              () => AnimatedGet.toWithSlideUp(const TestDestinationPage(title: 'Slide Up')),
              Colors.green,
            ),
            
            _buildAnimationButton(
              'Fade In',
              () => AnimatedGet.toWithFade(const TestDestinationPage(title: 'Fade In')),
              Colors.purple,
            ),
            
            _buildAnimationButton(
              'Scale',
              () => AnimatedGet.toWithScale(const TestDestinationPage(title: 'Scale')),
              Colors.orange,
            ),
            
            _buildAnimationButton(
              'Professional Curve',
              () => AnimatedGet.toWithCurve(const TestDestinationPage(title: 'Professional Curve')),
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationButton(String title, VoidCallback onPressed, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class TestDestinationPage extends StatelessWidget {
  final String title;

  const TestDestinationPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              '$title Animation',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Animation completed successfully!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Go Back',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}