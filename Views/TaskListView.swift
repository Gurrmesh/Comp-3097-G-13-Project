// TaskListView.swift
// COMP3097 – Group 13 | Gurrmesh Singgh (101471817)
//
// Features:
//  • Category filter pills
//  • Real-time search (title, notes, category)
//  • Four sort modes: Due Date, Priority, Status, Category
//  • Swipe-to-complete and swipe-to-delete on each row
//  • Due-soon and overdue row tinting

import SwiftUI
import CoreData

// MARK: – Sort mode enum
enum SortMode: String, CaseIterable, Identifiable {
    case dueDate   = "Due Date"
    case priority  = "Priority"
    case status    = "Status"
    case category  = "Category"
    var id: String { rawValue }
}

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var ctx

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskEntity.dueDate, ascending: true)],
        animation: .default
    )
    private var allTasks: FetchedResults<TaskEntity>

    @State private var selectedCategory: String    = "All"
    @State private var searchText:       String    = ""
    @State private var sortMode:         SortMode  = .dueDate
    @State private var showAddTask:      Bool      = false

    let categories = ["All", "Personal", "Work", "Study", "Health", "Other"]

    // MARK: – Filtered + sorted list
    private var displayedTasks: [TaskEntity] {
        var list = Array(allTasks)

        // Category filter
        if selectedCategory != "All" {
            list = list.filter { $0.wrappedCategory == selectedCategory }
        }

        // Search filter
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            list = list.filter {
                $0.wrappedTitle.lowercased().contains(q)
                || $0.wrappedDesc.lowercased().contains(q)
                || $0.wrappedCategory.lowercased().contains(q)
            }
        }

        // Sort
        switch sortMode {
        case .dueDate:
            list.sort { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        case .priority:
            list.sort { $0.prioritySortOrder < $1.prioritySortOrder }
        case .status:
            list.sort { $0.statusSortOrder < $1.statusSortOrder }
        case .category:
            list.sort { $0.wrappedCategory < $1.wrappedCategory }
        }

        return list
    }

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Category filter pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { cat in
                        CategoryFilterPill(label: cat, isSelected: selectedCategory == cat) {
                            selectedCategory = cat
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .background(Color(.systemGroupedBackground))

            // MARK: Sort picker
            HStack(spacing: 8) {
                Text("Sort:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(SortMode.allCases) { mode in
                            SortPill(label: mode.rawValue, isActive: sortMode == mode) {
                                sortMode = mode
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .background(Color(.systemGroupedBackground))

            Divider()

            // MARK: Task list / empty state
            if displayedTasks.isEmpty {
                Spacer()
                EmptyStateView(
                    icon:     searchText.isEmpty ? "tray.fill" : "magnifyingglass",
                    title:    searchText.isEmpty ? "No tasks here" : "No results",
                    subtitle: searchText.isEmpty
                        ? "Tap + to add a task in this category"
                        : "Try a different search term"
                )
                Spacer()
            } else {
                List {
                    ForEach(displayedTasks) { task in
                        NavigationLink(destination: TaskDetailView(task: task)) {
                            TaskRowView(task: task)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(rowBackground(for: task))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            // Delete
                            Button(role: .destructive) {
                                deleteTask(task)
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            // Complete / Uncomplete
                            Button {
                                toggleComplete(task)
                            } label: {
                                Label(
                                    task.computedStatus == "Completed" ? "Undo" : "Done",
                                    systemImage: task.computedStatus == "Completed"
                                        ? "arrow.uturn.backward" : "checkmark.circle.fill"
                                )
                            }
                            .tint(.green)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .searchable(text: $searchText, prompt: "Search tasks…")
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Tasks")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAddTask = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskView()
        }
    }

    // MARK: – Row background tinting
    private func rowBackground(for task: TaskEntity) -> Color {
        if task.computedStatus == "Overdue" {
            return Color.red.opacity(0.06)
        } else if task.isDueSoon {
            return Color.orange.opacity(0.05)
        }
        return Color(.systemBackground)
    }

    // MARK: – Actions
    private func toggleComplete(_ task: TaskEntity) {
        task.status = task.computedStatus == "Completed" ? "Pending" : "Completed"
        PersistenceController.shared.save()
    }

    private func deleteTask(_ task: TaskEntity) {
        ctx.delete(task)
        PersistenceController.shared.save()
    }
}

// MARK: – CategoryFilterPill
struct CategoryFilterPill: View {
    let label:      String
    let isSelected: Bool
    let action:     () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .padding(.vertical, 7)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.accentColor : Color(.systemFill))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: – SortPill
struct SortPill: View {
    let label:    String
    let isActive: Bool
    let action:   () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .padding(.vertical, 5)
                .padding(.horizontal, 12)
                .background(isActive ? Color.accentColor : Color(.systemFill))
                .foregroundColor(isActive ? .white : .secondary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: – EmptyStateView
struct EmptyStateView: View {
    let icon:     String
    let title:    String
    let subtitle: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 52))
                .foregroundColor(.secondary.opacity(0.4))
            Text(title)
                .font(.system(size: 20, weight: .semibold))
            Text(subtitle)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { TaskListView() }
            .environment(\.managedObjectContext,
                         PersistenceController.preview.container.viewContext)
    }
}
