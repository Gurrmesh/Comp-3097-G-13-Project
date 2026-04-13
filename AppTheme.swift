// AppTheme.swift
// COMP3097 – Group 13 | Gurrmesh Singgh (101471817)
//
// Central design token file — colours, category metadata, priority metadata.
// Import this everywhere instead of scattering magic strings.

import SwiftUI

// MARK: – Category metadata
struct CategoryMeta {
    let name:  String
    let icon:  String   // SF Symbol name
    let color: Color
}

extension CategoryMeta {
    static let all: [CategoryMeta] = [
        CategoryMeta(name: "Personal", icon: "heart.fill",         color: .blue),
        CategoryMeta(name: "Work",     icon: "briefcase.fill",     color: .orange),
        CategoryMeta(name: "Study",    icon: "book.fill",          color: .green),
        CategoryMeta(name: "Health",   icon: "figure.walk",        color: .red),
        CategoryMeta(name: "Other",    icon: "ellipsis.circle.fill",color: .gray),
    ]

    static func meta(for name: String) -> CategoryMeta {
        all.first { $0.name == name } ?? all.last!
    }
}

// MARK: – Priority metadata
struct PriorityMeta {
    let name:  String
    let color: Color
    let icon:  String
}

extension PriorityMeta {
    static let all: [PriorityMeta] = [
        PriorityMeta(name: "High",   color: .red,    icon: "exclamationmark.3"),
        PriorityMeta(name: "Medium", color: .orange, icon: "exclamationmark.2"),
        PriorityMeta(name: "Low",    color: .green,  icon: "exclamationmark"),
    ]
    static func meta(for name: String) -> PriorityMeta {
        all.first { $0.name == name } ?? all[1]
    }
}

// MARK: – Status colours
extension String {
    /// Returns the semantic SwiftUI Color for a task status string.
    var statusColor: Color {
        switch self {
        case "Completed":   return .green
        case "Overdue":     return .red
        case "In Progress": return .blue
        default:            return Color(.systemGray3)
        }
    }
}

// MARK: – Date helpers
extension Date {
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }

    func formatted(style: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .short) -> String {
        let f = DateFormatter()
        f.dateStyle  = style
        f.timeStyle  = timeStyle
        return f.string(from: self)
    }
}
