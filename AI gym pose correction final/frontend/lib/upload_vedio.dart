import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'analysis_loading_page.dart';

class UploadVideoPage extends StatefulWidget {
  // ✅ Accept exercise type from SelectExercisePage
  final String exerciseType;

  const UploadVideoPage({
    super.key,
    required this.exerciseType,
  });

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
            Text(
              "Upload your ${widget.exerciseType} video",
              style: const TextStyle(
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
                          : "Video selected ✅",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_videoFile != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _videoFile!.path.split('/').last,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    if (_videoFile == null) ...[
                      const SizedBox(height: 8),
                      const Text(
                        "Upload video less than 30s",
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

            /// 🔹 Analyze Button — passes video + exercise to loading page
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _videoFile == null
                    ? null
                    : () {
                        // ✅ Pass both videoFile and exerciseType to loading page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnalysisLoadingPage(
                              videoFile: _videoFile!,
                              exerciseType: widget.exerciseType,
                            ),
                          ),
                        );
                      },
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