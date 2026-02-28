import cv2
import os
import uuid
import mediapipe as mp

OUTPUT_DIR = "static/feedback_images"
os.makedirs(OUTPUT_DIR, exist_ok=True)

mp_pose = mp.solutions.pose
mp_draw = mp.solutions.drawing_utils


def generate_visual_feedback(frame, landmarks, incorrect_joints, phase="squatting", additional_text=None):
    """
    Generate visual feedback image with colored landmarks.
    
    Args:
        frame: Video frame (numpy array)
        landmarks: MediaPipe pose landmarks
        incorrect_joints: List of incorrect joint names (e.g., ["knee", "back"])
        phase: "standing" or "squatting"
        additional_text: Additional text to display
    
    Returns:
        filepath: Path to saved image
    """
    if frame is None or landmarks is None:
        return None
    
    annotated = frame.copy()
    h, w, _ = frame.shape
    
    # Map joint names to landmark indices
    joint_mapping = {
        "knee": [26, 28],      # Right knee, Right ankle
        "back": [12, 24],      # Right shoulder, Right hip
        "posture": [12, 24]    # Same as back for alignment issues
    }
    
    # Collect all incorrect landmark indices
    incorrect_indices = set()
    for joint in incorrect_joints:
        if joint in joint_mapping:
            incorrect_indices.update(joint_mapping[joint])
    
    # Draw each landmark with appropriate color
    for idx, landmark in enumerate(landmarks.landmark):
        if landmark.visibility < 0.5:
            continue
        
        x = int(landmark.x * w)
        y = int(landmark.y * h)
        
        # Determine color and size
        if idx in incorrect_indices:
            color = (0, 0, 255)  # Red for incorrect
            radius = 8
        else:
            color = (0, 255, 0)  # Green for correct
            radius = 5
        
        # Draw filled circle
        cv2.circle(annotated, (x, y), radius, color, -1)
        # Draw white outline for contrast
        cv2.circle(annotated, (x, y), radius + 2, (255, 255, 255), 2)
    
    # Draw skeleton connections
    connections = mp_pose.POSE_CONNECTIONS
    for connection in connections:
        start_idx = connection[0]
        end_idx = connection[1]
        
        start_landmark = landmarks.landmark[start_idx]
        end_landmark = landmarks.landmark[end_idx]
        
        if start_landmark.visibility < 0.5 or end_landmark.visibility < 0.5:
            continue
        
        start_point = (int(start_landmark.x * w), int(start_landmark.y * h))
        end_point = (int(end_landmark.x * w), int(end_landmark.y * h))
        
        # Color connection red if either endpoint is incorrect
        if start_idx in incorrect_indices or end_idx in incorrect_indices:
            line_color = (0, 0, 255)  # Red
        else:
            line_color = (255, 255, 255)  # White
        
        cv2.line(annotated, start_point, end_point, line_color, 2)
    
    # Add semi-transparent overlay for text background
    overlay = annotated.copy()
    text_height = 40 + (len(incorrect_joints) * 35) + (35 if additional_text else 0)
    cv2.rectangle(overlay, (0, 0), (w, min(text_height, 200)), (0, 0, 0), -1)
    cv2.addWeighted(overlay, 0.6, annotated, 0.4, 0, annotated)
    
    # Add text overlay
    y_offset = 30
    
    # Phase title
    phase_title = f"Posture Analysis - {phase.upper()} Phase"
    cv2.putText(annotated, phase_title, (10, y_offset),
                cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
    
    y_offset += 35
    
    # Feedback messages
    if not incorrect_joints:
        cv2.putText(annotated, "Perfect Form!", (10, y_offset),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
    else:
        for joint in incorrect_joints:
            joint_text = f"{joint.upper()}: NEEDS CORRECTION"
            cv2.putText(annotated, joint_text, (10, y_offset),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 255), 2)
            y_offset += 35
    
    # Additional text (e.g., depth info)
    if additional_text:
        y_offset += 10
        cv2.putText(annotated, additional_text, (10, y_offset),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 0), 1)
    
    # Save image
    filename = f"feedback_{phase}_{uuid.uuid4().hex[:8]}.png"
    filepath = os.path.join(OUTPUT_DIR, filename)
    cv2.imwrite(filepath, annotated)
    
    return filepath


def generate_dual_feedback(standing_frame, standing_landmarks, standing_issues,
                           squat_frame, squat_landmarks, squat_issues,
                           depth_info=None):
    """
    Generate two feedback images: one for standing, one for squatting.
    
    Returns:
        {
            "standing_image": filepath,
            "squatting_image": filepath
        }
    """
    standing_joints = [issue["joint"] for issue in standing_issues]
    squat_joints = list(set([issue["joint"] for issue in squat_issues]))
    
    # Additional text for squat image
    squat_text = f"Depth: {depth_info['min_knee']:.1f} degrees" if depth_info else None
    
    standing_path = generate_visual_feedback(
        standing_frame,
        standing_landmarks,
        standing_joints,
        phase="standing",
        additional_text=None
    )
    
    squatting_path = generate_visual_feedback(
        squat_frame,
        squat_landmarks,
        squat_joints,
        phase="squatting",
        additional_text=squat_text
    )
    
    return {
        "standing_image": standing_path,
        "squatting_image": squatting_path
    }