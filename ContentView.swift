// ContentView.swift
// COMP3097 – Group 13 | Gurrmesh Singgh (101471817)

import SwiftUI

struct ContentView: View {
    @State private var showLaunch = true

    var body: some View {
        ZStack {
            MainTabView()

            if showLaunch {
                LaunchScreenView(showLaunch: $showLaunch)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext,
                         PersistenceController.preview.container.viewContext)
    }
}
