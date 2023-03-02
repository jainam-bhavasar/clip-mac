//
//  SimilarityUtils.swift
//  clip-mac
//
//  Created by Jainam Sunilkumar Bhavasar on 01/03/23.
//

import Foundation
import CoreML




class SimilarityService{
    static fileprivate func dot_product(_ array1:MLMultiArray,_ array2:MLMultiArray) -> Double {
        var sum = 0.0
        for i in 0...(array1.shape[1].intValue-1){
            sum += array1[i].doubleValue * array2[i].doubleValue
        }
        return sum
    }

    fileprivate static func getSimilarityArray(indexed_enitities:[MLMultiArray],query_entity:MLMultiArray) -> [Double] {
        return indexed_enitities.map{entity in dot_product(entity, query_entity)}
    }
    
     static func getTopKSimilarWithIndex(indexed_enitities:[MLMultiArray],query_entity:MLMultiArray, k:Int) -> [(Double,Int)]{
        let similarity_array = getSimilarityArray(indexed_enitities: indexed_enitities, query_entity: query_entity)
        let sorted_similarity_array_with_index = zip(similarity_array, (0...(similarity_array.count-1))).sorted{$0.0>$1.0}
        return Array(sorted_similarity_array_with_index[0...min(indexed_enitities.count-1, k)])
    }
    
    struct SimilarityImagePrediction :Identifiable {
        let id  = UUID()
        
        
        let imagePrediction : ImagePrediction
        let similarity : Double
    }
    
    static func getTopKSimilarImagePredictions(indexed_predictions : [ImagePrediction],queryPrediction : ImagePrediction, k : Int) -> [SimilarityImagePrediction]{
        let similarities =  getSimilarityArray(indexed_enitities: indexed_predictions.map{$0.prediction}, query_entity: queryPrediction.prediction)
        let similarityImagePredictions = similarities.enumerated().map{SimilarityImagePrediction(imagePrediction: indexed_predictions[$0.offset], similarity: $0.element)}
        let top_k_sip = similarityImagePredictions.sorted{$0.similarity > $1.similarity}
        return Array(top_k_sip[0...min(top_k_sip.count-1, k)])
        
    }
    
    
}
