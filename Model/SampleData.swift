//
//  SampleData.swift
//  ai 11
//
//  Created by Youngmok Cho on 2020-03-31.
//  Copyright © 2020 Youngmok Cho. All rights reserved.
//

import Foundation

struct Sample {
    let title: String
    let description: String
    let image: String
}

struct SampleData {
    let samples = [
        Sample(title: "Photo Object Detection", description: "Detect objects in a given image", image: "ic_photo"),
        Sample(title: "Real Time Object Detection", description: "Detect objects in real-time", image: "ic_camera"),
        Sample(title: "Facial Analysis", description: "Classify age, gender, emotion from a facial image", image: "ic_emotion")
    ]
    
}
