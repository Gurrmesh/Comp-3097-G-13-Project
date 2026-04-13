// AddTaskView.swift
// COMP3097 – Group 13 | Gurrmesh Singgh (101471817)

import SwiftUI

struct AddTaskView: View {
    @Environment(\.managedObjectContext) private var ctx
    @Environment(\.dismiss) private var dismiss

    @State private var title       = ""
    @State private var description = ""
    @State private var category    = "Personal"
    @State private var priority    = "Medium"
    @State private var dueDate     = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    @State private var showAlert   = false

    let categories = ["Personal", "Work", "Study", "Health", "Other"]
    let priorities = ["High", "Medium", "Low"]

    var body: some View {
        NavigationStack {
            Form {

                // MARK: Info
                Section("Task Info") {
                    TextField("Title *", text: $title)
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

                // MARK: Settings
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

                    DatePicker("Due Date & Time",
                               selection: $dueDate,
                               displayedComponents: [.date, .hourAndMinute])
                }

                // MARK: Preview badge
                Section("Preview") {
                    HStack {
                        Text(title.isEmpty ? "Task title" : title)
                            .foregroundColor(title.isEmpty ? .secondary : .primary)
                            .font(.system(size: 15))
                        Spacer()
                        StatusBadge(status: "Pending")
                    }
                    HStack(spacing: 6) {
                        Circle()
                            .fill(PriorityMeta.meta(for: priority).color)
                            .frame(width: 8, height: 8)
                        CategoryTag(category: category)
                        Spacer()
                        Text(dueDate, style: .date)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveTask() }
                        .fontWeight(.bold)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("Title Required", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please enter a title for your task.")
            }
        }
    }

    private func saveTask() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { showAlert = true; return }

        let t              = TaskEntity(context: ctx)
        t.id               = UUID()
        t.title            = trimmed
        t.taskDescription  = description
        t.category         = category
        t.priority         = priority
        t.dueDate          = dueDate
        t.createdAt        = Date()
        t.status           = "Pending"

        PersistenceController.shared.save()
        dismiss()
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
            .environment(\.managedObjectContext,
                         PersistenceController.preview.container.viewContext)
    }
}
