//
//  Instituto_MusicalApp.swift
//  Instituto Musical
//
//  Created by Jonathan Padilla on 2/13/26.
//

import SwiftUI
import CoreData

@main
struct Instituto_MusicalApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
