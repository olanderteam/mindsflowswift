//
//  HistoryView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI
import Charts

/// Main view of growth history
struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedMetric: GrowthMetric = .energy
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Controles de filtro
                    filterControlsSection
                    
                    // Gráfico principal
                    mainChartSection
                    
                    // Summary statistics
                    summaryStatsSection
                    
                    // Insights and trends
                    insightsSection
                    
                    // Detailed history
                    detailedHistorySection
                }
                .padding()
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.loadData()
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
    
    // MARK: - Filter Controls
    
    private var filterControlsSection: some View {
        VStack(spacing: 16) {
            // Seletor de período
            HStack {
                Text("Período")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Picker("Período", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.displayName)
                            .tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // Seletor de métrica
            HStack {
                Text("Métrica")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Picker("Métrica", selection: $selectedMetric) {
                    ForEach(GrowthMetric.allCases, id: \.self) { metric in
                        Label(metric.displayName, systemImage: metric.icon)
                            .tag(metric)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .onChange(of: selectedTimeRange) { _ in
            _Concurrency.Task {
                await viewModel.loadData(for: selectedTimeRange)
            }
        }
        .onChange(of: selectedMetric) { _ in
            _Concurrency.Task {
                await viewModel.loadData(for: selectedTimeRange)
            }
        }
    }
    
    // MARK: - Main Chart
    
    private var mainChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedMetric.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(selectedTimeRange.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Valor atual
                VStack(alignment: .trailing, spacing: 4) {
                    Text(viewModel.currentValue(for: selectedMetric))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(selectedMetric.color)
                    
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.trendIcon(for: selectedMetric))
                            .font(.caption)
                        Text(viewModel.trendPercentage(for: selectedMetric))
                            .font(.caption)
                    }
                    .foregroundColor(viewModel.trendColor(for: selectedMetric))
                }
            }
            
            // Gráfico
            Chart(viewModel.chartData(for: selectedMetric, timeRange: selectedTimeRange), id: \.date) { dataPoint in
                LineMark(
                    x: .value("Data", dataPoint.date),
                    y: .value(selectedMetric.displayName, dataPoint.value)
                )
                .foregroundStyle(selectedMetric.color.gradient)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                
                AreaMark(
                    x: .value("Data", dataPoint.date),
                    y: .value(selectedMetric.displayName, dataPoint.value)
                )
                .foregroundStyle(
                    selectedMetric.color.opacity(0.1).gradient
                )
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: selectedTimeRange.axisStride)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: selectedTimeRange.axisFormat)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Summary Stats
    
    private var summaryStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resumo do Período")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(viewModel.summaryStats, id: \.title) { stat in
                    StatCard(
                        title: stat.title,
                        value: stat.value,
                        subtitle: stat.subtitle,
                        icon: stat.icon,
                        color: stat.color
                    )
                }
            }
        }
    }
    
    // MARK: - Insights
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insights and Trends")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(viewModel.insights, id: \.id) { insight in
                    InsightCard(insight: insight)
                }
            }
        }
    }
    
    // MARK: - Detailed History
    
    private var detailedHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detailed History")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(viewModel.detailedHistory, id: \.id) { entry in
                    HistoryEntryRow(entry: entry)
                }
            }
        }
    }
}

// MARK: - Supporting Views

/// Card for insights
struct InsightCard: View {
    let insight: GrowthInsight
    
    var body: some View {
        HStack(spacing: 12) {
            // Ícone
            Image(systemName: insight.icon)
                .font(.title3)
                .foregroundColor(insight.type.color)
                .frame(width: 30)
            
            // Conteúdo
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(insight.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            // Badge do tipo
            Text(insight.type.displayName)
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(insight.type.color.opacity(0.1))
                )
                .foregroundColor(insight.type.color)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

/// Row for history entry
struct HistoryEntryRow: View {
    let entry: HistoryEntry
    
    var body: some View {
        HStack(spacing: 12) {
            // Data
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.date, style: .date)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(entry.date, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 80, alignment: .leading)
            
            // Conteúdo
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if let description = entry.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Valor/Status
            VStack(alignment: .trailing, spacing: 2) {
                Text(entry.value)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(entry.type.color)
                
                Image(systemName: entry.type.icon)
                    .font(.caption2)
                    .foregroundColor(entry.type.color)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Preview

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}