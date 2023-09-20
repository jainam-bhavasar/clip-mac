//
//  ContentViewController.swift
//  clip-mac
//
//  Created by Jainam Sunilkumar Bhavasar on 02/03/23.
//

import Foundation

class ContentModel : ObservableObject{
    @Published var directory_path : String?
    @Published var indexing_status : String?
    @Published var image_url : URL = Bundle.main.urlForImageResource("input.png")!
    @Published var predictions : [ImageModel] = []
}
