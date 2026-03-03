import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'analysis_loading_page.dart';


class UploadVideoPage extends StatefulWidget {
  const UploadVideoPage({super.key});

  @override
  State<UploadVideoPage> createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {
  File? _videoFile;
  final ImagePicker _picker = ImagePicker();

  /// 📹 Pick video from gallery
  Future<void> pickVideo() async {
    final XFile? pickedVideo =
        await _picker.pickVideo(source: ImageSource.gallery);

    if (pickedVideo != null) {
      setState(() {
        _videoFile = File(pickedVideo.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Workout Video"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upload your Squat video",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            /// 🔹 Upload Area
            GestureDetector(
              onTap: pickVideo,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue),
                ),
                child: Column(
                  children: [
                    Icon(
                      _videoFile == null
                          ? Icons.video_call
                          : Icons.check_circle,
                      size: 60,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _videoFile == null
                          ? "Tap to upload from gallery"
                          : "Video selected",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_videoFile == null) ...[
                      const SizedBox(height: 8),
                      const Text(
                        "Upload video less than 30 s",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const Spacer(),

            /// 🔹 Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _videoFile == null ? null : () {
                       Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (_) => const AnalysisLoadingPage(),
                              ),
                            );
                          },

                // onPressed: _videoFile == null ? null : () {
                //   // Next: AI analysis page
                // },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Analyze Workout"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}