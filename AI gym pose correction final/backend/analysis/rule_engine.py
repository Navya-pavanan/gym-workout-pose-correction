import numpy as np

def evaluate_standing_posture(angles, positions, thresholds):
    """
    Evaluate starting/standing position.
    
    Args:
        angles: {"knee": float, "back": float}
        positions: {"shoulder_x": float, "hip_x": float, "knee_x": float, "ankle_x": float}
        thresholds: threshold dict for standing phase
    
    Returns:
        score: int (0-100)
        issues: list of issue dicts
    """
    issues = []
    
    # Check knee position (should be nearly straight)
    if angles["knee"] < thresholds["knee_angle"]["min"]:
        issues.append({
            "joint": "knee",
            "issue": "knees_bent_at_start",
            "message": f"Knees bent at starting position ({angles['knee']:.1f}°). Stand with straight legs before beginning.",
            "severity": "medium"
        })
    
    # Check upright posture
    if angles["back"] < thresholds["back_angle"]["min"]:
        issues.append({
            "joint": "back",
            "issue": "slouched_starting_position",
            "message": f"Slouched forward in starting position ({angles['back']:.1f}°). Stand tall with chest up.",
            "severity": "high"
        })
    elif angles["back"] > thresholds["back_angle"]["max"]:
        issues.append({
            "joint": "back",
            "issue": "leaning_back_start",
            "message": f"Leaning backward at start ({angles['back']:.1f}°). Stand with neutral spine.",
            "severity": "low"
        })
    
    # Check vertical alignment
    alignment_dev = max(
        abs(positions["shoulder_x"] - positions["hip_x"]),
        abs(positions["hip_x"] - positions["knee_x"])
    )
    
    if alignment_dev > thresholds["vertical_alignment_threshold"]:
        issues.append({
            "joint": "posture",
            "issue": "poor_vertical_alignment",
            "message": "Body not vertically aligned at start. Center your weight over mid-foot.",
            "severity": "medium"
        })
    
    # Calculate score
    score = max(0, 100 - len(issues) * 25)
    
    return score, issues


def evaluate_squat_frame(angles, positions, thresholds):
    """
    Evaluate a single squat frame.
    
    Args:
        angles: {"knee": float, "back": float}
        positions: position data for additional checks
        thresholds: threshold dict for squatting phase
    
    Returns:
        is_correct: bool
        issues: list of issue types ["knee", "back", etc.]
    """
    issues = []
    
    # Check knee depth
    if angles["knee"] > thresholds["knee_angle"]["max"]:
        issues.append("knee_shallow")
    elif angles["knee"] < thresholds["knee_angle"]["min"]:
        issues.append("knee_too_deep")
    
    # Check back angle
    if angles["back"] < thresholds["back_angle"]["min"]:
        issues.append("back_forward")
    elif angles["back"] > thresholds["back_angle"]["max"]:
        issues.append("back_upright")
    
    # Check knee forward travel (optional - if positions provided)
    if positions:
        knee_forward = positions.get("knee_x", 0) - positions.get("ankle_x", 0)
        if knee_forward > thresholds.get("knee_forward_threshold", 0.15):
            issues.append("knee_forward")
    
    is_correct = len(issues) == 0
    return is_correct, issues


def aggregate_squat_results(squat_frames_data, thresholds):
    """
    Aggregate results across all squat frames.
    
    Args:
        squat_frames_data: list of frame evaluation results
        thresholds: threshold dict
    
    Returns:
        score: int (0-100)
        feedback: list of detailed feedback dicts
    """
    total_frames = len(squat_frames_data)
    correct_frames = sum(1 for f in squat_frames_data if f["is_correct"])
    
    # Count issue types
    issue_counts = {
        "knee_shallow": 0,
        "knee_too_deep": 0,
        "back_forward": 0,
        "back_upright": 0,
        "knee_forward": 0
    }
    
    for frame in squat_frames_data:
        for issue in frame["issues"]:
            if issue in issue_counts:
                issue_counts[issue] += 1
    
    # Calculate score
    score = int((correct_frames / total_frames * 100)) if total_frames > 0 else 0
    
    # Generate feedback (only if issue rate > 30%)
    feedback = []
    threshold_rate = 0.3
    
    # Knee shallow
    if issue_counts["knee_shallow"] > total_frames * threshold_rate:
        rate = (issue_counts["knee_shallow"] / total_frames) * 100
        feedback.append({
            "joint": "knee",
            "issue": "not_bent_enough",
            "message": f"Knee not bent enough in {rate:.0f}% of squat frames. Go deeper to achieve proper depth (aim for 90° knee angle).",
            "severity": "high",
            "frames_affected": issue_counts["knee_shallow"]
        })
    
    # Knee too deep
    if issue_counts["knee_too_deep"] > total_frames * threshold_rate:
        rate = (issue_counts["knee_too_deep"] / total_frames) * 100
        feedback.append({
            "joint": "knee",
            "issue": "bent_too_much",
            "message": f"Knee bent excessively in {rate:.0f}% of frames. Avoid going deeper than comfortable depth.",
            "severity": "medium",
            "frames_affected": issue_counts["knee_too_deep"]
        })
    
    # Back leaning forward
    if issue_counts["back_forward"] > total_frames * threshold_rate:
        rate = (issue_counts["back_forward"] / total_frames) * 100
        feedback.append({
            "joint": "back",
            "issue": "leaning_forward",
            "message": f"Excessive forward lean in {rate:.0f}% of frames. Keep torso more upright by engaging core.",
            "severity": "high",
            "frames_affected": issue_counts["back_forward"]
        })
    
    # Back too upright
    if issue_counts["back_upright"] > total_frames * threshold_rate:
        rate = (issue_counts["back_upright"] / total_frames) * 100
        feedback.append({
            "joint": "back",
            "issue": "too_upright",
            "message": f"Torso too upright in {rate:.0f}% of frames. Some forward lean is natural.",
            "severity": "low",
            "frames_affected": issue_counts["back_upright"]
        })
    
    # Knee forward
    if issue_counts["knee_forward"] > total_frames * threshold_rate:
        rate = (issue_counts["knee_forward"] / total_frames) * 100
        feedback.append({
            "joint": "knee",
            "issue": "excessive_forward_travel",
            "message": f"Knees traveling too far forward in {rate:.0f}% of frames. Sit back more into your hips.",
            "severity": "medium",
            "frames_affected": issue_counts["knee_forward"]
        })
    
    return score, feedback


def analyze_movement_quality(squat_frames_data):
    """
    Analyze overall movement quality (smoothness, speed, etc.)
    
    Returns additional insights about movement pattern.
    """
    if len(squat_frames_data) < 5:
        return {}
    
    knee_angles = [f["angles"]["knee"] for f in squat_frames_data]
    
    # Calculate descent speed (angle change per frame)
    angle_changes = [abs(knee_angles[i] - knee_angles[i-1]) 
                     for i in range(1, len(knee_angles))]
    
    avg_speed = np.mean(angle_changes) if angle_changes else 0
    
    # Detect phases
    min_knee_idx = knee_angles.index(min(knee_angles))
    descent_frames = squat_frames_data[:min_knee_idx+1]
    ascent_frames = squat_frames_data[min_knee_idx:]
    
    analysis = {
        "min_depth": min(knee_angles),
        "max_depth": max(knee_angles),
        "avg_movement_speed": round(avg_speed, 2),
        "descent_frames": len(descent_frames),
        "ascent_frames": len(ascent_frames),
        "smoothness": "good" if np.std(angle_changes) < 2 else "jerky"
    }
    
    return analysis