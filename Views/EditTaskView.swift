// EditTaskView.swift
// COMP3097 – Group 13 | Gurrmesh Singgh (101471817)

import SwiftUI

struct EditTaskView: View {
    @ObservedObject var task: TaskEntity
    @Environment(\.dismiss) private var dismiss

    @State private var title:       String
    @State private var description: String
    @State private var category:    String
    @State private var priority:    String
    @State private var dueDate:     Date
    @State private var status:      String

    let categories = ["Personal", "Work", "Study", "Health", "Other"]
    let priorities = ["High", "Medium", "Low"]
    let statuses   = ["Pending", "In Progress", "Completed"]

    init(task: TaskEntity) {
        self.task    = task
        _title       = State(initialValue: task.wrappedTitle)
        _description = State(initialValue: task.wrappedDesc)
        _category    = State(initialValue: task.wrappedCategory)
        _priority    = State(initialValue: task.wrappedPriority)
        _dueDate     = State(initialValue: task.dueDate ?? Date())
        _status      = State(initialValue: task.wrappedStatus)
    }

    var body: some View {
        NavigationStack {
            Form {

                Section("Task Info") {
                    TextField("Title", text: $title)
                        .font(.system(size: 16))

                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("Notes (optional)")
                                .foregroundColor(Color(.placeholderText))
                                .font(.system(size: 16))
                                .padding(.top, 8)
                        }
                        TextEditor(text: $description)
                            .font(.system(size: 16))
                            .frame(minHeight: 80)
                    }
                }

                Section("Settings") {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            HStack {
                                Image(systemName: CategoryMeta.meta(for: cat).icon)
                                    .foregroundColor(CategoryMeta.meta(for: cat).color)
                                Text(cat)
                            }
                            .tag(cat)
                        }
                    }

                    Picker("Priority", selection: $priority) {
                        ForEach(priorities, id: \.self) { p in
                            HStack {
                                Circle()
                                    .fill(PriorityMeta.meta(for: p).color)
                                    .frame(width: 8, height: 8)
                                Text(p)
                            }
                            .tag(p)
                        }
                    }

                    Picker("Status", selection: $status) {
                        ForEach(statuses, id: \.self) { s in
                            HStack {
                                Circle().fill(s.statusColor).frame(width: 8, height: 8)
                                Text(s)
                            }
                            .tag(s)
                        }
                    }

                    DatePicker("Due Date & Time",
                               selection: $dueDate,
                               displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { save() }
                        .fontWeight(.bold)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        task.title           = trimmed
        task.taskDescription = description
        task.category        = category
        task.priority        = priority
        task.dueDate         = dueDate
        task.status          = status
        PersistenceController.shared.save()
        dismiss()
    }
}
