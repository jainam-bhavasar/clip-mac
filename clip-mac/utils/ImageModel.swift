//
//  SimilarityUtils.swift
//  clip-mac
//
//  Created by Jainam Sunilkumar Bhavasar on 01/03/23.
//

import Foundation
import CoreML
import RealmSwift
import CryptoKit

class ImageModel : Object,Identifiable,Codable {
    @Persisted(primaryKey: true) var fileHash : String
    @Persisted var prediction : List<Double> = List()
    var similarity : Double = 0.0
    var path : String = ""
    
    convenience init(_ path : String) {
        self.init()
        self.path = path
        let imageData = try! Data(contentsOf: URL(filePath: path))
        self.fileHash = CryptoKit.SHA256.hash(data: imageData).description
    }
    
    func updatePrediction(){
        self.prediction =  ModelManager.shared.predict(path: self.path).RealmList.normalise
    }
    
 
    
    func updateSimlarity(imageModel : ImageModel) {
        self.similarity =  (self.prediction.dotProduct(imageModel.prediction) ?? 0)*100
    }

    static func == (left: ImageModel,right:ImageModel) -> Bool {
        return left.hashValue == right.hashValue
    }
 
}



extension List where Element == Double {
    func dotProduct(_ other: List<Double>) -> Double? {
        var dot = 0.0
        for i in 0..<self.count {
            dot += self[i]*other[i]
        }
        return dot
    }
}



