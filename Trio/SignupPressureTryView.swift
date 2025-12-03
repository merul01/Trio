import SwiftUI

struct SignupPressureTryView: View {
    @EnvironmentObject var appState: AppState

    @State private var previewPressure: Double = 0.0

    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                Text("Try Trio pressure (Beta)")
                    .font(.title2)
                    .bold()

                Text("Press in the button-sized area below. We show how firmly you click using a traffic-light indicator. This page is just for exploration and doesn’t store anything.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ZStack {
                    PressureCaptureView(
                        onPressureChanged: { value in
                            previewPressure = value
                        },
                        onClickEnded: { maxP, _ in
                            previewPressure = maxP
                        }
                    )
                    .frame(height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )

                    Text("Press here")
                        .font(.headline)
                }

                PressureIndicatorView(pressure: previewPressure)
                    .padding(.top, 6)
            }
            .padding(24)
            .frame(maxWidth: 620)
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
            }
            .frame(maxWidth: 620)
            .padding(.top, 12)

            Spacer()
        }
        .padding(32)
    }
}

#Preview {
    SignupPressureTryView()
        .environmentObject(AppState())
}
