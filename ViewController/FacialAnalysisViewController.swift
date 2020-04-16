//
//  FacialAnalysisViewController.swift
//  ai 11
//
//  Created by Youngmok Cho on 2020-04-06.
//  Copyright © 2020 Youngmok Cho. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

class FacialAnalysisViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var selectedImage: UIImage? {
        didSet {
            self.blurredImageView.image = selectedImage
            self.selectedImageView.image = selectedImage
        }
    }
    
    var selectedCiImage: CIImage? {
        get {
            if let selectedImage = self.selectedImage {
                return CIImage(image: selectedImage)
            } else {
                return nil
            }
        }
    }
    
    var selectedFace: UIImage? {
        didSet {
            // continue if selectedFace isn't nil
            if let selectedFace = self.selectedFace {
                DispatchQueue.global(qos: .userInitiated).async {
                    self.performFaceAnalysis(on: selectedFace)
                }
            }
        }
        
    }
    
    var faceImageViews = [UIImageView]()
    
    var requests = [VNRequest]()
    
    @IBOutlet weak var blurredImageView: UIImageView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var facesScrollView: UIScrollView!
    
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var genderIdentifierLabel: UILabel!
    @IBOutlet weak var genderConfidenceLabel: UILabel!
    
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var ageConfidenceLabel: UILabel!
    @IBOutlet weak var ageIdentifierLabel: UILabel!
    
    @IBOutlet weak var emotionLabel: UILabel!
    @IBOutlet weak var emotionIdentifierLabel: UILabel!
    @IBOutlet weak var emotionConfidenceLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideAllLabels()
        
        do {
            let genderModel = try VNCoreMLModel(for: GenderNet().model)
            self.requests.append(VNCoreMLRequest(model: genderModel, completionHandler: handleGenderClassification))
            
            let ageModel = try VNCoreMLModel(for: AgeNet().model)
            self.requests.append(VNCoreMLRequest(model: ageModel, completionHandler: handleAgeClassification))
            
            let emotionModel = try VNCoreMLModel(for: CNNEmotions().model)
            self.requests.append(VNCoreMLRequest(model: emotionModel, completionHandler: handleEmotionClassification))
            
        } catch {
            print(error)
        }
    }
    
    
    @IBAction func addPhoto(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let importFromAlbum = UIAlertAction(title: "Import From Album", style: .default) { _ in
            let picker = UIImagePickerController()
            picker.delegate = self
            
            picker.sourceType = .savedPhotosAlbum
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
        
        let takePhoto = UIAlertAction(title: "Use Camera", style: .default) { _ in
            let picker = UIImagePickerController()
            picker.delegate = self
            
            picker.sourceType = .camera
            // two modes when sourcetype = camera
            // 1. photo 2. video
            picker.cameraCaptureMode = .photo
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            
        }
        
        actionSheet.addAction(importFromAlbum)
        actionSheet.addAction(takePhoto)
        actionSheet.addAction(cancel)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let uiImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.selectedImage = uiImage
            self.removeRectangles()
            self.removeFaceImageViews()
            self.hideAllLabels()
            
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.detectFaces()
            }
        
        }
        
    }
    
    
    func detectFaces() {
        if let ciImage = self.selectedCiImage {
            let detectFaceRequest = VNDetectFaceRectanglesRequest(completionHandler: self.handleFaces)
            let requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            
            do {
                try requestHandler.perform([detectFaceRequest])
            } catch {
                print(error)
            }
            
        }
    }
    
    func handleFaces(request: VNRequest, error: Error?) {
        if let faces = request.results as? [VNFaceObservation] {
            DispatchQueue.main.async {
                self.displayUI(for: faces)
            }
            
        }
    }

    func displayUI(for faces: [VNFaceObservation]) {
        if let faceImage = self.selectedImage {
            let imageRect = AVMakeRect(aspectRatio: faceImage.size, insideRect: self.selectedImageView.bounds)

            for (index, face) in faces.enumerated() {
                let w = face.boundingBox.size.width * imageRect.width
                let h = face.boundingBox.size.height * imageRect.height
                let x = face.boundingBox.origin.x * imageRect.width
                let y = imageRect.maxY - (face.boundingBox.origin.y * imageRect.height) - h

                // CAShapeLayer - can draw a rectangle on an image view
                let layer = CAShapeLayer()
                layer.frame = CGRect(x: x, y:y, width:w, height: h)
                layer.borderColor = UIColor.red.cgColor
                layer.borderWidth = 1
                self.selectedImageView.layer.addSublayer(layer)
                
                
                let w2 = face.boundingBox.size.width * faceImage.size.width
                let h2 = face.boundingBox.size.height * faceImage.size.height
                let x2 = face.boundingBox.origin.x * faceImage.size.width
                let y2 = (1 - face.boundingBox.origin.y) * faceImage.size.height - h2
                let cropRect = CGRect(x: x2 * faceImage.scale, y: y2 * faceImage.scale, width: w2 * faceImage.scale, height: h2 * faceImage.scale)
                
                if let faceCgImage = faceImage.cgImage?.cropping(to: cropRect) {
                    let faceUIImage = UIImage(cgImage: faceCgImage, scale: faceImage.scale, orientation: .up)
                    let faceImageView = UIImageView(frame: CGRect(x: 90 * index, y: 0, width: 80, height: 80))
                    faceImageView.image = faceUIImage
                    faceImageView.isUserInteractionEnabled = true
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(FacialAnalysisViewController.handleFaceImageViewTap))
                    faceImageView.addGestureRecognizer(tap)
                    
                    self.faceImageViews.append(faceImageView)
                    self.facesScrollView.addSubview(faceImageView)
                    
                }
            }
            
            self.facesScrollView.contentSize = CGSize(width: 90 * faces.count - 10, height: 80)
        }

    }

    func removeRectangles() {
        if let sublayers = self.selectedImageView.layer.sublayers {
            for layer in sublayers {
                layer.removeFromSuperlayer()
            }
        }
    }
    
    func removeFaceImageViews() {
        for faceImageView in self.faceImageViews {
            faceImageView.removeFromSuperview()
        }
        
        self.faceImageViews.removeAll()
    }
 
    
    @objc func handleFaceImageViewTap(_ sender: UITapGestureRecognizer) {
        if let tappedImageView = sender.view as? UIImageView {
            
            for faceImageView in self.faceImageViews {
                faceImageView.layer.borderWidth = 0
                // clear = 무색
                faceImageView.layer.borderColor = UIColor.clear.cgColor
            }
            
            tappedImageView.layer.borderWidth = 3
            tappedImageView.layer.borderColor = UIColor.blue.cgColor
            
            self.selectedFace = tappedImageView.image
            
        }
    }
    
    func performFaceAnalysis(on image: UIImage) {
        do {
            for request in self.requests {
                let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
                try handler.perform([request])
            }
        } catch {
            print(error)
        }
    }
    
    
    func handleGenderClassification(request: VNRequest, error: Error?) {
        if let genderObservation = request.results?.first as? VNClassificationObservation {
            DispatchQueue.main.async {
                self.showGenderLabels(identifier: genderObservation.identifier, confidence: genderObservation.confidence)
            }
        
            print("gender : \(genderObservation.identifier), confidence : \(genderObservation.confidence)")
        }
    }
    
    func handleAgeClassification(request: VNRequest, error: Error?) {
        if let ageObservation = request.results?.first as? VNClassificationObservation {
            DispatchQueue.main.async {
                self.showAgeLabels(identifier: ageObservation.identifier, confidence: ageObservation.confidence)
            }
            
            print("age : \(ageObservation.identifier), confidence : \(ageObservation.confidence)")
        }
    }
    
    func handleEmotionClassification(request: VNRequest, error: Error?) {
        if let emotionObservation = request.results?.first as? VNClassificationObservation {
            DispatchQueue.main.async {
                self.showEmotionLabels(identifier: emotionObservation.identifier, confidence: emotionObservation.confidence)
            }
            
            print("emotion : \(emotionObservation.identifier), confidence : \(emotionObservation.confidence)")
        }
    }
    
    func hideGenderLabels() {
        self.genderLabel.isHidden = true
        self.genderIdentifierLabel.isHidden = true
        self.genderConfidenceLabel.isHidden = true
    }
    
    func showGenderLabels(identifier: String, confidence: Float) {
        self.genderIdentifierLabel.text = identifier
        self.genderConfidenceLabel.text = String(format: "%.1f", confidence * 100) + "%"
        
        self.genderLabel.isHidden = false
        self.genderIdentifierLabel.isHidden = false
        self.genderConfidenceLabel.isHidden = false
    }
    
    func hideAgeLabels() {
        self.ageLabel.isHidden = true
        self.ageIdentifierLabel.isHidden = true
        self.ageConfidenceLabel.isHidden = true
    }
    
    func showAgeLabels(identifier: String, confidence: Float) {
        self.ageIdentifierLabel.text = identifier
        self.ageConfidenceLabel.text = String(format: "%.1f", confidence * 100) + "%"
        
        self.ageLabel.isHidden = false
        self.ageIdentifierLabel.isHidden = false
        self.ageConfidenceLabel.isHidden = false
    }
    
    func hideEmotionLabels() {
        self.emotionLabel.isHidden = true
        self.emotionIdentifierLabel.isHidden = true
        self.emotionConfidenceLabel.isHidden = true
    }
    
    func showEmotionLabels(identifier: String, confidence: Float) {
        self.emotionIdentifierLabel.text = identifier
        self.emotionConfidenceLabel.text = String(format: "%.1f", confidence * 100) + "%"
        
        self.emotionLabel.isHidden = false
        self.emotionIdentifierLabel.isHidden = false
        self.emotionConfidenceLabel.isHidden = false
    }
    
    func hideAllLabels() {
        self.hideAgeLabels()
        self.hideGenderLabels()
        self.hideEmotionLabels()
    }
}
