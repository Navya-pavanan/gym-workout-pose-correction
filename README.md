# Gym Workout Pose Correction

An AI-powered fitness assistant that analyzes workout posture in real-time and provides corrective feedback using computer vision and pose estimation techniques.

## Overview

Gym Workout Pose Correction is a computer vision-based application that helps users perform exercises with proper form. The system detects body landmarks through a webcam or video feed, evaluates posture, and provides instant feedback to reduce injury risk and improve workout effectiveness.

This project leverages pose estimation models to track body movements and compare them against ideal exercise postures.

## Features

* Real-time pose detection
* Exercise posture analysis
* Instant corrective feedback
* Workout form validation
* User-friendly interface
* Supports webcam-based monitoring
* Visual landmark tracking
* Injury prevention through posture correction

## Supported Exercises

* Squats
(for now)
NB:system is scalable

## Tech Stack

### Frontend

*Flutter

### Backend

* Python
* Flask 

### Computer Vision & AI

* OpenCV
* MediaPipe
* NumPy

## Project Structure

```bash
gym-workout-pose-correction/
│
├── static/
│   ├── css/
│   ├── js/
│   └── images/
│
├── templates/
│   └── index.html
│
├── app.py
├── pose_detector.py
├── exercise_logic.py
├── requirements.txt
├── README.md
└── assets/
```

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/Navya-pavanan/gym-workout-pose-correction.git
cd gym-workout-pose-correction
```

### 2. Create Virtual Environment

```bash
python -m venv venv
```

### 3. Activate Virtual Environment

Windows:

```bash
venv\Scripts\activate
```

Linux/Mac:

```bash
source venv/bin/activate
```

### 4. Install Dependencies

```bash
pip install -r requirements.txt
```


### 5. Install Flutter Dependencies

```bash
flutter pub get
```

### 6. Verify Flutter Setup

```bash
flutter doctor
```

Ensure all required Flutter SDK components and platform dependencies are installed.

## Running the Project

```bash
python app.py
```

Open your browser and navigate to:

```bash
http://127.0.0.1:5000
```

### Run on a Connected Device or Emulator

```bash
flutter run
```

### Run on a Specific Device

List available devices:

```bash
flutter devices
```

Run on a selected device:

```bash
flutter run -d <device_id>
```


## How It Works

1. Captures video frames from the webcam.
2. Detects human body landmarks using MediaPipe Pose.
3. Calculates joint angles and body alignment.
4. Compares posture against predefined exercise rules.
5. Generates corrective feedback in real time.
6. Displays posture status to the user.

## Future Enhancements

* Exercise repetition counter
* Personalized workout recommendations
* Workout history tracking
* Mobile application support
* AI-based form scoring
* Voice feedback system
* Additional exercise support

## Screenshots

### Home Page
<img width="720" height="1600" alt="WhatsApp Image 2026-06-13 at 7 49 14 PM" src="https://github.com/user-attachments/assets/1ab5a82a-094d-486d-8a06-e9c67dc566a1" />
<img width="720" height="1600" alt="WhatsApp Image 2026-06-13 at 7 49 14 PM" src="https://github.com/user-attachments/assets/76d65684-3051-412f-b065-84cf4ee95dd7" />
<img width="720" height="1600" alt="WhatsApp Image 2026-06-13 at 7 49 14 PM" src="https://github.com/user-attachments/assets/4cee0057-1400-421f-841c-259a410d19e5" />

### Pose Detection

<img width="720" height="1600" alt="WhatsApp Image 2026-06-13 at 7 49 14 PM" src="https://github.com/user-attachments/assets/19975af5-8a4f-4768-b2df-7976163e07c0" />
.

### Feedback System

<img width="720" height="1600" alt="WhatsApp Image 2026-06-13 at 7 49 14 PM" src="https://github.com/user-attachments/assets/78cb3536-3a6f-4133-b228-ba68990a15b2" />
<img width="720" height="1600" alt="WhatsApp Image 2026-06-13 at 7 49 14 PM" src="https://github.com/user-attachments/assets/8eb06366-5552-4c52-ab84-89cb3e6ba8d7" />
<img width="720" height="1600" alt="WhatsApp Image 2026-06-13 at 7 49 14 PM" src="https://github.com/user-attachments/assets/2b5a05b2-138b-41a9-a3d1-9c0aab31951f" />
<h4>if wrong</h4>
<img width="720" height="1600" alt="WhatsApp Image 2026-06-13 at 7 49 14 PM" src="https://github.com/user-attachments/assets/db02a6da-dbb3-4eed-b88f-c8b134ec3378" />

<img width="720" height="1600" alt="WhatsApp Image 2026-06-13 at 7 49 14 PM" src="https://github.com/user-attachments/assets/c33b7c7a-4743-494e-a255-1339eceb4df4" />


## Learning Outcomes

Through this project, I gained experience in:

* Computer Vision
* Human Pose Estimation
* OpenCV
* MediaPipe
* Real-Time Video Processing
* Full Stack Development
* Python Application Development



## Author

**Navya J**
**Nekshtra V Nair**
**Meenakshi HN**
**Krishna P**

GitHub: https://github.com/Navya-pavanan
