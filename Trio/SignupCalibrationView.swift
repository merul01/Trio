//
//  SignupCalibrationView.swift
//  Trio
//
//  Created by Merul Shah on 03/12/25.
//

import SwiftUI

struct SignupCalibrationView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 16) {
            Text("Calibration (placeholder)")
                .font(.title)

            Text("This will guide pressure and/or click-spot trials in beta/final modes.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Continue to Summary") {
                appState.go(to: .signupSuccess)
            }
        }
        .padding(32)
    }
}

#Preview {
    SignupCalibrationView()
        .environmentObject(AppState())
}
