//
//  MLModelUtils.swift
//  clip-mac
//
//  Created by Jainam Sunilkumar Bhavasar on 17/03/23.
//

import Foundation
import RealmSwift
import CoreML

extension MLMultiArray {
    var RealmList : List<Double> {
        let list = List<Double>()
        for i in 0...(self.shape[1].intValue-1){
            list.append(self[i].doubleValue)
        }
        return list
    }
    
}

extension List<Double> {
    var normalise : List<Double> {
        let l2 = sqrt(self.map { $0 * $0 }.reduce(0, +))
        let normalized_array : List<Double> = List()
        self.forEach{
            normalized_array.append($0/l2)
        }
        return normalized_array
    }
}

extension [ImageModel] {
    var softmax : [ImageModel] {
        let expValues = self.map { exp($0.similarity) }
        let sumExp = expValues.reduce(0, +)
        for (i,model) in self.enumerated() {
            model.similarity = 100*expValues[i]/sumExp
        }
        
        return self
    }
}

