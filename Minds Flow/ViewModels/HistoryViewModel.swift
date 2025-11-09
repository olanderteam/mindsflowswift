//
//  HistoryViewModel.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI
import Foundation

/// ViewModel to manage growth history
@MainActor
class HistoryViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var summaryStats: [SummaryStatistic] = []
    @Published var insights: [GrowthInsight] = []
    @Published var detailedHistory: [HistoryEntry] = []
    
    // Data for charts
    private var energyData: [ChartDataPoint] = []
    private var emotionData: [ChartDataPoint] = []
    private var tasksData: [ChartDataPoint] = []
    private var wisdomData: [ChartDataPoint] = []
    
    // Dependencies
    private let supabase = SupabaseManager.shared
    private let cache = CacheManager.shared
    
    // MARK: - Initialization
    
    init() {
        _Concurrency.Task {
            // Wait for authentication to complete
            try? await _Concurrency.Task.sleep(nanoseconds: 1_500_000_000)
            
            if AuthManager.shared.isAuthenticated {
                await loadData()
            } else {
                print("⚠️ HistoryViewModel: User not authenticated yet, loading sample data")
                loadSampleData()
            }
        }
    }
    
    // MARK: - Data Loading
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let userId = AuthManager.shared.currentUser?.id else {
                throw SupabaseError.notAuthenticated
            }
            
            // Load mental states data
            await loadMentalStatesData(userId: userId)
            
            // Load tasks data
            await loadTasksData(userId: userId)
            
            // Load wisdom data
            await loadWisdomData(userId: userId)
            
            // Generate statistics and insights
            generateSummaryStats()
            generateInsights()
            generateDetailedHistory()
            
            print("✅ History data loaded successfully")
            
        } catch {
            print("❌ Failed to load history data: \(error)")
            errorMessage = "Error loading history: \(error.localizedDescription)"
            
            // Fallback to sample data
            loadSampleData()
        }
        
        isLoading = false
    }
    
    func loadData(for timeRange: TimeRange) async {
        await loadData()
    }
    
    // MARK: - Private Data Loading Methods
    
    private func loadMentalStatesData(userId: UUID) async {
        do {
            // Fetch mental states from last 365 days
            let startDate = Calendar.current.date(byAdding: .day, value: -365, to: Date())!
            
            let query = SupabaseQuery
                .userId(userId)
                .orderBy("created_at", descending: false)
            
            let states: [MentalState] = try await supabase.fetch(from: "mental_states", query: query)
            
            // Filter last 365 days
            let filteredStates = states.filter { $0.createdAt >= startDate }
            
            // Convert to chart data
            energyData = filteredStates.map { state in
                ChartDataPoint(date: state.createdAt, value: Double(state.energy))
            }
            
            // Map emotions to numeric values (1-10)
            emotionData = filteredStates.map { state in
                let emotionValue = emotionToValue(state.mood)
                return ChartDataPoint(date: state.createdAt, value: emotionValue)
            }
            
            print("✅ Loaded \(filteredStates.count) mental states")
            
        } catch {
            print("❌ Failed to load mental states: \(error)")
        }
    }
    
    private func loadTasksData(userId: UUID) async {
        do {
            let startDate = Calendar.current.date(byAdding: .day, value: -365, to: Date())!
            
            let query = SupabaseQuery
                .userId(userId)
                .orderBy("created_at", descending: false)
            
            let tasks: [Task] = try await supabase.fetch(from: "tasks", query: query)
            
            // Group tasks by day
            let calendar = Calendar.current
            var tasksByDay: [Date: Int] = [:]
            
            for task in tasks where task.createdAt >= startDate {
                let dayStart = calendar.startOfDay(for: task.createdAt)
                tasksByDay[dayStart, default: 0] += 1
            }
            
            // Convert to chart data
            tasksData = tasksByDay.map { date, count in
                ChartDataPoint(date: date, value: Double(count))
            }.sorted { $0.date < $1.date }
            
            print("✅ Loaded \(tasks.count) tasks")
            
        } catch {
            print("❌ Failed to load tasks: \(error)")
        }
    }
    
    private func loadWisdomData(userId: UUID) async {
        do {
            let startDate = Calendar.current.date(byAdding: .day, value: -365, to: Date())!
            
            let query = SupabaseQuery
                .userId(userId)
                .orderBy("created_at", descending: false)
            
            let wisdomEntries: [Wisdom] = try await supabase.fetch(from: "wisdom_entries", query: query)
            
            // Group wisdom by day
            let calendar = Calendar.current
            var wisdomByDay: [Date: Int] = [:]
            
            for wisdom in wisdomEntries where wisdom.createdAt >= startDate {
                let dayStart = calendar.startOfDay(for: wisdom.createdAt)
                wisdomByDay[dayStart, default: 0] += 1
            }
            
            // Convert to chart data
            wisdomData = wisdomByDay.map { date, count in
                ChartDataPoint(date: date, value: Double(count))
            }.sorted { $0.date < $1.date }
            
            print("✅ Loaded \(wisdomEntries.count) wisdom entries")
            
        } catch {
            print("❌ Failed to load wisdom: \(error)")
        }
    }
    
    // MARK: - Data Generation Methods
    
    private func generateSummaryStats() {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
        
        // Average energy
        let recentEnergy = energyData.filter { $0.date >= weekAgo }
        let previousEnergy = energyData.filter { $0.date >= twoWeeksAgo && $0.date < weekAgo }
        let avgEnergy = recentEnergy.isEmpty ? 0 : recentEnergy.map { $0.value }.reduce(0, +) / Double(recentEnergy.count)
        let prevAvgEnergy = previousEnergy.isEmpty ? 0 : previousEnergy.map { $0.value }.reduce(0, +) / Double(previousEnergy.count)
        let energyChange = prevAvgEnergy == 0 ? 0 : ((avgEnergy - prevAvgEnergy) / prevAvgEnergy) * 100
        
        // Average emotion
        let recentEmotion = emotionData.filter { $0.date >= weekAgo }
        let previousEmotion = emotionData.filter { $0.date >= twoWeeksAgo && $0.date < weekAgo }
        let avgEmotion = recentEmotion.isEmpty ? 0 : recentEmotion.map { $0.value }.reduce(0, +) / Double(recentEmotion.count)
        let prevAvgEmotion = previousEmotion.isEmpty ? 0 : previousEmotion.map { $0.value }.reduce(0, +) / Double(previousEmotion.count)
        let emotionChange = prevAvgEmotion == 0 ? 0 : ((avgEmotion - prevAvgEmotion) / prevAvgEmotion) * 100
        
        // Tasks
        let recentTasks = tasksData.filter { $0.date >= weekAgo }
        let previousTasks = tasksData.filter { $0.date >= twoWeeksAgo && $0.date < weekAgo }
        let totalTasks = Int(recentTasks.map { $0.value }.reduce(0, +))
        let prevTotalTasks = Int(previousTasks.map { $0.value }.reduce(0, +))
        let tasksChange = prevTotalTasks == 0 ? 0 : Double((totalTasks - prevTotalTasks)) / Double(prevTotalTasks) * 100
        
        // Wisdom
        let recentWisdom = wisdomData.filter { $0.date >= weekAgo }
        let previousWisdom = wisdomData.filter { $0.date >= twoWeeksAgo && $0.date < weekAgo }
        let totalWisdom = Int(recentWisdom.map { $0.value }.reduce(0, +))
        let prevTotalWisdom = Int(previousWisdom.map { $0.value }.reduce(0, +))
        let wisdomChange = prevTotalWisdom == 0 ? 0 : Double((totalWisdom - prevTotalWisdom)) / Double(prevTotalWisdom) * 100
        
        summaryStats = [
            SummaryStatistic(
                title: "Average Energy",
                value: String(format: "%.1f", avgEnergy),
                subtitle: String(format: "%+.0f%% vs previous week", energyChange),
                color: .blue,
                icon: "bolt.fill"
            ),
            SummaryStatistic(
                title: "Average Emotion",
                value: String(format: "%.1f", avgEmotion),
                subtitle: String(format: "%+.0f%% vs previous week", emotionChange),
                color: .purple,
                icon: "heart.fill"
            ),
            SummaryStatistic(
                title: "Tasks Created",
                value: "\(totalTasks)",
                subtitle: String(format: "%+.0f%% vs previous week", tasksChange),
                color: .green,
                icon: "checkmark.circle.fill"
            ),
            SummaryStatistic(
                title: "Wisdom Added",
                value: "\(totalWisdom)",
                subtitle: String(format: "%+.0f%% vs previous week", wisdomChange),
                color: .orange,
                icon: "lightbulb.fill"
            )
        ]
    }
    
    private func generateInsights() {
        var newInsights: [GrowthInsight] = []
        
        // Energy trend analysis
        let energyTrend = calculateTrend(for: .energy)
        if energyTrend == .up {
            newInsights.append(GrowthInsight(
                id: UUID(),
                type: .positive,
                title: "Positive Energy Trend",
                description: "Your energy has been increasing consistently. Keep up your current habits!",
                icon: "arrow.up.circle.fill"
            ))
        } else if energyTrend == .down {
            newInsights.append(GrowthInsight(
                id: UUID(),
                type: .negative,
                title: "Declining Energy",
                description: "Your energy has been decreasing. Consider reviewing your sleep and eating habits.",
                icon: "arrow.down.circle.fill"
            ))
        }
        
        // Productivity analysis
        let recentTasks = tasksData.filter { $0.date >= Calendar.current.date(byAdding: .day, value: -7, to: Date())! }
        let avgTasksPerDay = recentTasks.isEmpty ? 0 : recentTasks.map { $0.value }.reduce(0, +) / Double(recentTasks.count)
        
        if avgTasksPerDay > 3 {
            newInsights.append(GrowthInsight(
                id: UUID(),
                type: .positive,
                title: "High Productivity",
                description: "You're creating an average of \(String(format: "%.1f", avgTasksPerDay)) tasks per day. Excellent!",
                icon: "star.circle.fill"
            ))
        }
        
        // Data-based suggestion
        if !energyData.isEmpty && !tasksData.isEmpty {
            newInsights.append(GrowthInsight(
                id: UUID(),
                type: .suggestion,
                title: "Optimize Your Time",
                description: "Plan important tasks when your energy is high for better productivity.",
                icon: "lightbulb.circle.fill"
            ))
        }
        
        insights = newInsights
    }
    
    private func generateDetailedHistory() {
        var entries: [HistoryEntry] = []
        
        // Add latest energy updates
        if let latestEnergy = energyData.last {
            entries.append(HistoryEntry(
                id: UUID(),
                date: latestEnergy.date,
                type: .energy,
                title: "Energy Updated",
                description: "Energy level recorded",
                value: "\(Int(latestEnergy.value))/10"
            ))
        }
        
        // Add recent tasks
        let recentTasks = tasksData.suffix(3)
        for taskData in recentTasks {
            entries.append(HistoryEntry(
                id: UUID(),
                date: taskData.date,
                type: .task,
                title: "Tasks Created",
                description: "\(Int(taskData.value)) task(s) created",
                value: "\(Int(taskData.value))"
            ))
        }
        
        // Add recent wisdom
        let recentWisdom = wisdomData.suffix(3)
        for wisdomData in recentWisdom {
            entries.append(HistoryEntry(
                id: UUID(),
                date: wisdomData.date,
                type: .wisdom,
                title: "Wisdom Added",
                description: "\(Int(wisdomData.value)) wisdom entr(y/ies) added",
                value: "\(Int(wisdomData.value))"
            ))
        }
        
        // Sort by date (most recent first)
        detailedHistory = entries.sorted { $0.date > $1.date }
    }
    
    // MARK: - Helper Methods
    
    private func emotionToValue(_ emotion: Emotion) -> Double {
        // Map emotions to values from 1-10
        switch emotion {
        case .happy, .grateful, .inspired, .motivated:
            return 9.0
        case .calm, .focused, .creative:
            return 7.0
        case .tired, .dispersed:
            return 4.0
        case .anxious, .sad, .confused:
            return 3.0
        }
    }
    
    // MARK: - Chart Data
    
    func chartData(for metric: GrowthMetric, timeRange: TimeRange) -> [ChartDataPoint] {
        let data: [ChartDataPoint]
        
        switch metric {
        case .energy:
            data = energyData
        case .emotion:
            data = emotionData
        case .tasks:
            data = tasksData
        case .wisdom:
            data = wisdomData
        }
        
        return filterData(data, for: timeRange)
    }
    
    // MARK: - Current Values
    
    func currentValue(for metric: GrowthMetric) -> String {
        let data = chartData(for: metric, timeRange: .week)
        guard let latest = data.last else { return "--" }
        
        switch metric {
        case .energy:
            return "\(Int(latest.value))/10"
        case .emotion:
            return "\(Int(latest.value))/10"
        case .tasks:
            return "\(Int(latest.value))"
        case .wisdom:
            return "\(Int(latest.value))"
        }
    }
    
    // MARK: - Trend Analysis
    
    func trendIcon(for metric: GrowthMetric) -> String {
        let trend = calculateTrend(for: metric)
        
        switch trend {
        case .up:
            return "arrow.up.right"
        case .down:
            return "arrow.down.right"
        case .stable:
            return "arrow.right"
        }
    }
    
    func trendColor(for metric: GrowthMetric) -> Color {
        let trend = calculateTrend(for: metric)
        
        switch trend {
        case .up:
            return .green
        case .down:
            return .red
        case .stable:
            return .orange
        }
    }
    
    func trendPercentage(for metric: GrowthMetric) -> String {
        let data = chartData(for: metric, timeRange: .week)
        guard data.count >= 2 else { return "0%" }
        
        let current = data.last!.value
        let previous = data[data.count - 2].value
        
        guard previous != 0 else { return "0%" }
        
        let percentage = ((current - previous) / previous) * 100
        return String(format: "%.1f%%", abs(percentage))
    }
    
    // MARK: - Private Methods
    
    private func calculateTrend(for metric: GrowthMetric) -> TrendDirection {
        let data = chartData(for: metric, timeRange: .week)
        guard data.count >= 2 else { return .stable }
        
        let current = data.last!.value
        let previous = data[data.count - 2].value
        
        let difference = current - previous
        let threshold: Double = 0.1
        
        if difference > threshold {
            return .up
        } else if difference < -threshold {
            return .down
        } else {
            return .stable
        }
    }
    
    private func filterData(_ data: [ChartDataPoint], for timeRange: TimeRange) -> [ChartDataPoint] {
        let now = Date()
        let startDate: Date
        
        switch timeRange {
        case .week:
            startDate = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        case .month:
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: now)!
        case .threeMonths:
            startDate = Calendar.current.date(byAdding: .month, value: -3, to: now)!
        case .year:
            startDate = Calendar.current.date(byAdding: .year, value: -1, to: now)!
        }
        
        return data.filter { $0.date >= startDate }
    }
    
    private func loadSampleData() {
        // Energy data (last 30 days)
        energyData = generateSampleData(
            baseValue: 7.0,
            variation: 2.0,
            days: 30,
            trend: .up
        )
        
        // Emotion data (last 30 days)
        emotionData = generateSampleData(
            baseValue: 6.5,
            variation: 1.5,
            days: 30,
            trend: .stable
        )
        
        // Tasks data (last 30 days)
        tasksData = generateSampleData(
            baseValue: 5.0,
            variation: 3.0,
            days: 30,
            trend: .up
        )
        
        // Wisdom data (last 30 days)
        wisdomData = generateSampleData(
            baseValue: 2.0,
            variation: 1.0,
            days: 30,
            trend: .up
        )
        
        // Summary statistics
        summaryStats = [
            SummaryStatistic(
                title: "Average Energy",
                value: "7.2",
                subtitle: "+12% vs previous week",
                color: .blue,
                icon: "bolt.fill"
            ),
            SummaryStatistic(
                title: "Average Emotion",
                value: "6.8",
                subtitle: "+5% vs previous week",
                color: .purple,
                icon: "heart.fill"
            ),
            SummaryStatistic(
                title: "Tasks Completed",
                value: "42",
                subtitle: "+18% vs previous week",
                color: .green,
                icon: "checkmark.circle.fill"
            ),
            SummaryStatistic(
                title: "Wisdom Added",
                value: "8",
                subtitle: "+25% vs previous week",
                color: .orange,
                icon: "lightbulb.fill"
            )
        ]
        
        // Insights
        insights = [
            GrowthInsight(
                id: UUID(),
                type: .positive,
                title: "Positive Energy Trend",
                description: "Your energy has been increasing consistently over the last 7 days. Keep up your current habits!",
                icon: "arrow.up.circle.fill"
            ),
            GrowthInsight(
                id: UUID(),
                type: .neutral,
                title: "Emotional Stability",
                description: "Your emotions are stable. Consider exploring new activities for growth.",
                icon: "equal.circle.fill"
            ),
            GrowthInsight(
                id: UUID(),
                type: .suggestion,
                title: "Improvement Opportunity",
                description: "You complete more tasks when your energy is high. Plan important tasks for those moments.",
                icon: "lightbulb.circle.fill"
            )
        ]
        
        // Detailed history
        detailedHistory = [
            HistoryEntry(
                id: UUID(),
                date: Date(),
                type: .energy,
                title: "Energy Updated",
                description: "Energy level set to 8/10",
                value: "8/10"
            ),
            HistoryEntry(
                id: UUID(),
                date: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
                type: .task,
                title: "Task Completed",
                description: "Review project documentation",
                value: "Completed"
            ),
            HistoryEntry(
                id: UUID(),
                date: Calendar.current.date(byAdding: .hour, value: -4, to: Date())!,
                type: .wisdom,
                title: "New Wisdom",
                description: "Added reflection on productivity",
                value: "New"
            ),
            HistoryEntry(
                id: UUID(),
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                type: .emotion,
                title: "Emotion Updated",
                description: "Emotional state set to Motivated",
                value: "Motivated"
            )
        ]
    }
    
    private func generateSampleData(
        baseValue: Double,
        variation: Double,
        days: Int,
        trend: TrendDirection
    ) -> [ChartDataPoint] {
        var data: [ChartDataPoint] = []
        let now = Date()
        
        for i in 0..<days {
            let date = Calendar.current.date(byAdding: .day, value: -days + i, to: now)!
            
            // Add trend
            let trendValue: Double
            switch trend {
            case .up:
                trendValue = Double(i) * 0.05
            case .down:
                trendValue = -Double(i) * 0.05
            case .stable:
                trendValue = 0
            }
            
            // Add random variation
            let randomVariation = Double.random(in: -variation...variation)
            let value = max(0, baseValue + trendValue + randomVariation)
            
            data.append(ChartDataPoint(date: date, value: value))
        }
        
        return data
    }
}

