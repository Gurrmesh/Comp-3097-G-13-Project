// CategoriesView.swift
// COMP3097 – Group 13 | Gurrmesh Singgh (101471817)
//
// Features:
//  • Category rows with task count, completed count
//  • Per-category progress bar
//  • Drill-down to CategoryDetailView (filtered task list)

import SwiftUI
import CoreData

struct CategoriesView: View {
    @Environment(\.managedObjectContext) private var ctx

    @FetchRequest(
        sortDescriptors: [],
        animation: .default
    )
    private var allTasks: FetchedResults<TaskEntity>

    var body: some View {
        List {
            Section(header: Text("All Categories")) {
                ForEach(CategoryMeta.all, id: \.name) { meta in
                    NavigationLink(destination: CategoryDetailView(category: meta.name)) {
                        CategoryRowView(
                            meta:      meta,
                            total:     count(for: meta.name),
                            completed: completedCount(for: meta.name)
                        )
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.large)
    }

    private func count(for cat: String) -> Int {
        allTasks.filter { $0.wrappedCategory == cat }.count
    }
    private func completedCount(for cat: String) -> Int {
        allTasks.filter { $0.wrappedCategory == cat && $0.computedStatus == "Completed" }.count
    }
}

// MARK: – CategoryRowView
struct CategoryRowView: View {
    let meta:      CategoryMeta
    let total:     Int
    let completed: Int

    private var progress: Double {
        total == 0 ? 0 : Double(completed) / Double(total)
    }

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(meta.color.opacity(0.12))
                    .frame(width: 42, height: 42)
                Image(systemName: meta.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(meta.color)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(meta.name)
                        .font(.system(size: 16, weight: .medium))
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(meta.color)
                }

                Text("\(total) task\(total != 1 ? "s" : "") · \(completed) completed")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(.systemFill))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(meta.color)
                            .frame(width: geo.size.width * progress, height: 4)
                            .animation(.easeInOut(duration: 0.4), value: progress)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: – CategoryDetailView
struct CategoryDetailView: View {
    let category: String

    @FetchRequest private var tasks: FetchedResults<TaskEntity>
    @State private var showAdd = false

    init(category: String) {
        self.category = category
        _tasks = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \TaskEntity.dueDate, ascending: true)],
            predicate: NSPredicate(format: "category == %@", category),
            animation: .default
        )
    }

    private var meta: CategoryMeta { CategoryMeta.meta(for: category) }

    var body: some View {
        Group {
            if tasks.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: meta.icon)
                        .font(.system(size: 52))
                        .foregroundColor(meta.color.opacity(0.4))
                    Text("No tasks in \(category)")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Tap + to add your first task here")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                List {
                    ForEach(tasks) { task in
                        NavigationLink(destination: TaskDetailView(task: task)) {
                            TaskRowView(task: task)
                        }
                        .listRowInsets(EdgeInsets())
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                // ctx not available here; handled via environment
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAdd = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                }
            }
        }
        .sheet(isPresented: $showAdd) {
            AddTaskView()
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { CategoriesView() }
            .environment(\.managedObjectContext,
                         PersistenceController.preview.container.viewContext)
    }
}
