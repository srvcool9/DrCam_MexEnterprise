from flask import Flask, request
import cv2
import numpy as np
import base64
import os

app = Flask(__name__)

output_dir = "C:/recordings"  # Change to desired path
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

video_writer = None
frame_size = (640, 480)

@app.route('/start-recording', methods=['POST'])
def start_recording():
    global video_writer
    file_path = os.path.join(output_dir, "output.mp4")
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    video_writer = cv2.VideoWriter(file_path, fourcc, 20.0, frame_size)
    return {"message": f"Recording started: {file_path}"}

@app.route('/send-frame', methods=['POST'])
def receive_frame():
    global video_writer
    if video_writer is None:
        return {"error": "Recording not started"}, 400

    frame_data = request.json['frame']
    frame_bytes = base64.b64decode(frame_data)
    nparr = np.frombuffer(frame_bytes, np.uint8)
    frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    if frame is not None:
        video_writer.write(frame)  # Write frame to video file

    return {"message": "Frame received"}

@app.route('/stop-recording', methods=['POST'])
def stop_recording():
    global video_writer
    if video_writer:
        video_writer.release()
        video_writer = None
    return {"message": "Recording stopped"}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
