import SwiftUI

struct PressureFactorView: View {
    @EnvironmentObject var appState: AppState

    @State private var currentPressure: Double = 0.0
    @State private var lastSample: ClickSample? = nil

    private var isDev: Bool {
        appState.mode == .developerBeta
    }

    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                Text("Trio Pressure Playground")
                    .font(.title2)
                    .bold()

                Text(isDev
                     ? "Developer playground for testing trackpad pressure and click-spot."
                     : "Public beta would not normally show this screen.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

                ZStack {
                    PressureCaptureView(
                        onPressureChanged: { value in
                            currentPressure = value
                        },
                        onClickEnded: { maxP, spotPoint in
                            lastSample = ClickSample(
                                pressure: maxP,
                                spot: LocationSpot(xNorm: spotPoint.x, yNorm: spotPoint.y)
                            )
                        }
                    )
                    .frame(height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )

                    Text("Press here to try Trio")
                        .font(.headline)
                }

                PressureIndicatorView(pressure: currentPressure)
                    .padding(.top, 6)

                if let sample = lastSample {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(format: "Last spot: x=%.2f, y=%.2f",
                                    sample.spot.xNorm, sample.spot.yNorm))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 640)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
            )

            HStack {
                Button("Back to login") {
                    appState.go(to: .login)
                }

                Spacer()
            }
            .frame(maxWidth: 640)
            .padding(.top, 12)

            Spacer()
        }
        .padding(32)
    }
}

#Preview {
    PressureFactorView()
        .environmentObject(AppState())
}