// MARK: - Supporting Types

/// Data point for charts
struct ChartDataPoint {
    let date: Date
    let value: Double
}

/// Summary statistic
struct SummaryStatistic {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
}

/// Growth insight
struct GrowthInsight {
    let id: UUID
    let type: InsightType
    let title: String
    let description: String
    let icon: String
}

/// History entry
struct HistoryEntry {
    let id: UUID
    let date: Date
    let type: HistoryEntryType
    let title: String
    let description: String?
    let value: String
    
    init(id: UUID, date: Date, type: HistoryEntryType, title: String, description: String? = nil, value: String) {
        self.id = id
        self.date = date
        self.type = type
        self.title = title
        self.description = description
        self.value = value
    }
}

/// Time period for analysis
enum TimeRange: CaseIterable {
    case week, month, threeMonths, year
    
    var displayName: String {
        switch self {
        case .week: return "7 days"
        case .month: return "30 days"
        case .threeMonths: return "3 months"
        case .year: return "1 year"
        }
    }
    
    var axisStride: Calendar.Component {
        switch self {
        case .week: return .day
        case .month: return .day
        case .threeMonths: return .weekOfYear
        case .year: return .month
        }
    }
    
    var axisFormat: Date.FormatStyle {
        switch self {
        case .week: return .dateTime.weekday(.abbreviated)
        case .month: return .dateTime.day()
        case .threeMonths: return .dateTime.month(.abbreviated)
        case .year: return .dateTime.month(.abbreviated)
        }
    }
}

