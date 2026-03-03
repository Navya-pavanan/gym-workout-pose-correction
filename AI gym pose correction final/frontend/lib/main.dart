import 'package:flutter/material.dart';
import 'select_exercise.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      
      debugShowCheckedModeBanner: false,
      home: AIWorkoutCoachUI(),
    );
  }
}

class AIWorkoutCoachUI extends StatelessWidget {
  const AIWorkoutCoachUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 🌈 Full screen gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFBFD7FF),
              Color(0xFF9FE6D8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              /// 🔹 HEADER SECTION
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: const [
                    Icon(
                      Icons.psychology,
                      size: 70,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "AI Workout Coach",
                      style: TextStyle(
                        fontSize: 26,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Improve your form. Train smarter.",
                      style: TextStyle(fontSize: 14,fontFamily: 'Roboto'),
                    ),
                  ],
                ),
              ),

              /// 🔹 HOW IT WORKS SECTION
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "How it works",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto'
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),

              /// 🔹 STEP 1
              buildStepCard(
                icon: Icons.upload,
                title: "Step 1: Upload Video",
                subtitle: "Record or upload your workout",
              ),

              /// 🔹 STEP 2
              buildStepCard(
                icon: Icons.analytics,
                title: "Step 2: AI Analysis",
                subtitle: "Pose & angle evaluation",
              ),

              /// 🔹 STEP 3
              buildStepCard(
                icon: Icons.check_circle,
                title: "Step 3: Get Feedback",
                subtitle: "Score, tips & visual guidance",
              ),

              const Spacer(),

              /// 🔹 BUTTON SECTION
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                 onPressed: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SelectExercisePage(),
                      ),
                        );
                      },
                  child: const Text(
                    "Get Started",
                    style: TextStyle(fontSize: 16,
                    fontFamily: 'Roboto'),
                  ),
                ),
              ),

              /// 🔹 FOOTER
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  "Version 1.0.0",
                  style: TextStyle(fontSize: 12,
                  fontFamily: 'Roboto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🔹 REUSABLE STEP CARD CONTAINER
Widget buildStepCard({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto'
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12,fontFamily: 'Roboto'),
            ),
          ],
        ),
      ],
    ),
  );
}