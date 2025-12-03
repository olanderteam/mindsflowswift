//
//  TaskFiltersView.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

/// View to advanced filters de tarefas
struct TaskFiltersView: View {
    @ObservedObject var viewModel: TasksViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedStatus: TaskStatus?
    @State private var selectedEnergyLevels: Set<EnergyLevel> = []
    @State private var selectedDateRange: DateRange = .all
    @State private var showOnlyWithPurpose = false
    
    init(viewModel: TasksViewModel) {
        self.viewModel = viewModel
        self._selectedStatus = State(initialValue: nil)
        self._selectedEnergyLevels = State(initialValue: Set())
        self._selectedDateRange = State(initialValue: .all)
        self._showOnlyWithPurpose = State(initialValue: false)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Status
                    statusSection
                    
                    // Níveis de energia
                    energyLevelsSection
                    
                    // Período
                    dateRangeSection
                    
                    // Opções adicionais
                    additionalOptionsSection
                    
                    // Filter statistics
                    filterStatsSection
                    
                    // Sugestões de filtros
                    suggestedFiltersSection
                }
                .padding()
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") {
                        clearAllFilters()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        applyFilters()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Status Section
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Status")
                .font(.headline)
            
            VStack(spacing: 8) {
                StatusFilterCard(
                    status: nil,
                    title: "Todas",
                    icon: "list.bullet",
                    color: .blue,
                    isSelected: selectedStatus == nil
                ) {
                    selectedStatus = nil
                }
                
                ForEach(TaskStatus.allCases, id: \.self) { status in
                    StatusFilterCard(
                        status: status,
                        title: status.displayName,
                        icon: status.icon,
                        color: status.color,
                        isSelected: selectedStatus == status
                    ) {
                        selectedStatus = status
                    }
                }
            }
        }
    }
    
    // MARK: - Energy Levels Section
    
    private var energyLevelsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Energy Levels")
                    .font(.headline)
                
                Spacer()
                
                if !selectedEnergyLevels.isEmpty {
                    Button("Clear") {
                        selectedEnergyLevels.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(EnergyLevel.allCases, id: \.self) { level in
                    EnergyLevelFilterCard(
                        level: level,
                        isSelected: selectedEnergyLevels.contains(level)
                    ) {
                        if selectedEnergyLevels.contains(level) {
                            selectedEnergyLevels.remove(level)
                        } else {
                            selectedEnergyLevels.insert(level)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Date Range Section
    
    private var dateRangeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Period")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(DateRange.allCases, id: \.self) { range in
                    DateRangeFilterCard(
                        range: range,
                        isSelected: selectedDateRange == range
                    ) {
                        selectedDateRange = range
                    }
                }
            }
        }
    }
    
    // MARK: - Additional Options Section
    
    private var additionalOptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Additional Options")
                .font(.headline)
            
            VStack(spacing: 8) {
                Toggle("Apenas com propósito definido", isOn: $showOnlyWithPurpose)
                    .toggleStyle(SwitchToggleStyle())
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Filter Stats Section
    
    private var filterStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resultado dos Filtros")
                .font(.headline)
            
            HStack(spacing: 16) {
                TaskFilterStatCard(
                    title: "Total",
                    value: "\(getFilteredTasksCount())",
                    icon: "list.bullet",
                    color: .blue
                )
                
                TaskFilterStatCard(
                    title: "Pendentes",
                    value: "\(getPendingTasksCount())",
                    icon: "circle",
                    color: .orange
                )
                
                TaskFilterStatCard(
                    title: "Concluídas",
                    value: "\(getCompletedTasksCount())",
                    icon: "checkmark.circle",
                    color: .green
                )
            }
        }
    }
    
    // MARK: - Suggested Filters Section
    
    private var suggestedFiltersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filtros Sugeridos")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    SuggestedFilterChip(
                        title: "Tarefas de Hoje",
                        icon: "calendar.badge.clock"
                    ) {
                        applySuggestedFilter(.today)
                    }
                    
                    SuggestedFilterChip(
                        title: "Alta Energia",
                        icon: "bolt.fill"
                    ) {
                        applySuggestedFilter(.highEnergy)
                    }
                    
                    SuggestedFilterChip(
                        title: "Pendentes Antigas",
                        icon: "clock.badge.exclamationmark"
                    ) {
                        applySuggestedFilter(.oldPending)
                    }
                    
                    SuggestedFilterChip(
                        title: "Com Propósito",
                        icon: "target"
                    ) {
                        applySuggestedFilter(.withPurpose)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Actions
    
    private func applyFilters() {
        // Apply energy filter if there's a selection
        if let energyLevel = selectedEnergyLevels.first {
            viewModel.setEnergyFilter(energyLevel)
        } else {
            viewModel.setEnergyFilter(nil)
        }
        dismiss()
    }
    
    private func clearAllFilters() {
        selectedStatus = nil
        selectedEnergyLevels.removeAll()
        selectedDateRange = .all
        showOnlyWithPurpose = false
    }
    
    private func applySuggestedFilter(_ filter: SuggestedFilter) {
        switch filter {
        case .today:
            selectedDateRange = .today
            selectedStatus = .pending
        case .highEnergy:
            selectedEnergyLevels = [.high]
            selectedStatus = .pending
        case .oldPending:
            selectedDateRange = .lastWeek
            selectedStatus = .pending
        case .withPurpose:
            showOnlyWithPurpose = true
        }
    }
    
    // MARK: - Helper Methods
    
    private func getFilteredTasksCount() -> Int {
        // Simulate count with applied filters
        return viewModel.tasks.count
    }
    
    private func getPendingTasksCount() -> Int {
        return viewModel.tasks.filter { !$0.isCompleted }.count
    }
    
    private func getCompletedTasksCount() -> Int {
        return viewModel.tasks.filter { $0.isCompleted }.count
    }
}

