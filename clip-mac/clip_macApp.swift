//
//  clip_macApp.swift
//  clip-mac
//
//  Created by Jainam Sunilkumar Bhavasar on 27/02/23.
//

import SwiftUI

@main
struct clip_macApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear{
                    DispatchQueue.global(qos:.userInitiated).async {
                        gitTest()
                    }
                }
        }
    }
    
    
}
