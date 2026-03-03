import 'dart:async';
import 'package:flutter/material.dart';
import 'analysis_result_page.dart';

class AnalysisLoadingPage extends StatefulWidget {
  const AnalysisLoadingPage({super.key});

  @override
  State<AnalysisLoadingPage> createState() => _AnalysisLoadingPageState();
}

class _AnalysisLoadingPageState extends State<AnalysisLoadingPage> {

  double progress = 0;
  int step = 0;

  @override
  void initState() {
    super.initState();
    startFakeProcess();
  }

  void startFakeProcess() async {

    /// Step 1 → Uploading
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      progress = 0.25;
      step = 1;
    });

    /// Step 2 → Detecting Pose
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      progress = 0.50;
      step = 2;
    });

    /// Step 3 → Analyzing Angles
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      progress = 0.75;
      step = 3;
    });

    /// Step 4 → Generating Feedback
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      progress = 1;
      step = 4;
    });

    /// Navigate to result
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AnalysisResultPage(),
      ),
    );
  }

  Widget buildStep(String text, int index) {
    bool completed = step >= index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                completed ? Colors.green : Colors.grey.shade300,
            child: completed
                ? const Icon(Icons.check, color: Colors.white)
                : Text("$index"),
          ),
          const SizedBox(width: 16),
          Text(text),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int percent = (progress * 100).toInt();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [

            const SizedBox(height: 60),

            const CircularProgressIndicator(),

            const SizedBox(height: 30),

            const Text(
              "Analyzing Your Posture",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text("$percent% Complete"),

            const SizedBox(height: 30),

            LinearProgressIndicator(value: progress),

            const SizedBox(height: 40),

            buildStep("Uploading video", 1),
            buildStep("Detecting pose", 2),
            buildStep("Analyzing angles", 3),
            buildStep("Generating feedback", 4),
          ],
        ),
      ),
    );
  }
}
