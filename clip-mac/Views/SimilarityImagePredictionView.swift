//
//  SimilarityImagePredictionView.swift
//  clip-mac
//
//  Created by Jainam Sunilkumar Bhavasar on 02/03/23.
//

import Foundation
import SwiftUI

struct SimilarityImagePredictionView: View {
    let similarityImagePredictions: [SimilarityService.SimilarityImagePrediction]

    var body: some View {
        List(similarityImagePredictions,id: \.id) { similarityImagePrediction in
           // let url = URL(fileURLWithPath: similarityImagePrediction.imagePrediction.path).absoluteURL
         //   let nsImage = NSImage(contentsOf: url)!
            HStack {
//                Image(nsImage: nsImage)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 50, height: 50)
                Text("\(similarityImagePrediction.similarity)")
            }
        }
    }
}
