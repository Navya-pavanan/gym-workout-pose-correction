import numpy as np


def calculate_angle(a, b, c):
    a = np.array(a)
    b = np.array(b)
    c = np.array(c)

    ba = a - b
    bc = c - b

    cosine = np.dot(ba, bc) / (np.linalg.norm(ba) * np.linalg.norm(bc))
    angle = np.degrees(np.arccos(np.clip(cosine, -1.0, 1.0)))
    return angle


def _detect_side(landmarks):
    """
    Auto-detect which side of the body is facing the camera
    by comparing average visibility of left vs right landmarks.
    Returns 'right' or 'left'.
    """
    right_vis = (
        landmarks[12].visibility +  # right shoulder
        landmarks[24].visibility +  # right hip
        landmarks[26].visibility +  # right knee
        landmarks[28].visibility    # right ankle
    ) / 4

    left_vis = (
        landmarks[11].visibility +  # left shoulder
        landmarks[23].visibility +  # left hip
        landmarks[25].visibility +  # left knee
        landmarks[27].visibility    # left ankle
    ) / 4

    return "right" if right_vis >= left_vis else "left"


def compute_squat_angles(landmarks):
    """
    Compute knee and back angles for squat analysis.
    Automatically selects left or right side landmarks
    based on which side is more visible to the camera.
    """
    side = _detect_side(landmarks)

    if side == "right":
        shoulder_idx = 12
        hip_idx      = 24
        knee_idx     = 26
        ankle_idx    = 28
    else:
        shoulder_idx = 11
        hip_idx      = 23
        knee_idx     = 25
        ankle_idx    = 27

    shoulder = [landmarks[shoulder_idx].x, landmarks[shoulder_idx].y]
    hip      = [landmarks[hip_idx].x,      landmarks[hip_idx].y]
    knee     = [landmarks[knee_idx].x,     landmarks[knee_idx].y]
    ankle    = [landmarks[ankle_idx].x,    landmarks[ankle_idx].y]

    return {
        "knee": calculate_angle(hip, knee, ankle),
        "back": calculate_angle(shoulder, hip, knee),
        "side": side  # included for debugging/logging purposes
    }


# FUTURE:
# def compute_super_squat_angles(landmarks):
#     pass