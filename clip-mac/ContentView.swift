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
    @StateObject var contentModel : ContentModel = ContentModel()
    let indexedEmbeddings : [MLMultiArray] = []
    private var columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    
    
    var body: some View {
        ScrollView(.vertical){
            VStack{
                Spacer()
                Button((contentModel.directory_path ?? "Pick Directory")) {
                    onPickDirectoryButtonTap()
                }
                Text(contentModel.indexing_status ?? "" )

                //Input image
                if( !contentModel.predictions.isEmpty){
                    Text("Input Image")
                    if let nsImage = NSImage(contentsOf: contentModel.image_url ) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .frame(width: 150 , height: 150)
                            .onTapGesture(count:2){
                                pickImage()
                            }
                    }
                    Text("Resuts")
                }
               

                LazyVGrid(columns:[GridItem(.adaptive(minimum: 200),spacing: 0)]){
                    ForEach(contentModel.predictions.sorted(by: {$0.similarity > $1.similarity}),id: \.path){ imageModel in
                        VStack{
                            if let nsImage = NSImage(contentsOf: URL(fileURLWithPath: imageModel.path) ) {
                                Image(nsImage: nsImage)
                                    .resizable()
                                    .frame(width: 200,height: 200.0)
                                    .onTapGesture(count:2) {
                                        let workspace = NSWorkspace.shared
                                        let fileURL = URL(fileURLWithPath: imageModel.path)
                                        workspace.activateFileViewerSelecting([fileURL])
                                    }.shadow(radius: 10)
                                Text(imageModel.path.replacingOccurrences(of: contentModel.directory_path ?? " ", with: "")).textSelection(.enabled)
                                Text(String(format: "%.2f", imageModel.similarity))
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
                        if(!["svg","png","jpg","jpeg"].contains(url.pathExtension)) {return }
                        contentModel.image_url = url
                    }
                    updateResults()
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
            contentModel.directory_path = result!.path
        }else {
            return
        }
    }
    
    fileprivate func pickImage(){
        let dialog = NSOpenPanel();
        dialog.canChooseDirectories = false;
        dialog.canChooseFiles = true
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            if(result == nil) {return}
            contentModel.image_url = result!
            updateResults()
        }
    }
    
    fileprivate func updateResults(){
        DispatchQueue(label: "jainam.serial.onPickDirectoryButtonTap.queue").async {
            DispatchQueue.main.async {
                contentModel.indexing_status = "Indexing Started"
            }
            let refreshedImageModels = refresh_cache(directory_path: contentModel.directory_path){(progress,total) in
                DispatchQueue.main.async {
                    self.contentModel.indexing_status = "Indexing \(progress)/\(total)"
                }
                }
            let testImageModel = ImageModel(contentModel.image_url.path)
            testImageModel.updatePrediction()
            refreshedImageModels.forEach{$0.updateSimlarity(imageModel: testImageModel)}
            DispatchQueue.main.async {
                contentModel.predictions = refreshedImageModels
                self.contentModel.indexing_status = ""
            }
        }
    }
    
    fileprivate func onPickDirectoryButtonTap() {
        pickDirectory()
        updateResults()
    }

    
}

    


