import 'package:flutter/material.dart';
import 'main.dart';
import 'widgets/score_card.dart';
import 'widgets/action_card.dart';
import 'widgets/summary_card.dart';
import 'upload_vedio.dart';

class AnalysisResultPage extends StatefulWidget {
  const AnalysisResultPage({super.key});

  @override
  State<AnalysisResultPage> createState() => _AnalysisResultPageState();
}

class _AnalysisResultPageState extends State<AnalysisResultPage> {
  int selectedIndex = 0;
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      /// 🔻 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
  currentIndex: selectedIndex,

  onTap: (index) {
    setState(() {
      selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const AIWorkoutCoachUI(), // ⭐ FIRST PAGE
        ),
        (route) => false,
      );
    }

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const UploadVideoPage(),
        ),
      );
    }

    if (index == 2) {
      // Future History Page
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

      
//    bottomNavigationBar: BottomNavigationBar(
//   currentIndex: selectedIndex,

//   onTap: (index) {
//     setState(() {
//       selectedIndex = index;
//     });

//     if (index == 0) {
//       Navigator.pushNamed(context, "/home");
//     }
//     if (index == 1) {
//       Navigator.pushNamed(context, "/upload");
//     }
//     if (index == 2) {
//       Navigator.pushNamed(context, "/history");
//     }
//   },

//   selectedItemColor: Colors.blue,
//   unselectedItemColor: Colors.grey,

//   items: const [
//     BottomNavigationBarItem(
//       icon: Icon(Icons.home_outlined),
//       activeIcon: Icon(Icons.home),
//       label: "Home",
//     ),

//     BottomNavigationBarItem(
//       icon: Icon(Icons.upload_outlined),
//       activeIcon: Icon(Icons.upload),
//       label: "Upload",
//     ),

//     BottomNavigationBarItem(
//       icon: Icon(Icons.history_outlined),
//       activeIcon: Icon(Icons.history),
//       label: "History",
//     ),
//   ],
// ),


      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// 🔹 HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE6F0FF), Color(0xFFE8FAF4)],
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Analysis Complete",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text("Exercise: Squat"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 SCORE CARD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ScoreCard(
                  score: 78,
                  confidence: 95,
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 VIEW DETAILS TITLE
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "View Details",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// 🔹 ACTION CARDS
              ActionCard(
                icon: Icons.remove_red_eye_outlined,
                title: "Posture Visualization",
                subtitle: "See annotated skeleton overlay",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PlaceholderScreen(
                        title: "Posture Visualization",
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
                      builder: (_) => const PlaceholderScreen(
                        title: "Personalized Feedback",
                      ),
                    ),
                  );
                },
              ),

              ActionCard(
                icon: Icons.show_chart,
                title: "Joint Analysis",
                subtitle: "Detailed angle measurements",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PlaceholderScreen(
                        title: "Joint Analysis",
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              /// 🔹 QUICK SUMMARY
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const SummaryCard(),
              ),

              const SizedBox(height: 20),

              /// 🔹 BUTTONS
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

/// 🔹 TEMP PLACEHOLDER SCREEN
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
