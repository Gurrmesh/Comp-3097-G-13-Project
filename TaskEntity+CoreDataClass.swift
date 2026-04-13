// TaskEntity+CoreDataClass.swift
// COMP3097 – Group 13 | Gurrmesh Singgh (101471817)
//
// Manual NSManagedObject subclass — set Codegen to "Manual/None" in the model editor.
//
// Core Data entity: TaskEntity
// Attributes:
//   id               UUID
//   title            String
//   taskDescription  String   ("description" is reserved by NSObject)
//   category         String
//   priority         String   "High" | "Medium" | "Low"
//   status           String   "Pending" | "In Progress" | "Completed" | "Overdue"
//   dueDate          Date
//   createdAt        Date

import Foundation
import CoreData

@objc(TaskEntity)
public class TaskEntity: NSManagedObject, Identifiable {}

extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var id:               UUID?
    @NSManaged public var title:            String?
    @NSManaged public var taskDescription:  String?
    @NSManaged public var category:         String?
    @NSManaged public var priority:         String?
    @NSManaged public var status:           String?
    @NSManaged public var dueDate:          Date?
    @NSManaged public var createdAt:        Date?

    // MARK: – Safe unwrapped accessors
    var wrappedTitle:    String { title            ?? "Untitled"  }
    var wrappedDesc:     String { taskDescription  ?? ""          }
    var wrappedCategory: String { category         ?? "Personal"  }
    var wrappedPriority: String { priority         ?? "Medium"    }
    var wrappedStatus:   String { status           ?? "Pending"   }
    var wrappedCreated:  Date   { createdAt        ?? Date()      }

    // MARK: – Auto-computed status
    /// Returns "Overdue" automatically if past due and not Completed.
    var computedStatus: String {
        if wrappedStatus == "Completed" { return "Completed" }
        if let due = dueDate,
           Calendar.current.startOfDay(for: due) < Calendar.current.startOfDay(for: Date()) {
            return "Overdue"
        }
        return wrappedStatus
    }

    // MARK: – Due-soon detection (within 24 hours)
    var isDueSoon: Bool {
        guard computedStatus != "Completed", computedStatus != "Overdue" else { return false }
        guard let due = dueDate else { return false }
        let hours = due.timeIntervalSince(Date()) / 3600
        return hours >= 0 && hours <= 24
    }

    // MARK: – Sort helpers
    var prioritySortOrder: Int {
        switch wrappedPriority {
        case "High":   return 0
        case "Medium": return 1
        default:       return 2
        }
    }

    var statusSortOrder: Int {
        switch computedStatus {
        case "Overdue":     return 0
        case "In Progress": return 1
        case "Pending":     return 2
        default:            return 3
        }
    }
}
