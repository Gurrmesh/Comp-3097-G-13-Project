// DashboardView.swift
// COMP3097 – Group 13 | Gurrmesh Singgh (101471817)
//
// Features:
//  • 5 stat cards (Total, Completed, In Progress, Overdue, Due Today)
//  • Overall progress bar
//  • Donut chart with status breakdown
//  • Due-soon banner (tasks within 24 hours)
//  • Grouped sections: Overdue / Due Today / Up Next

import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var ctx

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskEntity.dueDate, ascending: true)],
        animation: .default
    )
    private var allTasks: FetchedResults<TaskEntity>

    @State private var showAddTask = false

    // MARK: – Counts
    private var total:     Int { allTasks.count }
    private var completed: Int { allTasks.filter { $0.computedStatus == "Completed"   }.count }
    private var overdue:   Int { allTasks.filter { $0.computedStatus == "Overdue"     }.count }
    private var inProgress:Int { allTasks.filter { $0.computedStatus == "In Progress" }.count }
    private var dueToday:  Int { allTasks.filter { Calendar.current.isDateInToday($0.dueDate ?? .distantFuture) && $0.computedStatus != "Completed" }.count }
    private var progress:  Double { total == 0 ? 0 : Double(completed) / Double(total) }
    private var dueSoon:   [TaskEntity] { allTasks.filter { $0.isDueSoon } }

    // MARK: – Sections
    private var overdueTasks:  [TaskEntity] { allTasks.filter { $0.computedStatus == "Overdue" } }
    private var todayTasks:    [TaskEntity] { allTasks.filter {
        Calendar.current.isDateInToday($0.dueDate ?? .distantFuture)
        && $0.computedStatus != "Completed"
        && $0.computedStatus != "Overdue"
    }}
    private var upcomingTasks: [TaskEntity] { allTasks.filter {
        guard let d = $0.dueDate else { return false }
        return d > Date() && $0.computedStatus != "Completed"
    }}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: Stat Cards — row 1 (3 cards)
                HStack(spacing: 12) {
                    StatCard(value: total,      label: "Total Tasks",  color: .blue)
                    StatCard(value: completed,  label: "Completed",    color: .green)
                    StatCard(value: inProgress, label: "In Progress",  color: .purple)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                // MARK: Stat Cards — row 2 (2 cards)
                HStack(spacing: 12) {
                    StatCard(value: overdue,  label: "Overdue",   color: .red)
                    StatCard(value: dueToday, label: "Due Today", color: .orange)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                // MARK: Progress Bar
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Overall progress")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    ProgressView(value: progress)
                        .tint(.blue)
                        .scaleEffect(x: 1, y: 1.4, anchor: .center)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                // MARK: Donut Chart
                DonutChartView(tasks: Array(allTasks))
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                // MARK: Due-Soon Banner
                if !dueSoon.isEmpty {
                    DueSoonBanner(count: dueSoon.count)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                }

                // MARK: Overdue Section
                if !overdueTasks.isEmpty {
                    SectionHeader(title: "Overdue")
                    TaskCardList(tasks: overdueTasks)
                }

                // MARK: Due Today Section
                SectionHeader(title: "Due Today")
                if todayTasks.isEmpty {
                    EmptySectionCard(message: "Nothing due today 🎉")
                } else {
                    TaskCardList(tasks: todayTasks)
                }

                // MARK: Up Next Section
                SectionHeader(title: "Up Next")
                if upcomingTasks.isEmpty {
                    EmptySectionCard(message: "All caught up!")
                } else {
                    TaskCardList(tasks: Array(upcomingTasks.prefix(3)))
                }

                Spacer(minLength: 40)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddTask = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                }
            }
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskView()
        }
    }
}

// MARK: – StatCard
struct StatCard: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(value)")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(14)
    }
}

// MARK: – DonutChartView
struct DonutChartView: View {
    let tasks: [TaskEntity]

    private var counts: [(label: String, count: Int, color: Color)] {[
        ("Completed",   tasks.filter { $0.computedStatus == "Completed"   }.count, .green ),
        ("In Progress", tasks.filter { $0.computedStatus == "In Progress" }.count, .blue  ),
        ("Pending",     tasks.filter { $0.computedStatus == "Pending"     }.count, Color(.systemGray3)),
        ("Overdue",     tasks.filter { $0.computedStatus == "Overdue"     }.count, .red   ),
    ]}

    private var total: Int { tasks.count }

    var body: some View {
        HStack(spacing: 20) {
            // Donut
            ZStack {
                DonutShape(counts: counts, total: total)
                    .frame(width: 100, height: 100)

                VStack(spacing: 1) {
                    Text("\(total)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text("tasks")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }

            // Legend
            VStack(alignment: .leading, spacing: 8) {
                ForEach(counts, id: \.label) { item in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 10, height: 10)
                        Text(item.label)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(item.count)")
                            .font(.system(size: 13, weight: .semibold))
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(14)
    }
}

// MARK: – DonutShape (Canvas-based)
struct DonutShape: View {
    let counts: [(label: String, count: Int, color: Color)]
    let total:  Int

    var body: some View {
        Canvas { ctx, size in
            guard total > 0 else { return }
            let center  = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius  = min(size.width, size.height) / 2 - 6
            let stroke: CGFloat = 16
            var startAngle = Angle(degrees: -90)

            for item in counts {
                guard item.count > 0 else { continue }
                let sweep = Angle(degrees: 360.0 * Double(item.count) / Double(total))
                let endAngle = startAngle + sweep

                var path = Path()
                path.addArc(center: center,
                            radius: radius,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: false)

                ctx.stroke(path,
                           with: .color(item.color),
                           style: StrokeStyle(lineWidth: stroke, lineCap: .butt))

                startAngle = endAngle
            }
        }
    }
}

// MARK: – DueSoonBanner
struct DueSoonBanner: View {
    let count: Int

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "clock.badge.exclamationmark.fill")
                .font(.system(size: 20))
                .foregroundColor(.orange)
            VStack(alignment: .leading, spacing: 1) {
                Text("Due Soon")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.orange)
                Text("\(count) task\(count > 1 ? "s" : "") due within the next 24 hours")
                    .font(.system(size: 12))
                    .foregroundColor(.orange.opacity(0.8))
            }
            Spacer()
        }
        .padding(12)
        .background(Color.orange.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// MARK: – SectionHeader
struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.secondary)
            .padding(.horizontal, 32)
            .padding(.top, 24)
            .padding(.bottom, 8)
    }
}

// MARK: – EmptySectionCard
struct EmptySectionCard: View {
    let message: String
    var body: some View {
        Text(message)
            .font(.system(size: 14))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
    }
}

// MARK: – TaskCardList (wraps rows in a card)
struct TaskCardList: View {
    let tasks: [TaskEntity]
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(tasks.enumerated()), id: \.offset) { index, task in
                NavigationLink(destination: TaskDetailView(task: task)) {
                    TaskRowView(task: task)
                }
                .buttonStyle(.plain)
                if index < tasks.count - 1 {
                    Divider().padding(.leading, 56)
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { DashboardView() }
            .environment(\.managedObjectContext,
                         PersistenceController.preview.container.viewContext)
    }
}
