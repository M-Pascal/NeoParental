import 'package:flutter/material.dart';

void main() {
  runApp(const InitialPage());
}

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFA51200),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to NeoParental',
              ),
              Image.asset('assets/image_01.jpg'),
              const SizedBox(height: 20),
              const Text(
                  'A mobile application system that helps improve parental care for infants through intelligent monitoring and guidance.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the next page
                },
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
