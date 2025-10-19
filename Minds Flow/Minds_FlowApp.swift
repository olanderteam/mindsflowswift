//
//  Minds_FlowApp.swift
//  Minds Flow
//
//  Created by Gabe on 04/09/25.
//

import SwiftUI

@main
struct Minds_FlowApp: App {
    init() {
        // Inicializa o AuthManager
        _ = AuthManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
