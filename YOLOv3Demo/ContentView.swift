//
//  ContentView.swift
//  YOLOv3Demo
//
//  Created by Ishaan Bedi on 24/11/23.
//

import SwiftUI
import Vision
import CoreML


struct ContentView: View {
    @State private var isImagePickerPresented: Bool = false
    @State private var showResultSheet: Bool = false
    @State private var capturedImage: UIImage?
    @State private var detectedObjects: [Observation] = []
    let model = try! YOLOv3(configuration: MLModelConfiguration())
    var body: some View {
        VStack {
            Text("YOLOv3")
                .font(.title3)
            Button("Take a Picture") {
                isImagePickerPresented.toggle()
            }
                .sheet(isPresented: $isImagePickerPresented, onDismiss: loadImage) {
                ImagePicker(image: self.$capturedImage)
                    .ignoresSafeArea()
            }
                .sheet(isPresented: $showResultSheet) {
                VStack {
                    if let image = capturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 300)
                            .overlay {
                            GeometryReader { geometry in
                                Path { path in
                                    for observation in detectedObjects {
                                        path.addRect(VNImageRectForNormalizedRect(observation.boundingBox, Int(geometry.size.width), Int(geometry.size.height)))
                                    }
                                }
                                    .stroke(Color.red, lineWidth: 1.5)
                            }
                        }
                    }
                    if !detectedObjects.isEmpty {
                        List(detectedObjects, id: \.label) { item in
                            HStack {
                                Text(item.label.capitalized)
                                Spacer()
                                Text("\(item.confidence * 100, specifier: "%.2f")%")

                            }
                        }
                    } else {
                        VStack {
                            Text("Nothing could be detected.")
                            Button("Try again!") {
                                capturedImage = nil
                                detectedObjects = []
                                showResultSheet.toggle()
                            }
                                .buttonStyle(.borderedProminent)
                        }
                    }
                }
                    .padding(.all)
            }
        }
    }
    func loadImage() {
        let mlModel = model.model
        guard let vnCoreMLModel = try? VNCoreMLModel(for: mlModel) else { return }
        let request = VNCoreMLRequest(model: vnCoreMLModel) { request, error in
            guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
            detectedObjects = results.map { result in
                guard let label = result.labels.first?.identifier else { return Observation(label: "", confidence: VNConfidence.zero, boundingBox: .zero) }
                let confidence = result.labels.first?.confidence ?? 0.0
                let boundedBox = result.boundingBox
                let observation: Observation = Observation(label: label, confidence: confidence, boundingBox: boundedBox)
                return observation
            }
            print(detectedObjects)
        }
        guard let image = capturedImage, let pixelBuffer = convertToCVPixelBuffer(newImage: image) else {
            return
        }
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        do {
            try requestHandler.perform([request])
            showResultSheet.toggle()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}
struct Observation {
    let label: String
    let confidence: VNConfidence
    let boundingBox: CGRect
}

#Preview {
    ContentView()
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var image: UIImage?

        init(image: Binding<UIImage?>) {
            _image = image
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                image = uiImage
            }

            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(image: $image)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }


    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) { }
}



func convertToCVPixelBuffer(newImage: UIImage) -> CVPixelBuffer? {
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
    var pixelBuffer: CVPixelBuffer?
    let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)

    CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

    let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

    context?.translateBy(x: 0, y: newImage.size.height)
    context?.scaleBy(x: 1.0, y: -1.0)

    UIGraphicsPushContext(context!)
    newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
    UIGraphicsPopContext()
    CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    return pixelBuffer
}
