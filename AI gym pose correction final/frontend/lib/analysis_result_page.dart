import 'package:flutter/material.dart';
import 'main.dart';
import 'widgets/score_card.dart';
import 'widgets/action_card.dart';
import 'widgets/summary_card.dart';
import 'upload_vedio.dart';

class AnalysisResultPage extends StatefulWidget {
  final Map<String, dynamic> result;
  final String exerciseType;

  const AnalysisResultPage({
    super.key,
    required this.result,
    required this.exerciseType,
  });

  @override
  State<AnalysisResultPage> createState() => _AnalysisResultPageState();
}

class _AnalysisResultPageState extends State<AnalysisResultPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final int overallScore = (widget.result['overall_score'] ?? 0).toInt();
    final int standingScore = (widget.result['standing_score'] ?? 0).toInt();
    final int squattingScore = (widget.result['squatting_score'] ?? 0).toInt();
    final double depthAchieved =
        (widget.result['depth_achieved'] ?? 0).toDouble();

    final Map<String, dynamic> feedback = widget.result['feedback'] ?? {};
    final List<dynamic> standingFeedback = feedback['standing_phase'] ?? [];
    final List<dynamic> squattingFeedback = feedback['squatting_phase'] ?? [];

    final Map<String, dynamic> stats = widget.result['statistics'] ?? {};
    final Map<String, dynamic> movement =
        widget.result['movement_quality'] ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() => selectedIndex = index);
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AIWorkoutCoachUI()),
              (route) => false,
            );
          }
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    UploadVideoPage(exerciseType: widget.exerciseType),
              ),
            );
          }
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_outlined),
            activeIcon: Icon(Icons.upload),
            label: "Upload",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: "History",
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── HEADER ──────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE6F0FF), Color(0xFFE8FAF4)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Analysis Complete",
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text("Exercise: ${widget.exerciseType.toUpperCase()}"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── SCORE CARD ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ScoreCard(
                  score: overallScore,
                  confidence: squattingScore,
                ),
              ),

              const SizedBox(height: 16),

              // ── PHASE SCORES ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _PhaseScoreCard(
                        label: "Standing",
                        score: standingScore,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PhaseScoreCard(
                        label: "Squatting",
                        score: squattingScore,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── VIEW DETAILS LABEL ───────────────────────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "View Details",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── ACTION CARDS ─────────────────────────────────────────────
              ActionCard(
                icon: Icons.remove_red_eye_outlined,
                title: "Posture Visualization",
                subtitle: "See annotated skeleton overlay",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostureVisualizationScreen(
                        images: widget.result['images'] ?? {},
                      ),
                    ),
                  );
                },
              ),

              ActionCard(
                icon: Icons.chat_bubble_outline,
                title: "Personalized Feedback",
                subtitle: "Get specific improvement tips",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FeedbackScreen(
                        standingFeedback: standingFeedback,
                        squattingFeedback: squattingFeedback,
                        overallScore: overallScore,
                      ),
                    ),
                  );
                },
              ),

              ActionCard(
                icon: Icons.show_chart,
                title: "Movement Breakdown",
                subtitle: "How well your body moved",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JointAnalysisScreen(
                        movement: movement,
                        stats: stats,
                        depthAchieved: depthAchieved,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ── QUICK SUMMARY ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SummaryCard(
                  totalFrames: stats['total_frames'] ?? 0,
                  squatFrames: stats['squat_frames'] ?? 0,
                  correctFrames: stats['correct_squat_frames'] ?? 0,
                  depthAchieved: depthAchieved,
                ),
              ),

              const SizedBox(height: 20),

              // ── BUTTONS ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Try Another"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text("View History"),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phase Score Card
// ─────────────────────────────────────────────────────────────────────────────
class _PhaseScoreCard extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const _PhaseScoreCard({
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            "$score%",
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Posture Visualization Screen
// ─────────────────────────────────────────────────────────────────────────────
class PostureVisualizationScreen extends StatelessWidget {
  final Map<String, dynamic> images;

  const PostureVisualizationScreen({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    const String baseUrl = 'http://172.31.98.152:5000';
    final String? standingImg = images['standing_image'];
    final String? squattingImg = images['squatting_image'];

    return Scaffold(
      appBar: AppBar(title: const Text("Posture Visualization")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Standing Phase",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            if (standingImg != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network('$baseUrl/$standingImg'),
              )
            else
              const Text("No standing image available"),
            const SizedBox(height: 24),
            const Text("Squatting Phase",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            if (squattingImg != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network('$baseUrl/$squattingImg'),
              )
            else
              const Text("No squatting image available"),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Converts a raw snake_case feedback key into a friendly sentence.
String _humanise(String raw) {
  raw = raw.trim().replaceAll(RegExp(r'^["\[{]+|["\]}]+$'), '').trim();

  const Map<String, String> _phrases = {
    'knee_not_straight':
        'Try to fully straighten your knees when standing up.',
    'knees_not_straight':
        'Try to fully straighten your knees when standing up.',
    'back_not_upright':
        'Keep your back tall and straight while standing.',
    'poor_vertical_alignment':
        'Stand so your shoulders, hips, and ankles line up in a straight column.',
    'vertical_alignment_issue':
        'Stand so your shoulders, hips, and ankles line up in a straight column.',
    'knee_angle_too_high':
        'Try to squat a little deeper — aim for thighs parallel to the floor.',
    'knee_angle_too_low':
        'You are squatting very deep — aim for a 90° bend to protect your joints.',
    'back_angle_too_upright':
        'A slight forward lean is normal and healthy during a squat.',
    'back_angle_too_forward':
        'Keep your chest up and avoid leaning too far forward.',
    'knee_forward_travel_too_large':
        'Try to stop your knees from going too far past your toes.',
    'insufficient_depth':
        'Go a little lower — aim for thighs parallel to the ground.',
    'depth_too_shallow':
        'Go a little lower — aim for thighs parallel to the ground.',
    'good_form': 'Great form on this phase — keep it up!',
    'no_issues': 'No issues here. Excellent work!',
  };

  final String key = raw.toLowerCase().replaceAll(' ', '_');
  if (_phrases.containsKey(key)) return _phrases[key]!;
  for (final entry in _phrases.entries) {
    if (key.contains(entry.key)) return entry.value;
  }

  final prettified = raw.replaceAll('_', ' ').replaceAll('-', ' ').trim();
  if (prettified.isEmpty) return raw;
  return '${prettified[0].toUpperCase()}${prettified.substring(1)}.';
}

/// Returns star count (1–5) for a 0–100 score.
int _stars(int score) => (score / 20).ceil().clamp(1, 5);

/// Returns an emoji for a score.
String _scoreEmoji(int score) {
  if (score >= 85) return '🏆';
  if (score >= 70) return '💪';
  if (score >= 55) return '👍';
  if (score >= 40) return '🙂';
  return '🔄';
}

/// Builds a row of filled/empty star icons.
Widget _starRow(int score, Color color) {
  final int filled = _stars(score);
  return Row(
    children: List.generate(5, (i) {
      return Icon(
        i < filled ? Icons.star_rounded : Icons.star_outline_rounded,
        color: i < filled ? color : Colors.grey.shade300,
        size: 20,
      );
    }),
  );
}

/// Builds a labeled progress bar.
Widget _progressBar(String label, double value, Color color,
    {String? hint, String? tag}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            if (tag != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(tag,
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        if (hint != null) ...[
          const SizedBox(height: 2),
          Text(hint,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Feedback Screen
// ─────────────────────────────────────────────────────────────────────────────
class _FeedbackMeta {
  final IconData icon;
  final Color iconColor;
  final Color background;
  const _FeedbackMeta(this.icon, this.iconColor, this.background);
}

class FeedbackScreen extends StatelessWidget {
  final List<dynamic> standingFeedback;
  final List<dynamic> squattingFeedback;
  final int overallScore;

  const FeedbackScreen({
    super.key,
    required this.standingFeedback,
    required this.squattingFeedback,
    required this.overallScore,
  });

  _FeedbackMeta _meta(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('great') ||
        lower.contains('excellent') ||
        lower.contains('keep it up') ||
        lower.contains('no issue')) {
      return _FeedbackMeta(Icons.check_circle_rounded,
          const Color(0xFF22C55E), const Color(0xFFDCFCE7));
    }
    if (lower.contains('too far') ||
        lower.contains('too deep') ||
        lower.contains('leaning too')) {
      return _FeedbackMeta(Icons.warning_amber_rounded,
          const Color(0xFFEF4444), const Color(0xFFFEE2E2));
    }
    return _FeedbackMeta(Icons.tips_and_updates_outlined,
        const Color(0xFFF59E0B), const Color(0xFFFEF9C3));
  }

  /// Short motivational tip to show below each feedback message.
  String _tip(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('knee') && lower.contains('straight'))
      return '💡 Tip: Push your hips back slightly as you stand to help straighten the knee.';
    if (lower.contains('chest') || lower.contains('forward lean'))
      return '💡 Tip: Look straight ahead and imagine balancing a book on your head.';
    if (lower.contains('deeper') || lower.contains('lower'))
      return '💡 Tip: Try box squats — sit onto a low chair to build depth gradually.';
    if (lower.contains('toes'))
      return '💡 Tip: Widen your stance slightly and point your toes outward a little.';
    if (lower.contains('straight') || lower.contains('align'))
      return '💡 Tip: Stand against a wall to practise perfect upright posture.';
    if (lower.contains('great') || lower.contains('excellent'))
      return '🎉 Keep filming yourself to maintain this great form!';
    return '💡 Tip: Small, consistent improvements add up over time — keep going!';
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }

  Widget _feedbackTile(String raw) {
    final message = _humanise(raw);
    final meta = _meta(message);
    final tip = _tip(message);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: meta.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: meta.iconColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(meta.icon, color: meta.iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(message,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.5)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Motivational tip
          Text(tip,
              style: TextStyle(
                  fontSize: 13,
                  color: meta.iconColor.withOpacity(0.85),
                  height: 1.4)),
        ],
      ),
    );
  }

  Widget _scoreChip(int score) {
    Color color;
    String label;
    if (score >= 80) {
      color = const Color(0xFF22C55E);
      label = 'Excellent';
    } else if (score >= 60) {
      color = const Color(0xFFF59E0B);
      label = 'Good';
    } else {
      color = const Color(0xFFEF4444);
      label = 'Needs Work';
    }
    return Row(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Text(
            '$score% — $label  ${_scoreEmoji(score)}',
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool allClear =
        standingFeedback.isEmpty && squattingFeedback.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Personalized Feedback"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Score banner ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE6F0FF), Color(0xFFE8FAF4)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Your Workout Summary",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87)),
                  const SizedBox(height: 10),
                  _scoreChip(overallScore),
                  const SizedBox(height: 10),
                  _starRow(overallScore, const Color(0xFFF59E0B)),
                  const SizedBox(height: 10),
                  Text(
                    overallScore >= 80
                        ? "Solid session! You have great control over your movement."
                        : overallScore >= 60
                            ? "Good effort — a few tweaks will take you to the next level."
                            : "Keep practising — focus on the tips below to improve.",
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Perfect form ─────────────────────────────────────────────
            if (allClear)
              Center(
                child: Column(
                  children: const [
                    SizedBox(height: 20),
                    Icon(Icons.emoji_events,
                        size: 64, color: Color(0xFFF59E0B)),
                    SizedBox(height: 16),
                    Text("Perfect Form! 🎉",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      "No issues detected in either phase.\nYou nailed it — keep up the great work!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, height: 1.5),
                    ),
                  ],
                ),
              ),

            // ── Standing feedback ────────────────────────────────────────
            if (standingFeedback.isNotEmpty) ...[
              _sectionHeader(
                  "Standing Phase", Icons.accessibility_new, Colors.blue),
              ...standingFeedback
                  .map((f) => _feedbackTile(f.toString()))
                  .toList(),
              const SizedBox(height: 16),
            ],

            // ── Squatting feedback ───────────────────────────────────────
            if (squattingFeedback.isNotEmpty) ...[
              _sectionHeader(
                  "Squatting Phase", Icons.fitness_center, Colors.green),
              ...squattingFeedback
                  .map((f) => _feedbackTile(f.toString()))
                  .toList(),
              const SizedBox(height: 16),
            ],

            // ── General tip ──────────────────────────────────────────────
            if (!allClear)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.videocam_outlined,
                        color: Color(0xFF3B82F6), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "📹 Film from the side for the most accurate results next time.",
                        style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1D4ED8),
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Joint Analysis Screen  — fully user-friendly
// ─────────────────────────────────────────────────────────────────────────────

/// Converts a raw angle (degrees) into a 0–1 progress value for squat depth.
/// Good squat depth sits around 90°; we map 180° (standing) → 0 and 60° → 1.
double _depthProgress(double angleDeg) {
  // Clamp between 60° (very deep) and 180° (fully standing)
  final clamped = angleDeg.clamp(60.0, 180.0);
  // Invert: lower angle = more depth = higher bar
  return 1.0 - ((clamped - 60.0) / 120.0);
}

String _depthLabel(double angleDeg) {
  if (angleDeg <= 75) return 'Very Deep 🏆';
  if (angleDeg <= 95) return 'Great Depth 💪';
  if (angleDeg <= 115) return 'Good 👍';
  if (angleDeg <= 135) return 'Getting There 🙂';
  return 'Needs More Depth 🔄';
}

String _speedLabel(dynamic rawSpeed) {
  // rawSpeed is °/frame — completely meaningless to users, so we bucket it.
  final double s =
      (rawSpeed is num) ? rawSpeed.toDouble() : double.tryParse('$rawSpeed') ?? 0;
  if (s < 2) return 'Very Controlled 🐢';
  if (s < 4) return 'Smooth & Steady 👌';
  if (s < 7) return 'Moderate Pace 🏃';
  return 'Fast — Slow Down a Bit ⚡';
}

String _smoothnessLabel(dynamic raw) {
  // Lower smoothness value = smoother movement
  final double s =
      (raw is num) ? raw.toDouble() : double.tryParse('$raw') ?? 999;
  if (s < 1.5) return 'Very Smooth 🌊';
  if (s < 3.0) return 'Smooth 👍';
  if (s < 5.0) return 'Slightly Jerky 😬';
  return 'Jerky — Work on Control 🔄';
}

double _smoothnessProgress(dynamic raw) {
  final double s =
      (raw is num) ? raw.toDouble() : double.tryParse('$raw') ?? 10.0;
  // Invert: low value = smooth = high bar (cap at 10)
  return 1.0 - (s.clamp(0.0, 10.0) / 10.0);
}

double _speedProgress(dynamic raw) {
  final double s =
      (raw is num) ? raw.toDouble() : double.tryParse('$raw') ?? 10.0;
  // Ideal speed 2–4, cap at 10
  final ideal = s.clamp(2.0, 4.0);
  return 1.0 - ((ideal - 2.0) / 2.0); // closer to 2 = fuller bar
}

Color _progressColor(double value) {
  if (value >= 0.75) return const Color(0xFF22C55E);
  if (value >= 0.5) return const Color(0xFFF59E0B);
  return const Color(0xFFEF4444);
}

class JointAnalysisScreen extends StatelessWidget {
  final Map<String, dynamic> movement;
  final Map<String, dynamic> stats;
  final double depthAchieved;

  const JointAnalysisScreen({
    super.key,
    required this.movement,
    required this.stats,
    required this.depthAchieved,
  });

  Widget _sectionCard(String title, IconData icon, Color iconColor,
      List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87)),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── Squat depth ──────────────────────────────────────────────────────────
    final double depthProg = _depthProgress(depthAchieved);
    final String depthTag = _depthLabel(depthAchieved);
    final Color depthColor = _progressColor(depthProg);

    // ── Movement speed ───────────────────────────────────────────────────────
    final dynamic rawSpeed = movement['avg_speed'];
    final String speedTag = _speedLabel(rawSpeed);
    final double speedProg = _speedProgress(rawSpeed);
    final Color speedColor = _progressColor(speedProg);

    // ── Smoothness ───────────────────────────────────────────────────────────
    final dynamic rawSmooth = movement['smoothness'];
    final String smoothTag = _smoothnessLabel(rawSmooth);
    final double smoothProg = _smoothnessProgress(rawSmooth);
    final Color smoothColor = _progressColor(smoothProg);

    // ── Correct squat % ──────────────────────────────────────────────────────
    final int squat = (stats['squat_frames'] ?? 1) as int;
    final int correct = (stats['correct_squat_frames'] ?? 0) as int;
    final double correctRatio = squat > 0 ? correct / squat : 0.0;
    final int correctPct = (correctRatio * 100).round();
    final Color correctColor = _progressColor(correctRatio);

    // ── Descent vs ascent balance ────────────────────────────────────────────
    final int descent = (movement['descent_frames'] ?? 0) as int;
    final int ascent = (movement['ascent_frames'] ?? 0) as int;
    final int total = descent + ascent;
    final double descentRatio = total > 0 ? descent / total : 0.5;
    // Ideal: descent ≈ ascent (ratio near 0.5); we show how balanced it is
    final double balanceScore = 1.0 - (descentRatio - 0.5).abs() * 2;
    String balanceTag;
    if (balanceScore >= 0.8)
      balanceTag = 'Well Balanced ⚖️';
    else if (descentRatio > 0.6)
      balanceTag = 'Going Down Too Slowly 🐌';
    else
      balanceTag = 'Coming Up Too Slowly 🐌';
    final Color balanceColor = _progressColor(balanceScore);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Movement Breakdown"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── How Deep Did You Squat? ──────────────────────────────────
            _sectionCard(
              "How Deep Did You Squat?",
              Icons.fitness_center,
              Colors.green,
              [
                _progressBar(
                  "Squat Depth",
                  depthProg,
                  depthColor,
                  hint:
                      "Deeper squats (thighs parallel to floor) give better results.",
                  tag: depthTag,
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: depthColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    depthAchieved <= 95
                        ? "✅ You reached a good squat depth. Keep it consistent!"
                        : depthAchieved <= 120
                            ? "👇 Try squatting a little lower — aim for thighs parallel to the ground."
                            : "👇 Your squat is quite shallow. Try box squats to gradually build depth.",
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),

            // ── How Well Did You Move? ───────────────────────────────────
            _sectionCard(
              "How Well Did You Move?",
              Icons.self_improvement,
              Colors.blue,
              [
                _progressBar(
                  "Movement Speed",
                  speedProg,
                  speedColor,
                  hint:
                      "Controlled, steady speed protects your joints and builds strength.",
                  tag: speedTag,
                ),
                _progressBar(
                  "Smoothness",
                  smoothProg,
                  smoothColor,
                  hint:
                      "Smooth movement means your muscles are working evenly.",
                  tag: smoothTag,
                ),
                _progressBar(
                  "Up/Down Balance",
                  balanceScore,
                  balanceColor,
                  hint:
                      "Going down and coming up at a similar pace is ideal.",
                  tag: balanceTag,
                ),
              ],
            ),

            // ── How Many Reps Were Correct? ──────────────────────────────
            _sectionCard(
              "Rep Quality",
              Icons.bar_chart_rounded,
              Colors.purple,
              [
                _progressBar(
                  "Correct Reps",
                  correctRatio,
                  correctColor,
                  hint:
                      "Percentage of your squat movements that had good form.",
                  tag: "$correctPct% Correct",
                ),
                const SizedBox(height: 4),
                Text(
                  correctPct >= 80
                      ? "🏆 Most of your reps were on point — great consistency!"
                      : correctPct >= 50
                          ? "👍 Over half your reps were correct. A little more focus will get you to 80%+."
                          : "🔄 Work on the tips in Personalized Feedback and retry — you'll improve fast!",
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black54, height: 1.5),
                ),
              ],
            ),

            // ── Overall stars ────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE6F0FF), Color(0xFFE8FAF4)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text("Overall Movement Rating",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  _starRow(correctPct, const Color(0xFFF59E0B)),
                  const SizedBox(height: 8),
                  Text(
                    "${_scoreEmoji(correctPct)}  Keep working on it — every session counts!",
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}