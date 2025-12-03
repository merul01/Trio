import SwiftUI

struct LoginSuccessView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)

                Text("Successfully logged in")
                    .font(.title)
                    .bold()

                if let sample = appState.lastLoginSample {
                    VStack(spacing: 8) {
                        Text("Your login click")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        PressureIndicatorView(pressure: sample.pressure)
                    }
                } else {
                    Text("No Trio data recorded (demo).")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text("Next, we show a mock student dashboard with tuition, housing, and course status.")
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

                Button("Continue to dashboard") {
                    appState.go(to: .dashboard)
                }
                .keyboardShortcut(.defaultAction)
            }
            .frame(maxWidth: 480)

            Spacer()
        }
        .padding(32)
    }
}

#Preview {
    let state = AppState()
    state.lastLoginSample = ClickSample(
        pressure: 0.62,
        spot: LocationSpot(xNorm: 0.6, yNorm: 0.5)
    )
    return LoginSuccessView()
        .environmentObject(state)
}
