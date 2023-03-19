//
//  IOUtils.swift
//  clip-mac
//
//  Created by Jainam Sunilkumar Bhavasar on 17/03/23.
//

import Foundation
import AppKit

func getImagePaths(inDirectory directoryPath: String) -> [String] {
    let fm = FileManager.default
    guard let items = fm.enumerator(atPath: directoryPath)?.allObjects as? [String] else{
        return []
    }
    var images = items.filter{$0.hasSuffix("png") || $0.hasSuffix("jpg") || $0.hasSuffix("svg")  }
    images = images.map{"\(directoryPath)/\($0)" }
    return images
}

func getImageUrls(inDirectory directoryPath: String) -> [URL] {
    let imagePaths = getImagePaths(inDirectory: directoryPath)
    return imagePaths.map{URL(filePath: $0)}
}

func getImages(inDirectory directoryPath : String)->[NSImage] {
    let imagePaths = getImageUrls(inDirectory: directoryPath)
    return imagePaths.map{NSImage(byReferencing: $0)}
}
