//
//  RealTimeDetectionViewController.swift
//  ai 11
//
//  Created by Youngmok Cho on 2020-04-05.
//  Copyright © 2020 Youngmok Cho. All rights reserved.
//

import UIKit
import Vision

class RealTimeDetectionViewController: UIViewController {
    
    @IBOutlet weak var cameraView: UIView!
    
    var videoCapture: VideoCapture!
    
    let visionRequestHandler = VNSequenceRequestHandler()
    
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.confidenceLabel.text = ""
        self.categoryLabel.text = ""
        
        let spec = VideoSpec(fps: 3, size: CGSize(width: 1280, height: 720))
        self.videoCapture = VideoCapture(cameraType: .back, preferredSpec: spec, previewContainer: self.cameraView.layer)
        // called repeatedly every time the image window changes
        self.videoCapture.imageBufferHandler = {(imageBuffer, timestamp, outputBuffer) in
            self.detectObject(image: imageBuffer)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let videoCapture = self.videoCapture {
            videoCapture.startCapture()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let videoCapture = self.videoCapture {
            videoCapture.stopCapture()
        }
    }

    func detectObject(image: CVImageBuffer) {
        do {
            let vnCoreMLModel = try VNCoreMLModel(for: Resnet50().model)
            let request = VNCoreMLRequest(model: vnCoreMLModel, completionHandler: self.handleObjectDetection)
            request.imageCropAndScaleOption = .centerCrop
            try self.visionRequestHandler.perform([request], on: image)
            
        } catch {
            print(error)
        }
    }
    
    func handleObjectDetection(request: VNRequest, error: Error?) {
        if let result = request.results?.first as? VNClassificationObservation {
            DispatchQueue.main.async {
                self.categoryLabel.text = result.identifier
                self.confidenceLabel.text = String(format: "%.1f", result.confidence * 100) + "%"
            }
        }
    }
    
}
