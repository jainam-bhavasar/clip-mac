//
//  Database.swift
//  clip-mac
//
//  Created by Jainam Sunilkumar Bhavasar on 17/03/23.
//

import Foundation
import RealmSwift

class FileHashDatabase {
    private var realm : Realm

    init() {
        self.realm = try! Realm()
    }
    
    func add(imageModels : [ImageModel]) {
        try? realm.write{
            for model in imageModels {
                print("model : \(model.path) hash : \(model.fileHash)")
                if(!isPresent(imageModel: model)){
                    realm.add(model)
                }
            }
        }
    }
    
    func delete(imageModels : [ImageModel]){
        try! realm.write{
            imageModels.forEach{realm.delete($0)}
        }
    }
    
    func deleteAll(){
        try! realm.write{
            realm.deleteAll()
        }
    }
    
    func isPresent(imageModel : ImageModel ) -> Bool{
        let object = realm.object(ofType: ImageModel.self, forPrimaryKey: imageModel.fileHash)
        return object != nil
    }
    
    func getAll() -> Results<ImageModel> {
        return realm.objects(ImageModel.self)
    }
    
    func getModel(_ imageModel : ImageModel) -> ImageModel? {
        return realm.object(ofType: ImageModel.self, forPrimaryKey: imageModel.fileHash)
    }
    
    
}


