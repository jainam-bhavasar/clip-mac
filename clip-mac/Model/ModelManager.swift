//
//  ModelManager.swift
//  clip-mac
//
//  Created by Jainam Sunilkumar Bhavasar on 01/03/23.
//

import Foundation
import CoreML
 class ModelManager {
    static let shared = ModelManager()
    
    private let lock = NSLock()
    private var _model: clip_vitb32?
    
     init() {
         _model = loadModel()
     }
     
    var model: clip_vitb32 {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _model ?? loadModel()
        }
        set {
            lock.lock()
            _model = newValue
            lock.unlock()
        }
    }
      
   fileprivate  func loadModel() -> clip_vitb32{
      let model = try! clip_vitb32(configuration: MLModelConfiguration())
      return model
   }
   
     func predict(path:String) -> ImagePrediction {
         let url = URL(fileURLWithPath: path).absoluteURL
         let input = try? clip_vitb32Input(input_1At: url )
         let output :clip_vitb32Output = try! ModelManager.shared.model.prediction(input: input!)
         return ImagePrediction(path: path, prediction: output.var_1285)
     }
                                                  
}
