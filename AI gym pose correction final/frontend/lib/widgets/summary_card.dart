import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final int totalFrames;
  final int squatFrames;
  final int correctFrames;
  final double depthAchieved;

  const SummaryCard({
    super.key,
    required this.totalFrames,
    required this.squatFrames,
    required this.correctFrames,
    required this.depthAchieved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Quick Summary",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _row("Total Frames", "$totalFrames"),
          _row("Squat Frames", "$squatFrames"),
          _row("Correct Frames", "$correctFrames"),
          _row("Depth Achieved", "${depthAchieved}°"),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}