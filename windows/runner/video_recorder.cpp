
#include <opencv2/opencv.hpp>
#include <iostream>
#include <thread>

bool isRecording = false; // Flag to stop recording

extern "C" __declspec(dllexport) void startRecording(const char* outputPath) {
    cv::VideoCapture cap(0); // Open default camera (0)
    if (!cap.isOpened()) {
        std::cerr << "❌ Error: Could not open camera!" << std::endl;
        return;
    }

    int frameWidth = static_cast<int>(cap.get(cv::CAP_PROP_FRAME_WIDTH));
    int frameHeight = static_cast<int>(cap.get(cv::CAP_PROP_FRAME_HEIGHT));
    cv::Size frameSize(frameWidth, frameHeight);
    int fps = 30; // Frames per second

    cv::VideoWriter writer(outputPath, cv::VideoWriter::fourcc('M', 'J', 'P', 'G'), fps, frameSize);
    if (!writer.isOpened()) {
        std::cerr << "❌ Error: Could not open video writer!" << std::endl;
        return;
    }

    isRecording = true;
    std::cout << "🎥 Recording started: " << outputPath << std::endl;

    while (isRecording) {
        cv::Mat frame;
        cap >> frame; // Capture frame
        if (frame.empty()) {
            std::cerr << "⚠️ Warning: Empty frame!" << std::endl;
            continue;
        }
        writer.write(frame); // Save frame
        cv::waitKey(33); // Delay ~30 FPS
    }

    cap.release();
    writer.release();
    std::cout << "✅ Recording stopped." << std::endl;
}

extern "C" __declspec(dllexport) void stopRecording() {
    isRecording = false;
}
