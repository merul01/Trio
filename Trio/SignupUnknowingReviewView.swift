import SwiftUI

struct SignupUnknowingReviewView: View {
    @EnvironmentObject var appState: AppState

    @State private var knowingSample: ClickSample? = nil

    private var unknowing: ClickSample? {
        appState.signupUnknowingSample
    }

    private var isDev: Bool {
        appState.mode == .developerBeta
    }

    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                Text("What you just did (unknowingly)")
                    .font(.title2)
                    .bold()

                if let u = unknowing {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("When you clicked “Sign Up with Trio”, we measured how firmly and where you pressed.")
                            .foregroundStyle(.secondary)

                        PressureIndicatorView(pressure: u.pressure)

                        spotVisualization(
                            title: "Your sign-up click spot",
                            spot: u.spot
                        )

                        Text("In this beta prototype, Trio treats this as your unknowing sign-up pattern.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("No pressure value recorded for sign up (demo).")
                        .foregroundStyle(.secondary)
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Now try it knowingly")
                        .font(.headline)

                    Text("Click in the button-sized area below as you normally would. We’ll show the pressure and spot again.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    ZStack {
                        PressureCaptureView(
                            onPressureChanged: { _ in
                                // ignore live spot here
                            },
                            onClickEnded: { maxP, spotPoint in
                                let sample = ClickSample(
                                    pressure: maxP,
                                    spot: LocationSpot(xNorm: spotPoint.x, yNorm: spotPoint.y)
                                )
                                knowingSample = sample
                                appState.storeKnowingSample(sample)
                            }
                        )
                        .frame(height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.accentColor, lineWidth: 1)
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.accentColor.opacity(0.08))
                        )

                        Text("Click here again")
                            .font(.headline)
                            .foregroundColor(Color.accentColor)
                    }

                    if let k = knowingSample {
                        PressureIndicatorView(pressure: k.pressure)
                            .padding(.top, 6)

                        spotVisualization(
                            title: "Your second click spot",
                            spot: k.spot
                        )
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 680)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
            )

            HStack {
                Button("Back to sign up") {
                    appState.go(to: .signupForm)
                }

                Spacer()

                Button("Finish sign up") {
                    appState.finalizeSignup()
                    appState.go(to: .signupSuccess)
                }
                .keyboardShortcut(.defaultAction)
                .disabled(knowingSample == nil)
            }
            .padding(.top, 12)
            .frame(maxWidth: 680)

            Spacer()
        }
        .padding(32)
    }

    private func spotVisualization(title: String, spot: LocationSpot) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    .frame(height: 40)

                GeometryReader { geo in
                    let size = geo.size
                    let cx = spot.xNorm * size.width
                    let cy = (1 - spot.yNorm) * size.height

                    let tolerance: CGFloat = min(size.width, size.height) * 0.25

                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
                            .frame(width: tolerance * 2, height: tolerance * 2)
                            .position(x: cx, y: cy)

                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                            .position(x: cx, y: cy)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .frame(height: 40)

            if isDev {
                Text(String(format: "Relative spot: x=%.2f, y=%.2f", spot.xNorm, spot.yNorm))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    let state = AppState()
    state.signupUnknowingSample = ClickSample(
        pressure: 0.52,
        spot: LocationSpot(xNorm: 0.7, yNorm: 0.4)
    )
    return SignupUnknowingReviewView()
        .environmentObject(state)
}
