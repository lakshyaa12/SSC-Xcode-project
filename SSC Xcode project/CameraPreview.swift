//
//  CameraPreview.swift
//  SSC Xcode project
//
//  Created by Lakshya  on 05/02/25.
//

import SwiftUI
import AVFoundation

// This struct is used to show the camera feed in a SwiftUI view
struct CameraPreview: UIViewControllerRepresentable {
    var session: AVCaptureSession

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = viewController.view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No updates are needed
    }
}
