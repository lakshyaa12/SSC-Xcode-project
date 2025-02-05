import SwiftUI
import AVFoundation

class BlinkDetector: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    
    @Published var detectedMorseCode: String = "" // This is the detected Morse code
    @Published var transcribedText: String = "..." // This is the transcribed text (e.g., letters)
    
    var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private var blinkTimer: Timer?
    private var blinkStartTime: Date?
    
    private var morseCodeSequence: String = ""
    
    // Start the camera
    func startCamera(completion: @escaping (Bool) -> Void) {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            completion(false)
            return
        }
        
        let videoDeviceInput: AVCaptureDeviceInput
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            completion(false)
            return
        }
        
        if captureSession?.canAddInput(videoDeviceInput) == true {
            captureSession?.addInput(videoDeviceInput)
        } else {
            completion(false)
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession?.canAddOutput(metadataOutput) == true {
            captureSession?.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.face]
        } else {
            completion(false)
            return
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        
        captureSession?.startRunning()
        completion(true)
    }
    
    // Stop the camera
    func stopCamera() {
        captureSession?.stopRunning()
    }
    
    // Handle face detection in the camera preview
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first else { return }
        guard let readableObject = metadataObject as? AVMetadataFaceObject else { return }
        
        let faceHeight = readableObject.bounds.size.height
        
        if faceHeight > 50 {
            startBlinkDetection()
        } else {
            stopBlinkDetection()
        }
    }
    
    // Start blink detection
    func startBlinkDetection() {
        blinkStartTime = Date()
        blinkTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(checkBlinkDuration), userInfo: nil, repeats: true)
    }
    
    // Stop blink detection
    func stopBlinkDetection() {
        blinkTimer?.invalidate()
        blinkTimer = nil
        
        if let startTime = blinkStartTime {
            let blinkDuration = Date().timeIntervalSince(startTime)
            
            if blinkDuration < 0.5 {
                detectMorseSymbol(".")
            } else if blinkDuration > 1.0 {
                detectMorseSymbol("-")
            }
        }
    }
    
    // Update Morse code and transcribed text
    func detectMorseSymbol(_ symbol: String) {
        morseCodeSequence += symbol
        DispatchQueue.main.async {
            self.detectedMorseCode = self.morseCodeSequence
        }
        
        transcribeMorseToText()
    }
    
    // Convert Morse code to text
    func transcribeMorseToText() {
        let morseToText: [String: String] = [
            ".-": "A", "-...": "B", "-.-.": "C", "-..": "D", ".": "E", "..-.": "F", "--.": "G", "....": "H",
            "..": "I", ".---": "J", "-.-": "K", ".-..": "L", "--": "M", "-.": "N", "---": "O", ".--.": "P",
            "--.-": "Q", ".-.": "R", "...": "S", "-": "T", "..-": "U", "...-": "V", ".--": "W", "-..-": "X",
            "-.--": "Y", "--..": "Z"
        ]
        
        let letter = morseToText[morseCodeSequence] ?? ""
        DispatchQueue.main.async {
            self.transcribedText = letter
        }
    }
    
    // This method checks the blink duration and updates accordingly
    @objc func checkBlinkDuration() {
        if let startTime = blinkStartTime {
            let blinkDuration = Date().timeIntervalSince(startTime)
            
            if blinkDuration > 1.5 {
                stopBlinkDetection()
            }
        }
    }
}
