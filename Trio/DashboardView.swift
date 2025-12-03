import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(alignment: .leading, spacing: 16) {
                Text("Student Dashboard")
                    .font(.title)
                    .bold()

                VStack(alignment: .leading, spacing: 6) {
                    Text("Fall Graduate Tuition:  $0")
                    Text("On-campus Housing Fees:  $0")
                    Text("CSE 518:  3.0 / 3.0 credits completed")
                    Text("Other 2 courses:  Pending")
                }
                .font(.body)

                Divider()

                if let sample = appState.lastLoginSample {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Logged in with Trio")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        PressureIndicatorView(pressure: sample.pressure)
                    }
                } else {
                    Text("No Trio login data for this session (demo).")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
                Button("Log Out") {
                    appState.clearForNewSession()
                    appState.go(to: .login)
                }
                Spacer()
            }
            .frame(maxWidth: 640)
            .padding(.top, 8)

            Spacer()
        }
        .padding(32)
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppState())
}
