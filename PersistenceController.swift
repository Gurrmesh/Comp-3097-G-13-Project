// PersistenceController.swift
// COMP3097 – Group 13 | Gurrmesh Singgh (101471817)

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TaskSphere")

        if inMemory {
            container.persistentStoreDescriptions.first?.url =
                URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data failed to load: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // MARK: – Save helper
    func save() {
        let ctx = container.viewContext
        guard ctx.hasChanges else { return }
        do {
            try ctx.save()
        } catch {
            print("Core Data save error: \(error)")
        }
    }

    // MARK: – Preview store with sample tasks
    static var preview: PersistenceController = {
        let ctrl = PersistenceController(inMemory: true)
        let ctx  = ctrl.container.viewContext

        let cal   = Calendar.current
        let now   = Date()
        let yest  = cal.date(byAdding: .day, value: -1,  to: now)!
        let today = now
        let tom1  = cal.date(byAdding: .day, value:  1,  to: now)!
        let tom3  = cal.date(byAdding: .day, value:  3,  to: now)!
        let tom5  = cal.date(byAdding: .day, value:  5,  to: now)!

        let samples: [(String, String, String, String, String, Date)] = [
            ("Study for Midterm Exam",  "Review chapters 4–7 and practice problems", "Study",    "High",   "Overdue",     yest ),
            ("Buy Groceries",           "Eggs, bread, milk, fruit",                  "Personal", "Low",    "Pending",     today),
            ("Gym Workout",             "Chest and arms day — 1 hour",               "Health",   "Medium", "In Progress", today),
            ("Project Meeting",         "Team sync for capstone sprint 3",            "Work",     "High",   "Pending",     tom1 ),
            ("Read Research Paper",     "ML fairness paper for assignment",           "Study",    "Medium", "Pending",     tom3 ),
            ("Call Mom",               "Weekend catch-up",                           "Personal", "Low",    "Completed",   tom3 ),
            ("Submit Assignment",       "COMP3097 final submission",                  "Study",    "High",   "Overdue",     yest ),
            ("Morning Run",            "5 km around the park",                       "Health",   "Low",    "Completed",   today),
            ("Team Standup",           "Daily 15-min sync",                          "Work",     "Medium", "Pending",     tom1 ),
            ("Meal Prep Sunday",       "Cook for the week",                          "Health",   "Low",    "Pending",     tom5 ),
        ]

        for (title, desc, cat, pri, status, due) in samples {
            let t              = TaskEntity(context: ctx)
            t.id               = UUID()
            t.title            = title
            t.taskDescription  = desc
            t.category         = cat
            t.priority         = pri
            t.status           = status
            t.dueDate          = due
            t.createdAt        = now
        }
        try? ctx.save()
        return ctrl
    }()
}
