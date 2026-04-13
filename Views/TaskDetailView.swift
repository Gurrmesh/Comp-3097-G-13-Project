// TaskDetailView.swift
// COMP3097 – Group 13 | Gurrmesh Singgh (101471817)

import SwiftUI

struct TaskDetailView: View {
    @ObservedObject var task: TaskEntity
    @Environment(\.managedObjectContext) private var ctx
    @Environment(\.dismiss) private var dismiss

    @State private var showEdit        = false
    @State private var showDeleteAlert = false

    var body: some View {
        List {

            // MARK: Due-soon banner
            if task.isDueSoon {
                Section {
                    HStack(spacing: 10) {
                        Image(systemName: "clock.badge.exclamationmark.fill")
                            .foregroundColor(.orange)
                        Text("This task is due within 24 hours")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.orange)
                    }
                    .listRowBackground(Color.orange.opacity(0.08))
                }
            }

            // MARK: Core info
            Section {
                DetailRow(label: "Title", value: task.wrappedTitle, large: true)
                DetailRow(label: "Notes", value: task.wrappedDesc.isEmpty ? "No notes added" : task.wrappedDesc)
            }

            // MARK: Details
            Section("Details") {

                HStack {
                    Label("Category", systemImage: CategoryMeta.meta(for: task.wrappedCategory).icon)
                        .foregroundColor(.secondary)
                        .font(.system(size: 15))
                    Spacer()
                    CategoryTag(category: task.wrappedCategory)
                }

                HStack {
                    Label("Priority", systemImage: PriorityMeta.meta(for: task.wrappedPriority).icon)
                        .foregroundColor(.secondary)
                        .font(.system(size: 15))
                    Spacer()
                    HStack(spacing: 6) {
                        Circle()
                            .fill(PriorityMeta.meta(for: task.wrappedPriority).color)
                            .frame(width: 8, height: 8)
                        Text(task.wrappedPriority)
                            .font(.system(size: 15))
                    }
                }

                HStack {
                    Label("Due Date", systemImage: "calendar")
                        .foregroundColor(.secondary)
                        .font(.system(size: 15))
                    Spacer()
                    Text(formattedDueDate)
                        .font(.system(size: 15))
                        .foregroundColor(task.computedStatus == "Overdue" ? .red : .primary)
                }

                HStack {
                    Label("Status", systemImage: "circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 15))
                    Spacer()
                    StatusBadge(status: task.computedStatus)
                }

                HStack {
                    Label("Created", systemImage: "plus.circle")
                        .foregroundColor(.secondary)
                        .font(.system(size: 15))
                    Spacer()
                    Text(formattedCreatedDate)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }

            // MARK: Change Status
            Section("Change Status") {
                ForEach(["Pending", "In Progress", "Completed"], id: \.self) { s in
                    Button {
                        withAnimation {
                            task.status = s
                            PersistenceController.shared.save()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(s.statusColor)
                                .frame(width: 10, height: 10)
                            Text(s)
                                .foregroundColor(.primary)
                                .font(.system(size: 16))
                            Spacer()
                            if task.computedStatus == s {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }

            // MARK: Delete
            Section {
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    HStack {
                        Spacer()
                        Label("Delete Task", systemImage: "trash.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") { showEdit = true }
                    .fontWeight(.semibold)
            }
        }
        .sheet(isPresented: $showEdit) {
            EditTaskView(task: task)
        }
        .alert("Delete Task?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                ctx.delete(task)
                PersistenceController.shared.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("\(task.wrappedTitle) will be permanently deleted.")
        }
    }

    // MARK: Helpers
    private var formattedDueDate: String {
        guard let due = task.dueDate else { return "No date set" }
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: due)
    }

    private var formattedCreatedDate: String {
        guard let created = task.createdAt else { return "" }
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: created)
    }
}

// MARK: DetailRow
struct DetailRow: View {
    let label: String
    let value: String
    var large: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(0.5)
            Text(value)
                .font(.system(size: large ? 18 : 15,
                              weight: large ? .semibold : .regular))
        }
        .padding(.vertical, 2)
    }
}

// MARK: CategoryTag
struct CategoryTag: View {
    let category: String
    var color: Color { CategoryMeta.meta(for: category).color }

    var body: some View {
        Text(category)
            .font(.system(size: 12, weight: .bold))
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}

// MARK: Preview
struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let ctx = PersistenceController.preview.container.viewContext
        let task = TaskEntity(context: ctx)
        task.id = UUID()
        task.title = "Sample Task"
        task.taskDescription = "A sample description"
        task.category = "Work"
        task.priority = "High"
        task.status = "In Progress"
        task.dueDate = Date()
        task.createdAt = Date()
        return NavigationStack {
            TaskDetailView(task: task)
        }
        .environment(\.managedObjectContext, ctx)
    }
}
