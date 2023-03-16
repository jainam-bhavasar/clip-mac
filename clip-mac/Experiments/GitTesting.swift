//
//  GitTesting.swift
//  clip-mac
//
//  Created by Jainam Sunilkumar Bhavasar on 04/03/23.
//

import Foundation

func gitTest(){

   
}

func executeCommand(_ command: String) -> String? {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
        let process = Process()
        process.currentDirectoryPath = homeDir
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let result = String(data: data, encoding: .utf8) {
               return result
            }
        } catch {
            print("Error executing command: \(error.localizedDescription)")
        }
    
        return nil
}
