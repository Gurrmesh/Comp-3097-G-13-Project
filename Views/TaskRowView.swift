// TaskRowView.swift
// COMP3097 – Group 13 | Gurrmesh Singgh (101471817)
//
// Reusable task row used across Dashboard, TaskList, and Categories.
// Shows: completion toggle, title, category, due date, priority dot,
//        due-soon badge, status badge.

import SwiftUI

struct TaskRowView: View {
    @ObservedObject var task: TaskEntity
    @Environment(\.managedObjectContext) private var ctx

    var body: some View {
        HStack(spacing: 12) {

            // MARK: Completion toggle
            Button {
                withAnimation(.spring(response: 0.3)) {
                    task.status = task.computedStatus == "Completed" ? "Pending" : "Completed"
                    PersistenceController.shared.save()
                }
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(
                            task.computedStatus == "Completed" ? Color.green : Color(.separator),
                            lineWidth: 2
                        )
                        .frame(width: 26, height: 26)

                    if task.computedStatus == "Completed" {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 26, height: 26)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            // MARK: Task content
            VStack(alignment: .leading, spacing: 4) {

                // Title
                Text(task.wrappedTitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(task.computedStatus == "Completed" ? .secondary : .primary)
                    .strikethrough(task.computedStatus == "Completed", color: .secondary)
                    .lineLimit(1)

                // Meta row
                HStack(spacing: 6) {
                    // Priority dot
                    Circle()
                        .fill(PriorityMeta.meta(for: task.wrappedPriority).color)
                        .frame(width: 7, height: 7)

                    // Category
                    Text(task.wrappedCategory)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)

                    Text("·")
                        .foregroundColor(.secondary)

                    // Due date
                    if let due = task.dueDate {
                        Text(due, style: .date)
                            .font(.system(size: 12))
                            .foregroundColor(task.computedStatus == "Overdue" ? .red : .secondary)
                    }

                    // Due-soon badge
                    if task.isDueSoon {
                        Text("Due Soon")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .foregroundColor(.orange)
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()

            // MARK: Status badge
            StatusBadge(status: task.computedStatus)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }
}

// MARK: – StatusBadge
struct StatusBadge: View {
    let status: String

    private var badgeColor: Color {
        switch status {
        case "Completed":    return .green
        case "Overdue":      return .red
        case "In Progress":  return .blue
        default:             return Color(.systemGray4)
        }
    }
    private var textColor: Color {
        switch status {
        case "Completed":    return .green
        case "Overdue":      return .red
        case "In Progress":  return .blue
        default:             return .secondary
        }
    }

    var body: some View {
        Text(status)
            .font(.system(size: 11, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(badgeColor.opacity(0.12))
            .foregroundColor(textColor)
            .clipShape(Capsule())
    }
}