// MARK: - Supporting Views

/// Card para filtro de status
struct StatusFilterCard: View {
    let status: TaskStatus?
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 25)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color(.systemGray4), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Card para filtro de nível de energia
struct EnergyLevelFilterCard: View {
    let level: EnergyLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: level.icon)
                    .font(.title2)
                    .foregroundColor(level.color)
                
                Text(level.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? level.color.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? level.color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Card para filtro de período
struct DateRangeFilterCard: View {
    let range: DateRange
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: range.icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 25)
                
                Text(range.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color(.systemGray4), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Card for filter statistics
struct TaskFilterStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

/// Chip para filtros sugeridos
struct SuggestedFilterChip: View {
    let title: String
    let icon: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Supporting Types

enum SuggestedFilter {
    case today
    case highEnergy
    case oldPending
    case withPurpose
}

enum DateRange: CaseIterable {
    case all
    case today
    case yesterday
    case thisWeek
    case lastWeek
    case thisMonth
    case lastMonth
    
    var displayName: String {
        switch self {
        case .all: return "Todas"
        case .today: return "Hoje"
        case .yesterday: return "Ontem"
        case .thisWeek: return "Esta Semana"
        case .lastWeek: return "Semana Passada"
        case .thisMonth: return "Este Mês"
        case .lastMonth: return "Mês Passado"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "calendar"
        case .today: return "calendar.badge.clock"
        case .yesterday: return "calendar.badge.minus"
        case .thisWeek: return "calendar.badge.plus"
        case .lastWeek: return "calendar"
        case .thisMonth: return "calendar.circle"
        case .lastMonth: return "calendar.circle.fill"
        }
    }
}

enum TaskStatus: CaseIterable {
    case pending
    case completed
    
    var displayName: String {
        switch self {
        case .pending: return "Pendentes"
        case .completed: return "Concluídas"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "circle"
        case .completed: return "checkmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .completed: return .green
        }
    }
}

// MARK: - Preview

struct TaskFiltersView_Previews: PreviewProvider {
    static var previews: some View {
        TaskFiltersView(viewModel: TasksViewModel())
    }
}