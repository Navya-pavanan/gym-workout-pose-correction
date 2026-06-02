import 'dart:io';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'analysis_result_page.dart';

class AnalysisLoadingPage extends StatefulWidget {
  // ✅ Receive video file and exercise type from UploadVideoPage
  final File videoFile;
  final String exerciseType;

  const AnalysisLoadingPage({
    super.key,
    required this.videoFile,
    required this.exerciseType,
  });

  @override
  State<AnalysisLoadingPage> createState() => _AnalysisLoadingPageState();
}

class _AnalysisLoadingPageState extends State<AnalysisLoadingPage> {
  double progress = 0;
  int step = 0;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    startRealAnalysis(); // ✅ Call real Flask API
  }

  void startRealAnalysis() async {
    try {
      // Step 1 — Uploading
      setState(() {
        progress = 0.25;
        step = 1;
      });

      // Step 2 — Detecting Pose (UI update while API runs)
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        progress = 0.50;
        step = 2;
      });

      // ✅ REAL API CALL to Flask backend
      final result = await ApiService.analyzeVideo(
        videoFile: widget.videoFile,
        exerciseType: widget.exerciseType,
      );

      // Step 3 — Analyzing Angles
      setState(() {
        progress = 0.75;
        step = 3;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // Step 4 — Generating Feedback
      setState(() {
        progress = 1.0;
        step = 4;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // ✅ Navigate to result page with REAL data
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AnalysisResultPage(
              result: result,
              exerciseType: widget.exerciseType,
            ),
          ),
        );
      }
    } catch (e) {
      // ❌ Show error if API fails
      if (mounted) {
        setState(() {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Widget buildStep(String text, int index) {
    bool completed = step >= index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: completed ? Colors.green : Colors.grey.shade300,
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

    // ❌ Show error screen if something went wrong
    if (errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 20),
                const Text(
                  "Analysis Failed",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Go Back & Try Again"),
                ),
              ],
            ),
          ),
        ),
      );
    }

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