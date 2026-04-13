// MainTabView.swift
// COMP3097 – Group 13 | Gurrmesh Singgh (101471817)

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "squares.below.rectangle")
            }

            NavigationStack {
                TaskListView()
            }
            .tabItem {
                Label("Tasks", systemImage: "checklist")
            }

            NavigationStack {
                CategoriesView()
            }
            .tabItem {
                Label("Categories", systemImage: "folder.fill")
            }
        }
        .onAppear {
            // Force tab bar to always be visible
            UITabBar.appearance().backgroundColor = UIColor.systemBackground
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environment(\.managedObjectContext,
                         PersistenceController.preview.container.viewContext)
    }
}
