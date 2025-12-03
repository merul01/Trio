//
//  TrioApp.swift
//  Trio
//
//  Created by Merul Shah on 03/12/25.
//

import SwiftUI

@main
struct TrioAuthApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
