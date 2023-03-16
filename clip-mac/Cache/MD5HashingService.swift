//
//  MD5HashingService.swift
//  clip-mac
//
//  Created by Jainam Sunilkumar Bhavasar on 04/03/23.
//

import Foundation
import CommonCrypto

func sha256Hash(forFileAtPath filePath: String) -> String? {
    // Open file for reading
    guard let file = FileHandle(forReadingAtPath: filePath) else {
        return nil
    }
    defer {
        file.closeFile()
    }
    
    // Set up the hash object
    var context = CC_SHA256_CTX()
    CC_SHA256_Init(&context)
    
    // Read the file in chunks and update the hash object
    let chunkSize = 1024 * 1024 // 1MB
    while autoreleasepool(invoking: {
        let data = file.readData(ofLength: chunkSize)
        if !data.isEmpty {
            data.withUnsafeBytes {
                _ = CC_SHA256_Update(&context, $0.baseAddress, CC_LONG(data.count))
            }
            return true // Continue reading
        } else {
            return false // End of file reached
        }
    }) {}
    
    // Finalize the hash object and create a string from the result
    var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    CC_SHA256_Final(&digest, &context)
    let sha256String = digest.map { String(format: "%02hhx", $0) }.joined()
    
    return sha256String
}

