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
        var list = List<Double>()
        for i in 0...(self.shape[1].intValue-1){
            list.append(self[i].doubleValue)
        }
        return list
    }
}
