//
//  ContentView.swift
//  clip-mac
//
//  Created by Jainam Sunilkumar Bhavasar on 27/02/23.
//

import SwiftUI
import CoreData
import CoreML


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var model : ContentModel = ContentModel()
    let testImage :URL = Bundle.main.urlForImageResource("input")!
    let indexedEmbeddings : [MLMultiArray] = []
    
    
    
    var body: some View {
        ScrollView(.vertical){
            VStack{
                List(model.top10Predictions ?? [],id: \.id){ sip in
                    Text(sip.imagePrediction.path)
                }
                Spacer()
                Button((model.directory_path ?? "Pick Directory")) {
                    onPickDirectoryButtonTap()
                }
                Text(model.indexing_status ?? "" )
                if let nsImage = NSImage(contentsOf: model.image_url ) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .frame(width: 200,height: 200.0)
                        .onTapGesture {
                            print(model.top10Predictions?.count)
                        }
                }
                
               // SimilarityImagePredictionView(similarityImagePredictions: model.top10Predictions ?? [])
                
               
            }.onDrop(of: [.fileURL],isTargeted: nil){ providers in
                return processNewImage(providers)
            }
        }
    }
    
    
    
    fileprivate func processNewImage(_ providers: [NSItemProvider]) -> Bool {
        if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
            let _ = provider.loadObject(ofClass: URL.self) { object, error in
                if let url = object {
                    print("url: \(url)")
                    
                    DispatchQueue.main.async {
                        model.image_url = url
                        
                        if( model.predictions != nil){
                            let top10SIP = SimilarityService.getTopKSimilarImagePredictions(
                                indexed_predictions: model.predictions ?? [],
                                queryPrediction:  ModelManager.shared.predict(path: model.image_url.path),
                                k: 10)
                            
                            model.top10Predictions = top10SIP
//                            model.top10Predictions?.forEach{
//                                model.indexing_status?.append($0.imagePrediction.path + "\n")
//                            }
                            
                        }
                    }
                    
                    
                    
                   
                }
            }
            return true
        }
        return false
    }
    
    
    fileprivate func pickDirectory(){
        let dialog = NSOpenPanel();
        dialog.canChooseDirectories = true;
        dialog.canChooseFiles = false
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            if(result == nil) {return}
            
            model.directory_path = result!.path
        }
    }
    
    
    fileprivate func onPickDirectoryButtonTap() {
        pickDirectory()
        model.indexing_status = "Indexing Started"
        DispatchQueue(label: "jainam.serial.onPickDirectoryButtonTap.queue").async {
            
            let predictions =  index_files(path: model.directory_path){ (progress,total) in
                DispatchQueue.main.async {
                    model.indexing_status = "Indexing : \(progress)/\(total)"
                }
            }
            
            DispatchQueue.main.async {
                model.predictions = predictions
                model.indexing_status = ""
                
               
                let top10SIP = SimilarityService.getTopKSimilarImagePredictions(
                    indexed_predictions: predictions,
                    queryPrediction:  ModelManager.shared.predict(path: model.image_url.path),
                    k: 10)
                
                model.top10Predictions = top10SIP
//                model.top10Predictions?.forEach{
//                    model.indexing_status?.append($0.imagePrediction.path + "\n")
//                }
//                top10SIP.forEach{
//                    print($0.imagePrediction.path)
//                }
                
                
                
            }
        }
    }

    
}

    


