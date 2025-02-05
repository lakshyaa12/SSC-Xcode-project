import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        // This method can be used to handle each frame of video from the camera
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            // You can process the frame or call the method to analyze it for Morse code, etc.
        }
    }
    
    var captureSession: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        // Create a preview layer to show the camera feed
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the preview layer's frame if needed
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
    
    // This method creates a coordinator to handle the camera output
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
}

struct ContentView: View {
    @StateObject private var blinkDetector = BlinkDetector()
    @State private var isCameraActive = false
    @State private var captureSession: AVCaptureSession?

    var body: some View {
        NavigationView {
            VStack {
                Text("Morse Code Detector")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                if isCameraActive, let session = captureSession {
                    CameraView(captureSession: session)
                        .edgesIgnoringSafeArea(.all) // Ensure camera fills screen
                    
                    VStack {
                        Text("Camera is active")
                            .padding(.top)
                        
                        // Detected Morse Code text
                        Text("Detected Morse Code: \(blinkDetector.detectedMorseCode)")
                            .padding()
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Transcribed Text
                        Text("Transcribed Text: \(blinkDetector.transcribedText)")
                            .padding()
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 10)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                } else {
                    Button("Start Camera") {
                        blinkDetector.startCamera { success in
                            if success {
                                captureSession = blinkDetector.captureSession
                                isCameraActive = true
                            }
                        }
                    }
                    .padding()
                    .font(.title2)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Spacer()
                
                NavigationLink(destination: Text("Settings or other content here")) {
                    Text("Go to Settings")
                        .foregroundColor(.blue)
                        .font(.title2)
                        .padding()
                }
            }
            .navigationBarTitle("Morse Code with Eye Blink", displayMode: .inline)
            .padding()
        }
    }
}
//
//@main
//struct MyApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
