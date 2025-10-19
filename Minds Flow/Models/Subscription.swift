//
//  Subscription.swift
//  Minds Flow
//
//  Created by Kiro on 18/10/25.
//

import Foundation

/// Modelo para representar a assinatura do usuário
/// Gerencia informações de plano e status de pagamento
struct Subscription: Codable, Identifiable {
    
    // MARK: - Properties
    let id: UUID
    let userId: UUID
    var planId: String
    var status: SubscriptionStatus
    var currentPeriodStart: Date
    var currentPeriodEnd: Date
    var stripeCustomerId: String?
    var stripeSubscriptionId: String?
    let createdAt: Date
    let updatedAt: Date
    
    // MARK: - Subscription Status
    enum SubscriptionStatus: String, Codable, CaseIterable {
        case active
        case inactive
        case cancelled
        case pastDue = "past_due"
        case trialing
        
        var displayName: String {
            switch self {
            case .active:
                return "Ativa"
            case .inactive:
                return "Inativa"
            case .cancelled:
                return "Cancelada"
            case .pastDue:
                return "Pagamento Pendente"
            case .trialing:
                return "Período de Teste"
            }
        }
        
        var icon: String {
            switch self {
            case .active:
                return "checkmark.circle.fill"
            case .inactive:
                return "xmark.circle"
            case .cancelled:
                return "slash.circle"
            case .pastDue:
                return "exclamationmark.triangle"
            case .trialing:
                return "clock"
            }
        }
    }
    
    // MARK: - Supabase Mapping
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case planId = "plan_id"
        case status
        case currentPeriodStart = "current_period_start"
        case currentPeriodEnd = "current_period_end"
        case stripeCustomerId = "stripe_customer_id"
        case stripeSubscriptionId = "stripe_subscription_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        userId: UUID,
        planId: String,
        status: SubscriptionStatus,
        currentPeriodStart: Date,
        currentPeriodEnd: Date,
        stripeCustomerId: String? = nil,
        stripeSubscriptionId: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.planId = planId
        self.status = status
        self.currentPeriodStart = currentPeriodStart
        self.currentPeriodEnd = currentPeriodEnd
        self.stripeCustomerId = stripeCustomerId
        self.stripeSubscriptionId = stripeSubscriptionId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Subscription Extensions

extension Subscription {
    
    /// Verifica se a assinatura está ativa
    var isActive: Bool {
        return status == .active && currentPeriodEnd > Date()
    }
    
    /// Verifica se está em período de teste
    var isTrialing: Bool {
        return status == .trialing
    }
    
    /// Verifica se a assinatura expirou
    var isExpired: Bool {
        return currentPeriodEnd < Date() && status != .active
    }
    
    /// Dias restantes no período atual
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: currentPeriodEnd)
        return max(0, components.day ?? 0)
    }
    
    /// Retorna descrição formatada dos dias restantes
    var daysRemainingText: String {
        let days = daysRemaining
        
        if days == 0 {
            return "Expira hoje"
        } else if days == 1 {
            return "1 dia restante"
        } else {
            return "\(days) dias restantes"
        }
    }
    
    /// Duração do período atual em dias
    var periodDuration: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: currentPeriodStart, to: currentPeriodEnd)
        return components.day ?? 0
    }
    
    /// Retorna o tipo de plano formatado
    var planName: String {
        switch planId.lowercased() {
        case "free":
            return "Gratuito"
        case "pro":
            return "Pro"
        case "premium":
            return "Premium"
        case "enterprise":
            return "Enterprise"
        default:
            return planId.capitalized
        }
    }
    
    /// Retorna descrição completa da assinatura
    var description: String {
        return "\(planName) - \(status.displayName)"
    }
    
    /// Verifica se precisa renovar em breve (menos de 7 dias)
    var needsRenewal: Bool {
        return daysRemaining <= 7 && daysRemaining > 0
    }
    
    /// Retorna data de renovação formatada
    var renewalDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: currentPeriodEnd)
    }
}

// MARK: - Timestamped Protocol

extension Subscription: Timestamped {}

// MARK: - Sample Data

extension Subscription {
    
    /// Assinatura ativa de exemplo
    static let sampleActivePro = Subscription(
        userId: UUID(),
        planId: "pro",
        status: .active,
        currentPeriodStart: Date().addingTimeInterval(-86400 * 15), // 15 dias atrás
        currentPeriodEnd: Date().addingTimeInterval(86400 * 15), // 15 dias no futuro
        stripeCustomerId: "cus_sample123",
        stripeSubscriptionId: "sub_sample456"
    )
    
    /// Assinatura gratuita de exemplo
    static let sampleFree = Subscription(
        userId: UUID(),
        planId: "free",
        status: .active,
        currentPeriodStart: Date().addingTimeInterval(-86400 * 30),
        currentPeriodEnd: Date().addingTimeInterval(86400 * 335) // ~1 ano
    )
    
    /// Assinatura em período de teste
    static let sampleTrial = Subscription(
        userId: UUID(),
        planId: "pro",
        status: .trialing,
        currentPeriodStart: Date().addingTimeInterval(-86400 * 5),
        currentPeriodEnd: Date().addingTimeInterval(86400 * 9) // 9 dias restantes
    )
    
    /// Assinatura com pagamento pendente
    static let samplePastDue = Subscription(
        userId: UUID(),
        planId: "pro",
        status: .pastDue,
        currentPeriodStart: Date().addingTimeInterval(-86400 * 35),
        currentPeriodEnd: Date().addingTimeInterval(-86400 * 5), // Expirou há 5 dias
        stripeCustomerId: "cus_sample789",
        stripeSubscriptionId: "sub_sample012"
    )
}
