import 'package:flutter/material.dart';
import 'upload_vedio.dart';
import 'instruction_video_page.dart';

class SelectExercisePage extends StatefulWidget {
  const SelectExercisePage({super.key});

  @override
  State<SelectExercisePage> createState() => _SelectExercisePageState();
}

class _SelectExercisePageState extends State<SelectExercisePage> {

  /// 👉 Track selected exercise
  String? selectedExercise;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: Column(
        children: [

          /// 🔹 HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE6F0FF),
                  Color(0xFFE8FAF4),
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select Your Exercise",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Choose the workout you want to analyze",
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// 🔹 SQUAT CARD
          GestureDetector(
            onTap: () {
              setState(() {
                selectedExercise = "squat";
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selectedExercise == "squat"
                    ? Colors.blue.shade50
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selectedExercise == "squat"
                      ? Colors.blue
                      : Colors.grey.shade300,
                  width: selectedExercise == "squat" ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.fitness_center,
                        color: Colors.blue),
                  ),
                  const SizedBox(width: 16),

                  /// TEXT COLUMN
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Squat",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text("Lower body strength"),
                    ],
                  ),

                  const Spacer(),

                  /// RADIO STYLE INDICATOR
                  Icon(
                    selectedExercise == "squat"
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          /// 🔹 CONTINUE BUTTON
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedExercise == null
                    ? null   /// ❌ Disabled
                    : () {   /// ✅ Enabled → Navigate
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InstructionVideoPage(
                              exerciseName: selectedExercise!,
                            ),
                          ),
                        );
                      },

                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedExercise == null
                      ? Colors.grey
                      : Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),

                child: const Text("Continue"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


