// TaskSphereApp.swift
// COMP3097 – Group 13 | Gurrmesh Singgh (101471817)

import SwiftUI

@main
struct TaskSphereApp: App {
    let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext,
                             persistence.container.viewContext)
        }
    }
}
