import SwiftUI

struct SignupSuccessView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)

                Text("Account created")
                    .font(.title)
                    .bold()

                if let user = appState.currentUser {
                    VStack(spacing: 4) {
                        Text("Trio profile created for NetID:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(user.netid)
                            .font(.headline)
                    }

                    if let p = user.pressureProfile {
                        Text("Pressure factor: \(p.baselineLevel.displayName)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    if let l = user.locationProfile {
                        Text(String(format: "Click-spot factor: tolerance radius ≈ %.2f", l.tolerance))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Text("On the next login, Trio can use your click pressure and spot as an extra factor, depending on what you chose.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }

            HStack {
                Button("Back to login") {
                    appState.go(to: .login)
                }

                Spacer()
            }
            .frame(maxWidth: 480)

            Spacer()
        }
        .padding(32)
    }
}

#Preview {
    let state = AppState()
    state.currentUser = TrioUser(
        netid: "example123",
        usesPressure: true,
        usesLocation: true,
        pressureProfile: PressureProfile(baselineLevel: .medium, baselineValue: 0.6),
        locationProfile: LocationProfile(baselineSpot: LocationSpot(xNorm: 0.5, yNorm: 0.4), tolerance: 0.25)
    )
    return SignupSuccessView()
        .environmentObject(state)
}
