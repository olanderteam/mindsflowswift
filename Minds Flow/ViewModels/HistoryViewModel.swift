//
//  HistoryViewModel.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI
import Foundation

/// ViewModel para gerenciar o histórico de crescimento
@MainActor
class HistoryViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var summaryStats: [SummaryStatistic] = []
    @Published var insights: [GrowthInsight] = []
    @Published var detailedHistory: [HistoryEntry] = []
    
    // Dados para gráficos
    private var energyData: [ChartDataPoint] = []
    private var emotionData: [ChartDataPoint] = []
    private var tasksData: [ChartDataPoint] = []
    private var wisdomData: [ChartDataPoint] = []
    
    // MARK: - Initialization
    
    init() {
        loadSampleData()
    }
    
    // MARK: - Data Loading
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Implementar carregamento real dos dados do Supabase
            try await _Concurrency.Task.sleep(nanoseconds: 1_000_000_000) // Simula delay
            loadSampleData()
        } catch {
            errorMessage = "Erro ao carregar histórico: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func loadData(for timeRange: TimeRange) async {
        await loadData()
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
        // Dados de energia (últimos 30 dias)
        energyData = generateSampleData(
            baseValue: 7.0,
            variation: 2.0,
            days: 30,
            trend: .up
        )
        
        // Dados de emoção (últimos 30 dias)
        emotionData = generateSampleData(
            baseValue: 6.5,
            variation: 1.5,
            days: 30,
            trend: .stable
        )
        
        // Dados de tarefas (últimos 30 dias)
        tasksData = generateSampleData(
            baseValue: 5.0,
            variation: 3.0,
            days: 30,
            trend: .up
        )
        
        // Dados de sabedoria (últimos 30 dias)
        wisdomData = generateSampleData(
            baseValue: 2.0,
            variation: 1.0,
            days: 30,
            trend: .up
        )
        
        // Estatísticas resumidas
        summaryStats = [
            SummaryStatistic(
                title: "Energia Média",
                value: "7.2",
                subtitle: "+12% vs semana anterior",
                color: .blue,
                icon: "bolt.fill"
            ),
            SummaryStatistic(
                title: "Emoção Média",
                value: "6.8",
                subtitle: "+5% vs semana anterior",
                color: .purple,
                icon: "heart.fill"
            ),
            SummaryStatistic(
                title: "Tarefas Concluídas",
                value: "42",
                subtitle: "+18% vs semana anterior",
                color: .green,
                icon: "checkmark.circle.fill"
            ),
            SummaryStatistic(
                title: "Sabedorias Adicionadas",
                value: "8",
                subtitle: "+25% vs semana anterior",
                color: .orange,
                icon: "lightbulb.fill"
            )
        ]
        
        // Insights
        insights = [
            GrowthInsight(
                id: UUID(),
                type: .positive,
                title: "Tendência Positiva de Energia",
                description: "Sua energia tem aumentado consistentemente nos últimos 7 dias. Continue com os hábitos atuais!",
                icon: "arrow.up.circle.fill"
            ),
            GrowthInsight(
                id: UUID(),
                type: .neutral,
                title: "Estabilidade Emocional",
                description: "Suas emoções estão estáveis. Considere explorar novas atividades para crescimento.",
                icon: "equal.circle.fill"
            ),
            GrowthInsight(
                id: UUID(),
                type: .suggestion,
                title: "Oportunidade de Melhoria",
                description: "Você tem completado mais tarefas quando sua energia está alta. Planeje tarefas importantes para esses momentos.",
                icon: "lightbulb.circle.fill"
            )
        ]
        
        // Histórico detalhado
        detailedHistory = [
            HistoryEntry(
                id: UUID(),
                date: Date(),
                type: .energy,
                title: "Energia Atualizada",
                description: "Nível de energia definido como 8/10",
                value: "8/10"
            ),
            HistoryEntry(
                id: UUID(),
                date: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
                type: .task,
                title: "Tarefa Concluída",
                description: "Revisar documentação do projeto",
                value: "Concluída"
            ),
            HistoryEntry(
                id: UUID(),
                date: Calendar.current.date(byAdding: .hour, value: -4, to: Date())!,
                type: .wisdom,
                title: "Nova Sabedoria",
                description: "Adicionada reflexão sobre produtividade",
                value: "Nova"
            ),
            HistoryEntry(
                id: UUID(),
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                type: .emotion,
                title: "Emoção Atualizada",
                description: "Estado emocional definido como Motivado",
                value: "Motivado"
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
            
            // Adiciona tendência
            let trendValue: Double
            switch trend {
            case .up:
                trendValue = Double(i) * 0.05
            case .down:
                trendValue = -Double(i) * 0.05
            case .stable:
                trendValue = 0
            }
            
            // Adiciona variação aleatória
            let randomVariation = Double.random(in: -variation...variation)
            let value = max(0, baseValue + trendValue + randomVariation)
            
            data.append(ChartDataPoint(date: date, value: value))
        }
        
        return data
    }
}

// MARK: - Supporting Types

/// Ponto de dados para gráficos
struct ChartDataPoint {
    let date: Date
    let value: Double
}

/// Estatística resumida
struct SummaryStatistic {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
}

/// Insight de crescimento
struct GrowthInsight {
    let id: UUID
    let type: InsightType
    let title: String
    let description: String
    let icon: String
}

/// Entrada do histórico
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

/// Período de tempo para análise
enum TimeRange: CaseIterable {
    case week, month, threeMonths, year
    
    var displayName: String {
        switch self {
        case .week: return "7 dias"
        case .month: return "30 dias"
        case .threeMonths: return "3 meses"
        case .year: return "1 ano"
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

/// Métrica de crescimento
enum GrowthMetric: CaseIterable {
    case energy, emotion, tasks, wisdom
    
    var displayName: String {
        switch self {
        case .energy: return "Energia"
        case .emotion: return "Emoção"
        case .tasks: return "Tarefas"
        case .wisdom: return "Sabedoria"
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

/// Direção da tendência
enum TrendDirection {
    case up, down, stable
}

/// Tipo de insight
enum InsightType {
    case positive, negative, neutral, suggestion
    
    var displayName: String {
        switch self {
        case .positive: return "Positivo"
        case .negative: return "Atenção"
        case .neutral: return "Neutro"
        case .suggestion: return "Sugestão"
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

/// Tipo de entrada do histórico
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