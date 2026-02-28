import os
import sys
import cv2
import numpy as np

# Add parent directory to path so we can import from analysis/
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from analysis.pose_estimation import get_pose_landmarks
from analysis.angle_calculation import calculate_angle

def process_video(video_path):
    """
    Process a single video and extract knee and back angles from all frames.
    """
    print(f"Processing: {video_path}")
    
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"  ❌ Could not open video: {video_path}")
        return [], []
    
    knee_angles = []
    back_angles = []
    frame_count = 0
    processed_frames = 0

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        
        frame_count += 1
        # Sample every 5th frame for efficiency
        if frame_count % 5 != 0:
            continue

        landmarks = get_pose_landmarks(frame)
        if landmarks:
            lm = landmarks.landmark
            
            # Use right side landmarks (consistent with main app)
            hip = [lm[24].x, lm[24].y]
            knee = [lm[26].x, lm[26].y]
            ankle = [lm[28].x, lm[28].y]
            shoulder = [lm[12].x, lm[12].y]

            knee_angle = calculate_angle(hip, knee, ankle)
            back_angle = calculate_angle(shoulder, hip, knee)
            
            knee_angles.append(knee_angle)
            back_angles.append(back_angle)
            processed_frames += 1

    cap.release()
    print(f"  ✓ Processed {processed_frames} frames out of {frame_count} total frames")
    
    return knee_angles, back_angles


def main():
    # Paths
    correct_videos_dir = "correct_videos"
    
    # Check if directory exists
    if not os.path.exists(correct_videos_dir):
        print(f"❌ Error: Directory '{correct_videos_dir}' not found!")
        print(f"   Please create it and add correct squat videos (.mp4)")
        return
    
    # Get all video files
    video_files = [f for f in os.listdir(correct_videos_dir) 
                   if f.endswith(('.mp4', '.avi', '.mov', '.MP4'))]
    
    if not video_files:
        print(f"❌ Error: No video files found in '{correct_videos_dir}'")
        print(f"   Please add .mp4 videos of correct squats")
        return
    
    print(f"\n📹 Found {len(video_files)} video(s) to process\n")
    
    # Process all videos
    all_knee = []
    all_back = []
    
    for video in video_files:
        video_path = os.path.join(correct_videos_dir, video)
        k, b = process_video(video_path)
        all_knee.extend(k)
        all_back.extend(b)
    
    # Check if we got any data
    if not all_knee or not all_back:
        print("\n❌ Error: No pose data extracted from videos!")
        print("   Make sure videos show clear side-view squats")
        return
    
    # Calculate statistics
    print("\n" + "="*60)
    print("📊 RESULTS - SUGGESTED THRESHOLDS")
    print("="*60)
    
    knee_mean = np.mean(all_knee)
    knee_std = np.std(all_knee)
    knee_min = np.min(all_knee)
    knee_max = np.max(all_knee)
    
    back_mean = np.mean(all_back)
    back_std = np.std(all_back)
    back_min = np.min(all_back)
    back_max = np.max(all_back)
    
    print(f"\n🦵 KNEE ANGLE:")
    print(f"   Mean:  {knee_mean:.1f}°")
    print(f"   Std:   {knee_std:.1f}°")
    print(f"   Range: {knee_min:.1f}° - {knee_max:.1f}°")
    print(f"   📌 SUGGESTED THRESHOLD: {knee_mean - 15:.1f}° to {knee_mean + 15:.1f}°")
    
    print(f"\n🧍 BACK ANGLE:")
    print(f"   Mean:  {back_mean:.1f}°")
    print(f"   Std:   {back_std:.1f}°")
    print(f"   Range: {back_min:.1f}° - {back_max:.1f}°")
    print(f"   📌 SUGGESTED THRESHOLD: {back_mean - 20:.1f}° to {back_mean + 20:.1f}°")
    
    print("\n" + "="*60)
    print("📝 Copy this to config/thresholds.json:")
    print("="*60)
    print("""{
  "squat": {
    "knee_angle": { "min": %.1f, "max": %.1f },
    "back_angle": { "min": %.1f, "max": %.1f }
  }
}""" % (knee_mean - 15, knee_mean + 15, back_mean - 20, back_mean + 20))
    print("="*60)
    
    print(f"\n✅ Analyzed {len(all_knee)} frames from {len(video_files)} video(s)")
    print()


if __name__ == "__main__":
    main()