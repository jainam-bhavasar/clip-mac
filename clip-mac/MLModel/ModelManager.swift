//
//  ModelManager.swift
//  clip-mac
//
//  Created by Jainam Sunilkumar Bhavasar on 01/03/23.
//

import Foundation
import CoreML
import SwiftDraw
import AppKit
import RealmSwift
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
        
         let input = createInput(url)
         let output :clip_vitb32Output = try! ModelManager.shared.model.prediction(input: input!)
         return ImagePrediction(path: path, prediction: output.var_1285)
     }
     
     
     
     func createInput(_ url: URL) -> clip_vitb32Input?{
         switch url.pathExtension {
             case "svg":
                 let image = NSImage(contentsOfSVGFile: url.path)
                 var imageRect = CGRect(x: 0, y: 0, width: image!.size.width, height: image!.size.height)
                 let cgImage = image!.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
                return try? clip_vitb32Input(input_1With: cgImage!)
             default :
                 return try? clip_vitb32Input(input_1At: url)
             }
             
     }
 }
     

     
                                                  

