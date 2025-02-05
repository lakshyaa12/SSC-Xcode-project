import SwiftUI
import AVFoundation

struct BlinkDetectionScreen: View {
    @StateObject private var blinkDetector = BlinkDetector()  // ObservableObject to manage blink detection
    @State private var isCameraReady = false  // State to manage camera readiness
    
    var body: some View {
        VStack {
            // Title for this screen
            Text("Blink to Generate Morse Code")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            // Show loading indicator until the camera is ready
            if !isCameraReady {
                ProgressView("Initializing Camera...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else {
                // Camera Preview
                if let session = blinkDetector.captureSession {
                    CameraPreview(session: session)  // Displays live camera feed
                        .frame(width: 300, height: 300)
                        .cornerRadius(10)
                        .padding()
                }
            }
            
            // Detected Morse Code
            Text("Detected Morse Code: \(blinkDetector.detectedMorseCode)")
                .font(.title2)
                .padding()
            
            // Transcribed Text
            Text("Transcribed Text: \(blinkDetector.transcribedText)")
                .font(.title2)
                .foregroundColor(.green)
                .padding()
            
            Spacer()
            
            // Button to stop the camera session
            Button(action: {
                blinkDetector.stopCamera()
            }) {
                Text("Stop Blink Detection")
                    .font(.title2)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            blinkDetector.startCamera { success in
                isCameraReady = success
            }
        }
        .onDisappear {
            blinkDetector.stopCamera()
        }
        .navigationTitle("Morse Code Detection")
        .navigationBarBackButtonHidden(false)  // Ensure back button is visible
    }
}

struct BlinkDetectionScreen_Previews: PreviewProvider {
    static var previews: some View {
        BlinkDetectionScreen()
    }
}
