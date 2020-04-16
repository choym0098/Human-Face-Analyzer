//
//  ObjectDetectionViewController.swift
//  ai 11
//
//  Created by Youngmok Cho on 2020-04-05.
//  Copyright © 2020 Youngmok Cho. All rights reserved.
//

import UIKit
import Vision


class ObjectDetectionViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var selectedImageView: UIImageView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    var selectedImage: UIImage? {
        // performs an action when selectedImage changes
        didSet {
            self.selectedImageView.image = selectedImage
        }
    }
    
    var selectedciImage: CIImage? {
        get {
            if let selectedImage = self.selectedImage {
                return CIImage(image: selectedImage)
            } else {
                return nil
            }
        }
    }
    
    // only called once when a view controller is created
    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndicatorView.hidesWhenStopped = true
        self.activityIndicatorView.stopAnimating()
        self.categoryLabel.text = ""
        self.confidenceLabel.text = ""
    }
    
    @IBAction func addPhoto(_ sender: UIBarButtonItem) {
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
    
    // from UIImagePickerController Delegate
    // performs an action when an image is selected
    // info : contains image data
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // when an image is chosen, we switch back to the original screen
        picker.dismiss(animated: true)
        
        if let uiImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            self.selectedImage = uiImage
            self.categoryLabel.text = ""
            self.confidenceLabel.text = ""
            self.activityIndicatorView.startAnimating()
            // run detectObject() in a new thread
            DispatchQueue.global(qos: .userInitiated).async {
                self.detectObject()
            }
            
        }
    }
    
    // This function(particularly requestHandler.perform) takes a while
    // Hence, we use multithreadingn to speed up the process of running ML model in imagePickerController() function
    func detectObject() {
        // check if ciImage is defined
        if let ciImage = self.selectedciImage {
            do {
                let vnCoreMLModel = try VNCoreMLModel(for: Resnet50().model)
                // completionHandler : call this function upon a request
                let request = VNCoreMLRequest(model: vnCoreMLModel, completionHandler: self.handleObjectDetection)
                request.imageCropAndScaleOption = .centerCrop
                let requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
                // perform(var) : var - array of VNRequests
                // Since we have only one request here, simply pass in [request] to the function
                try requestHandler.perform([request])
                
            } catch {
                print(error)
            }
            
            
        }
    }
    
    // returns ML result given an image
    func handleObjectDetection(request: VNRequest, error:Error?) {
        if let result = request.results?.first as? VNClassificationObservation {
            
            // Update category and cocnfidence in MAIN thread
            // Any updates to UI have to occur in MAIN thread
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
                self.categoryLabel.text = result.identifier
                self.confidenceLabel.text = String(format: "%.1f", result.confidence * 100) + "%"
            }
        }
        
    }
    
    
    
}
