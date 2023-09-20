//
//  MD5HashingService.swift
//  clip-mac
//
//  Created by Jainam Sunilkumar Bhavasar on 04/03/23.
//

import Foundation
import AppKit
import CryptoKit



extension NSImage {
    var SHA256 : String {
        let imageData = self.tiffRepresentation(using: .none, factor: 1)
        return CryptoKit.SHA256.hash(data: imageData!).description
    }
}

//func newFilesAdded(_ cachedHashes : [String] , _ currentFileInfos : [FileInfo] ) -> [FileInfo]{
//    return currentFileInfos.filter{ fileInfo in
//        cachedHashes.contains(fileInfo.hash)
//    }
//}


