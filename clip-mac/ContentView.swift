//
//  ContentView.swift
//  clip-mac
//
//  Created by Jainam Sunilkumar Bhavasar on 27/02/23.
//

import SwiftUI
import CoreData
import CoreML
import CommonCrypto

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var model : ContentModel = ContentModel()
    let testImage :URL = Bundle.main.urlForImageResource("input")!
    let indexedEmbeddings : [MLMultiArray] = []
    private var columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    
    
    var body: some View {
        ScrollView(.vertical){
            VStack{
                Spacer()
                Button((model.directory_path ?? "Pick Directory")) {
                    onPickDirectoryButtonTap()
                }
                Text(model.indexing_status ?? "" )

                if( !model.top10Predictions.isEmpty){
                    Text("Input Image")
                    if let nsImage = NSImage(contentsOf: model.image_url ) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .frame(width: 200,height: 200.0)
                            .onTapGesture(count:2){
                                pickImage()
                            }
                    }
                    Text("Resuts")
                }
               

                LazyVGrid(columns:[GridItem(.adaptive(minimum: 200),spacing: 0)]){
                    ForEach(model.top10Predictions){ sip in
                        VStack{
                            if let nsImage = NSImage(contentsOf: URL(fileURLWithPath: sip.imagePrediction.path) ) {
                                Image(nsImage: nsImage)
                                    .resizable()
                                    .frame(width: 200,height: 200.0)
                                    .onTapGesture(count:2) {
                                        let workspace = NSWorkspace.shared
                                        let fileURL = URL(fileURLWithPath: sip.imagePrediction.path)
                                        workspace.activateFileViewerSelecting([fileURL])
                                    }.shadow(radius: 10)
                                Text(sip.imagePrediction.path.replacingOccurrences(of: model.directory_path ?? " ", with: "")).textSelection(.enabled)
                                Text(String(sip.similarity))
                            }
                        }
                       
                    }

                }
                
               
                
               
            }.onDrop(of: [.fileURL],isTargeted: nil){ providers in
                return processNewImage(providers)
            }
        }
    }
    
    
    
    fileprivate func processNewImage(_ providers: [NSItemProvider]) -> Bool {
        if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
            let _ = provider.loadObject(ofClass: URL.self) { object, error in
                if let url = object {
                    
                    DispatchQueue.main.async {
                        model.image_url = url
                        
                        if( model.predictions != nil){
                            let top10SIP = SimilarityService.getTopKSimilarImagePredictions(
                                indexed_predictions: model.predictions ?? [],
                                queryPrediction:  ModelManager.shared.predict(path: model.image_url.path),
                                k: nil)
                            
                            model.top10Predictions = top10SIP
                            
                                    
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
    
    fileprivate func pickImage(){
        let dialog = NSOpenPanel();
        dialog.canChooseDirectories = false;
        dialog.canChooseFiles = true
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            if(result == nil) {return}
            
            model.image_url = result!
            
            if( model.predictions != nil){
                let top10SIP = SimilarityService.getTopKSimilarImagePredictions(
                    indexed_predictions: model.predictions ?? [],
                    queryPrediction:  ModelManager.shared.predict(path: model.image_url.path),
                    k: nil)
                
                model.top10Predictions = top10SIP
//                            model.top10Predictions?.forEach{
//                                model.indexing_status?.append($0.imagePrediction.path + "\n")
//                            }
                
            }
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
                    k: nil)
                
                model.top10Predictions = top10SIP

                
                
            }
        }
    }

    
}

    


