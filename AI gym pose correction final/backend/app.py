from flask import Flask, request, jsonify
import json
import cv2
import numpy as np
from flask_cors import CORS 

from utils.file_utils import save_uploaded_video, delete_file
from analysis.pose_estimation import get_pose_landmarks
from analysis.angle_calculation import compute_squat_angles
from analysis.rule_engine import (
    evaluate_standing_posture,
    evaluate_squat_frame,
    aggregate_squat_results,
    analyze_movement_quality
)
from analysis.visual_feedback import generate_dual_feedback

app = Flask(__name__)
CORS(app) 
app = Flask(__name__)
CORS(app)

# ✅ ADD THESE 3 LINES HERE
@app.route("/ping", methods=["GET"])
def ping():
    return jsonify({"status": "Flask backend is running"}), 200

# Load thresholds
with open("config/thresholds.json") as f:
    THRESHOLDS = json.load(f)

# EMA smoothing factor
EMA_ALPHA = 0.3

# Minimum landmark visibility to accept a frame
VISIBILITY_THRESHOLD = 0.6

# Landmark indices for each side (knee excluded from visibility check --
# side-view videos consistently produce low knee visibility in MediaPipe)
LANDMARKS = {
    "right": {"shoulder": 12, "hip": 24, "knee": 26, "ankle": 28},
    "left":  {"shoulder": 11, "hip": 23, "knee": 25, "ankle": 27}
}


def _detect_side(lm):
    """
    Detect which side of the body is more visible to the camera.
    Returns 'right' or 'left'.
    """
    right_vis = (lm[12].visibility + lm[24].visibility + lm[28].visibility) / 3
    left_vis  = (lm[11].visibility + lm[23].visibility + lm[27].visibility) / 3
    return "right" if right_vis >= left_vis else "left"


def _landmarks_visible(lm, side):
    """
    Return True if shoulder, hip, and ankle on the detected side
    all meet the visibility threshold.
    """
    idx = LANDMARKS[side]
    return all(
        lm[idx[joint]].visibility >= VISIBILITY_THRESHOLD
        for joint in ["shoulder", "hip", "ankle"]
    )


def _ema_update(prev, current, alpha=EMA_ALPHA):
    """Apply exponential moving average: new = alpha * current + (1 - alpha) * prev."""
    if prev is None:
        return current
    return alpha * current + (1 - alpha) * prev