/// Growth metric
enum GrowthMetric: CaseIterable {
    case energy, emotion, tasks, wisdom
    
    var displayName: String {
        switch self {
        case .energy: return "Energy"
        case .emotion: return "Emotion"
        case .tasks: return "Tasks"
        case .wisdom: return "Wisdom"
        }
    }
    
    var icon: String {
        switch self {
        case .energy: return "bolt.fill"
        case .emotion: return "heart.fill"
        case .tasks: return "checkmark.circle.fill"
        case .wisdom: return "lightbulb.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .energy: return .blue
        case .emotion: return .purple
        case .tasks: return .green
        case .wisdom: return .orange
        }
    }
}

/// Trend direction
enum TrendDirection {
    case up, down, stable
}

/// Insight type
enum InsightType {
    case positive, negative, neutral, suggestion
    
    var displayName: String {
        switch self {
        case .positive: return "Positive"
        case .negative: return "Attention"
        case .neutral: return "Neutral"
        case .suggestion: return "Suggestion"
        }
    }
    
    var color: Color {
        switch self {
        case .positive: return .green
        case .negative: return .red
        case .neutral: return .orange
        case .suggestion: return .blue
        }
    }
}

/// History entry type
enum HistoryEntryType {
    case energy, emotion, task, wisdom
    
    var icon: String {
        switch self {
        case .energy: return "bolt.fill"
        case .emotion: return "heart.fill"
        case .task: return "checkmark.circle.fill"
        case .wisdom: return "lightbulb.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .energy: return .blue
        case .emotion: return .purple
        case .task: return .green
        case .wisdom: return .orange
        }
    }
}