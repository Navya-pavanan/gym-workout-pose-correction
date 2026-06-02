import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  final int score;
  final int confidence;

  const ScoreCard({
    super.key,
    required this.score,
    required this.confidence,
  });

  String get _label {
    if (score >= 70) return "Good";
    if (score >= 40) return "Average";
    return "Bad";
  }

  Color get _color {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  IconData get _icon {
    if (score >= 70) return Icons.check_circle;
    if (score >= 40) return Icons.warning;
    return Icons.cancel;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [

          Text(
            score.toString(),
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: _color,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "$score / 100",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_icon, size: 16, color: _color),
                const SizedBox(width: 6),
                Text(
                  _label,
                  style: TextStyle(
                    color: _color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Confidence"),
              Text(
                "$confidence%",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}