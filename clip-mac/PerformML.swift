//
//  PerformML.swift
//  clip-mac
//
//  Created by Jainam Sunilkumar Bhavasar on 27/02/23.
//

import Foundation
import CoreML
import Vision
import AppKit
import SwiftUI
import CoreML
import Cocoa
import Accelerate
import RealmSwift

struct ImagePrediction {
    let path : String
    let prediction : MLMultiArray
}

func loadModel() -> clip_vitb32{
    let model = try! clip_vitb32(configuration: MLModelConfiguration())
    return model
}

func index_files(path:String?, progress : @escaping (Int,Int)->()) -> [ImagePrediction]{
    let startTime = Date()
    if(path == nil) {return []}
    
    //Input
    let paths = getImagePaths(inDirectory: path!)
    var predictions : [ImagePrediction] = []
    for (i,path) in paths.enumerated(){
        let prediction = ModelManager.shared.predict(path: path)
        progress(i+1,paths.count)
        predictions.append(prediction)
    }

    return predictions
    
}

func getTopKSimilarImages(url : URL, indexedPredictions : [ImagePrediction]) -> [SimilarityService.SimilarityImagePrediction]{
    let queryPrediction = ModelManager.shared.predict(path: url.path)
    let top_k_sip : [SimilarityService.SimilarityImagePrediction] =
    SimilarityService.getTopKSimilarImagePredictions(indexed_predictions: indexedPredictions, queryPrediction: queryPrediction, k: 10)
    return top_k_sip
}


 
