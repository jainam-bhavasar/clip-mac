//
//  CacheRefresher.swift
//  clip-mac
//
//  Created by Jainam Sunilkumar Bhavasar on 17/03/23.
//

import Foundation
import AppKit
import RealmSwift
func refresh_cache(directory_path : String?) -> [ImageModel] {
    if(directory_path == nil) {return []}
    // get current Directory's files
    let imageModels = getImagePaths(inDirectory: directory_path!).map{ImageModel($0)}

    // Check if database has our files
    let database = FileHashDatabase()
    
    var addedOrModifiedModels : [ImageModel] = []
    for model in imageModels {
        if(database.isPresent(imageModel: model)){
            model.prediction = database.getModel(model)!.prediction
        }else {
            addedOrModifiedModels.append(model)
        }
    }
    //add to database
    addedOrModifiedModels.forEach{$0.updatePrediction()}
    database.add(imageModels : addedOrModifiedModels)
    print("refreshing done for \(addedOrModifiedModels.count) files")
    
    return imageModels
}
