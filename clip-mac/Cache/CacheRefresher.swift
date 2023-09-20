//
//  CacheRefresher.swift
//  clip-mac
//
//  Created by Jainam Sunilkumar Bhavasar on 17/03/23.
//

import Foundation
import AppKit
import RealmSwift
func refresh_cache(directory_path : String?,progress: @escaping (Int,Int)->()) -> [ImageModel] {
    if(directory_path == nil) {return []}

    let imageModels = getImagePaths(inDirectory: directory_path!).map{ImageModel($0)}

    let database = FileHashDatabase()
    
    for (i,model) in imageModels.enumerated() {
        if(database.isPresent(imageModel: model)){
            model.prediction = database.getModel(model)!.prediction
        }else {
            model.updatePrediction()
            database.add(imageModels: [model])
        }
        progress(i+1,imageModels.count)
    }
   
    return imageModels
}
