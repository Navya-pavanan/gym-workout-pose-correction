import os
import uuid

UPLOAD_DIR = "uploads"

def save_uploaded_video(file):
    if not os.path.exists(UPLOAD_DIR):
        os.makedirs(UPLOAD_DIR)

    filename = f"{uuid.uuid4()}.mp4"
    path = os.path.join(UPLOAD_DIR, filename)
    file.save(path)
    return path

def delete_file(path):
    if os.path.exists(path):
        os.remove(path)
