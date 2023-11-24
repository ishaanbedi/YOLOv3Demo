# YOLOv3 Real-Time Object Detection in iOS App using SwiftUI and CoreML

This is a SwiftUI-based iOS application that demonstrates the use of YOLOv3 (You Only Look Once version 3) for real-time object detection in images captured from the device's camera.

The app utilizes the Vision and CoreML frameworks to integrate the YOLOv3 model for detecting objects in the images.

This project can be used to detect objects in images using both the YOLOv3 model and the YOLOv3 Tiny model, as the Swift classes are same for both the models with the only difference being the model file (size and name).

The project is not bundled with any of the YOLOv3 models. You can download the models from the [Apple Machine Learning Models](https://developer.apple.com/machine-learning/models/) page and add them to the project by dragging and dropping them into the project navigator. 

By default, the project is configured to use the YOLOv3 model.
To use the YOLOv3 Tiny model, update the name over [here]().



## Features

- Capture images using the device's camera.
- Real-time object detection using YOLOv3 model.
- Display bounding boxes around detected objects.
- Display detected objects with confidence percentages.

## Usage

1. Run the app
2. Tap the "Take a Picture" button to take a picture
3. The app will detect objects in the image and display the results
4. The results will be displayed in a list view with the detected objects and their confidence percentages, and also in the image view with bounding boxes around the detected objects.


## Demo

![Demo](https://res.cloudinary.com/dhfhotfqs/image/upload/v1700807434/Screenshot_2023-11-24_at_12.00.29_PM_nugwpr.png)

## Acknowledgements

### YOLOv3

A neural network for fast object detection that detects 80 different classes of objects. Given an RGB image, with the dimensions 416x416, the model outputs three arrays (one for each layer) of arbitrary length; each containing confidence scores for each cell and the normalised coordaintes for the bounding box around the detected object(s).

Refer to the original paper for more details. [YOLOv3: An Incremental Improvement](https://pjreddie.com/media/files/papers/YOLOv3.pdf)

### Function `convertToCVPixelBuffer(newImage: UIImage) -> CVPixelBuffer?` 

This function is built on top of the methodology described over [here](https://www.hackingwithswift.com/whats-new-in-ios-11), as the specific requirement for the CoreML model is to accept a *CVPixelBuffer* as input, whereas the captured image is of type *UIImage*.