@app.route("/analyze_video", methods=["POST"])
def analyze_video():
    """
    Complete squat analysis with standing and squatting phases.
    Supports both left and right side view videos.
    """
    video = request.files.get("video")
    exercise = request.form.get("exercise", "squat")

    if exercise not in THRESHOLDS:
        return jsonify({"error": "Unsupported exercise"}), 400

    # Save uploaded video
    video_path = save_uploaded_video(video)
    cap = cv2.VideoCapture(video_path)

    if not cap.isOpened():
        delete_file(video_path)
        return jsonify({"error": "Cannot open video file"}), 400

    # Initialize tracking variables
    frame_count = 0

    # Standing phase data
    standing_frames_data = []
    best_standing_frame = None
    best_standing_landmarks = None

    # Squat phase data
    squat_frames_data = []
    best_squat_frame = None
    best_squat_landmarks = None
    min_knee_angle = float('inf')

    # EMA state (smoothed angle values carried across sampled frames)
    ema_knee = None
    ema_back = None

    # Detected side -- set once from the first valid frame, reused throughout.
    # Camera position is fixed for the entire video so no need to detect per frame.
    detected_side = None

    # Thresholds
    SQUAT_THRESHOLD = 130   # Knee must be < 130 deg to be considered squatting
    STANDING_FRAME_LIMIT = 50  # First 50 frames checked for standing

    print("\n=== STARTING VIDEO ANALYSIS ===")

    # MAIN PROCESSING LOOP
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        frame_count += 1

        # Sample every 5th frame for efficiency
        if frame_count % 5 != 0:
            continue

        # Get pose landmarks
        landmarks = get_pose_landmarks(frame)
        if not landmarks:
            continue

        lm = landmarks.landmark

        # === AUTO-DETECT FACING SIDE (once only) ===
        # Since the camera position is fixed throughout the video,
        # detect the side from the first valid frame and reuse it.
        if detected_side is None:
            detected_side = _detect_side(lm)
            print(f"Detected camera side: {detected_side}")

        side = detected_side
        idx = LANDMARKS[side]

        # === LANDMARK VISIBILITY FILTERING ===
        # Skip frame if shoulder, hip, or ankle on the detected side are low confidence.
        # Knee is excluded from this check -- side-view videos consistently
        # produce low knee visibility scores in MediaPipe.
        if not _landmarks_visible(lm, side):
            continue

        # Calculate angles using the locked detected side
        angles = compute_squat_angles(lm)
        if angles is None:
            continue

        # === EMA SMOOTHING ===
        ema_knee = _ema_update(ema_knee, angles["knee"])
        ema_back = _ema_update(ema_back, angles["back"])

        smoothed_angles = {
            "knee": ema_knee,
            "back": ema_back
        }

        # Extract position data using the detected side's landmark indices
        positions = {
            "shoulder_x": lm[idx["shoulder"]].x,
            "hip_x":      lm[idx["hip"]].x,
            "knee_x":     lm[idx["knee"]].x,
            "ankle_x":    lm[idx["ankle"]].x
        }

        # === PHASE DETECTION (uses RAW angles for responsiveness) ===

        # Check if this is a STANDING frame (first 50 frames, knee > 160 deg)
        if frame_count <= STANDING_FRAME_LIMIT and angles["knee"] > 160:
            standing_frames_data.append({
                "frame_num": frame_count,
                "angles": smoothed_angles.copy(),
                "positions": positions.copy()
            })

            # Save first good standing frame for visual feedback
            if best_standing_frame is None:
                best_standing_frame = frame.copy()
                best_standing_landmarks = landmarks

        # Check if this is a SQUAT frame (raw knee < 130 deg for sensitivity)
        elif angles["knee"] < SQUAT_THRESHOLD:
            # Evaluate using smoothed angles for stable scoring
            is_correct, issues = evaluate_squat_frame(
                smoothed_angles,
                positions,
                THRESHOLDS[exercise]["squatting"]
            )

            squat_frames_data.append({
                "frame_num": frame_count,
                "angles": smoothed_angles.copy(),
                "positions": positions.copy(),
                "is_correct": is_correct,
                "issues": issues
            })

            # Track deepest squat using raw angle to catch the true minimum
            if angles["knee"] < min_knee_angle:
                min_knee_angle = angles["knee"]
                best_squat_frame = frame.copy()
                best_squat_landmarks = landmarks
                print(f"Frame {frame_count}: NEW DEEPEST SQUAT (knee={angles['knee']:.1f}, back={angles['back']:.1f}, side={side})")
            else:
                print(f"Frame {frame_count}: SQUAT (knee={angles['knee']:.1f}, back={angles['back']:.1f}, side={side})")

    cap.release()

    print(f"\n=== PROCESSING COMPLETE ===")
    print(f"Total frames: {frame_count}")
    print(f"Standing frames: {len(standing_frames_data)}")
    print(f"Squat frames: {len(squat_frames_data)}")
    print(f"Deepest knee angle: {min_knee_angle:.1f}")

    # === ERROR CHECKS ===

    if len(squat_frames_data) == 0:
        delete_file(video_path)
        return jsonify({
            "error": "No squat position detected in video",
            "suggestion": "Ensure video shows person performing squats (knee bent below 130 degrees)"
        }), 400

    if best_standing_frame is None:
        print("WARNING: No standing frames detected, using first squat frame")
        best_standing_frame = best_squat_frame
        best_standing_landmarks = best_squat_landmarks

    # === EVALUATE STANDING PHASE ===

    standing_issues = []
    standing_score = 100
    baseline_back_angle = None

    if len(standing_frames_data) > 0:
        avg_standing_angles = {
            "knee": np.mean([f["angles"]["knee"] for f in standing_frames_data]),
            "back": np.mean([f["angles"]["back"] for f in standing_frames_data])
        }

        avg_positions = {
            "shoulder_x": np.mean([f["positions"]["shoulder_x"] for f in standing_frames_data]),
            "hip_x":      np.mean([f["positions"]["hip_x"] for f in standing_frames_data]),
            "knee_x":     np.mean([f["positions"]["knee_x"] for f in standing_frames_data]),
            "ankle_x":    np.mean([f["positions"]["ankle_x"] for f in standing_frames_data])
        }

        baseline_back_angle = avg_standing_angles["back"]

        standing_score, standing_issues = evaluate_standing_posture(
            avg_standing_angles,
            avg_positions,
            THRESHOLDS[exercise]["standing"]
        )

        print(f"\nStanding Phase Score: {standing_score}")
        print(f"Standing Issues: {len(standing_issues)}")
        print(f"Baseline back angle recorded: {baseline_back_angle:.1f} (reserved for future threshold retuning)")

    # === BASELINE BACK NORMALIZATION ===
    # Baseline is captured above but evaluation intentionally uses absolute
    # smoothed angles to remain compatible with thresholds.json which expects
    # absolute degree values. Retuning thresholds to deviation-based values
    # is required before enabling normalization here.

    # === EVALUATE SQUAT PHASE ===

    squat_score, squat_feedback = aggregate_squat_results(
        squat_frames_data,
        THRESHOLDS[exercise]["squatting"]
    )

    print(f"\nSquat Phase Score: {squat_score}")
    print(f"Squat Feedback Items: {len(squat_feedback)}")

    # === MOVEMENT QUALITY ANALYSIS ===

    movement_quality = analyze_movement_quality(squat_frames_data)

    print(f"\nMovement Quality:")
    print(f"  Min depth: {movement_quality.get('min_depth', 'N/A')}")
    print(f"  Smoothness: {movement_quality.get('smoothness', 'N/A')}")

    # === CALCULATE OVERALL SCORE ===

    # Weighted average: 30% standing, 70% squatting
    overall_score = int(standing_score * 0.3 + squat_score * 0.7)

    # === COMBINE ALL FEEDBACK ===

    all_feedback = {
        "standing_phase": standing_issues,
        "squatting_phase": squat_feedback
    }

    # === GENERATE VISUAL FEEDBACK (TWO IMAGES) ===

    depth_info = {
        "min_knee": movement_quality.get("min_depth", min_knee_angle)
    }

    visual_paths = generate_dual_feedback(
        best_standing_frame,
        best_standing_landmarks,
        standing_issues,
        best_squat_frame,
        best_squat_landmarks,
        squat_feedback,
        depth_info=depth_info
    )

    print(f"\nGenerated images:")
    print(f"  Standing: {visual_paths['standing_image']}")
    print(f"  Squatting: {visual_paths['squatting_image']}")

    # === COMPILE STATISTICS ===

    statistics = {
        "total_frames": frame_count,
        "standing_frames": len(standing_frames_data),
        "squat_frames": len(squat_frames_data),
        "correct_squat_frames": sum(1 for f in squat_frames_data if f["is_correct"]),
        "incorrect_squat_frames": sum(1 for f in squat_frames_data if not f["is_correct"])
    }

    # === CLEANUP ===

    delete_file(video_path)

    # === RETURN RESPONSE ===

    return jsonify({
        "overall_score": overall_score,
        "standing_score": standing_score,
        "squatting_score": squat_score,
        "feedback": all_feedback,
        "images": visual_paths,
        "statistics": statistics,
        "movement_quality": movement_quality,
        "depth_achieved": round(min_knee_angle, 1)
    })


if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5000)