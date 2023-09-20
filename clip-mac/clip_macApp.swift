//
//  clip_macApp.swift
//  clip-mac
//
//  Created by Jainam Sunilkumar Bhavasar on 27/02/23.
//

import SwiftUI

@main
struct clip_macApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear{
                    ModelManager.init()
                }
        }
    }
    
    
}
