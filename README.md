# Comp-3097-G-13-Project
# TaskSphere – Xcode Setup Guide
## COMP3097 · Group 13 · Winter 2026 · Gurrmesh Singgh · 101471817

---

## File List

| File | Purpose |
|---|---|
| `TaskSphereApp.swift` | `@main` entry point, injects Core Data context |
| `PersistenceController.swift` | Core Data stack, `.shared` singleton, `.preview` with 10 sample tasks |
| `TaskEntity+CoreDataClass.swift` | `NSManagedObject` subclass — manual, Codegen = None |
| `AppTheme.swift` | Central design tokens: `CategoryMeta`, `PriorityMeta`, color helpers |
| `ContentView.swift` | Launch gate → `MainTabView` |
| `LaunchScreenView.swift` | Animated gradient launch screen |
| `MainTabView.swift` | `TabView` with 3 tabs |
| `DashboardView.swift` | 5 stat cards, progress bar, donut chart, due-soon banner, grouped sections |
| `TaskListView.swift` | Search, sort, category filter, swipe actions, row tinting |
| `TaskRowView.swift` | Reusable row + `StatusBadge` |
| `TaskDetailView.swift` | Full info, status changer, edit sheet, delete alert |
| `AddTaskView.swift` | New task form with live preview |
| `EditTaskView.swift` | Pre-filled edit form |
| `CategoriesView.swift` | Category list with progress bars + `CategoryDetailView` |
| `TaskSphere.xcdatamodeld/` | Core Data model XML |

---

## Xcode Setup — Step by Step

### Step 1 — Create the Project
1. Xcode → **File → New → Project**
2. Choose **iOS → App**
3. Fill in:
   - Product Name: `TaskSphere`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: ✅ **Core Data** ← must check this
4. Save somewhere convenient

---

### Step 2 — Delete Xcode's auto-generated files
Delete these two files Xcode creates automatically (they conflict with ours):
- `ContentView.swift` — right-click → Delete → Move to Trash
- `Persistence.swift` — right-click → Delete → Move to Trash

---

### Step 3 — Add all Swift files
Drag **all 14 `.swift` files** into the project navigator under the `TaskSphere` group:

```
TaskSphereApp.swift
PersistenceController.swift
TaskEntity+CoreDataClass.swift
AppTheme.swift
ContentView.swift
LaunchScreenView.swift
MainTabView.swift
DashboardView.swift
TaskListView.swift
TaskRowView.swift
TaskDetailView.swift
AddTaskView.swift
EditTaskView.swift
CategoriesView.swift
```

When the dialog appears:
- ✅ Copy items if needed
- ✅ Add to target: TaskSphere

---

### Step 4 — Configure the Core Data Model
1. In the project navigator, click **`TaskSphere.xcdatamodeld`**
2. Xcode opens the model editor
3. Delete any existing entity Xcode created
4. Click **Add Entity** at the bottom → name it exactly: `TaskEntity`
5. Add these 8 attributes:

| Attribute Name   | Type   |
|------------------|--------|
| `id`             | UUID   |
| `title`          | String |
| `taskDescription`| String |
| `category`       | String |
| `priority`       | String |
| `status`         | String |
| `dueDate`        | Date   |
| `createdAt`      | Date   |

6. With `TaskEntity` selected, open the **Data Model Inspector** (right panel → ruler icon)
7. Under **Class**:
   - Name: `TaskEntity`
   - Module: `Current Product Module`
   - **Codegen: `Manual/None`** ← critical, prevents Xcode generating a conflicting file

---

### Step 5 — Run
- Select **iPhone 16 Pro** simulator in the toolbar
- Press **⌘R**
- The app launches with the animated launch screen
- 10 sample tasks are pre-loaded in the preview store

---

## Feature Checklist

### From the Original Proposal
| Feature | Done |
|---|---|
| Launch screen with team info | ✅ |
| Task categories (Personal, Work, Study, Health, Other) | ✅ |
| Add tasks: title, description, due date/time, priority | ✅ |
| Track status: Pending, In Progress, Completed, Overdue | ✅ |
| Auto-detect overdue tasks | ✅ |
| Auto-detect tasks close to due date | ✅ |
| Visual progress interface | ✅ |
| Persistent local storage (Core Data) | ✅ |
| Swift + SwiftUI + multi-screen navigation | ✅ |

### Added Beyond the Proposal
| Feature | Done |
|---|---|
| "In Progress" stat card on Dashboard | ✅ |
| Donut chart — status distribution | ✅ |
| Due-soon banner (24-hour warning) on Dashboard | ✅ |
| Due-soon badge on task rows | ✅ |
| Overdue row tinting (red) | ✅ |
| Due-soon row tinting (orange) | ✅ |
| Real-time search bar | ✅ |
| 4 sort modes (Due Date, Priority, Status, Category) | ✅ |
| Swipe-to-complete (leading swipe) | ✅ |
| Swipe-to-delete (trailing swipe) | ✅ |
| Per-category progress bars in Categories tab | ✅ |
| Form validation on Add Task | ✅ |
| Live preview card in Add Task form | ✅ |
| Central `AppTheme.swift` design system | ✅ |
