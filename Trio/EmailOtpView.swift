import SwiftUI

struct EmailOtpView: View {
    @EnvironmentObject var appState: AppState

    @State private var otpCode: String = ""

    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                Text("Need help signing in?")
                    .font(.title2)
                    .bold()

                Text("If Trio’s pressure / click-spot check doesn’t match, you can still sign in using one of these options:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 10) {
                    Label("Email one-time passcode", systemImage: "envelope.fill")
                    Label("Duo-style approval on your phone", systemImage: "iphone.homebutton")
                    Label("Trio pressure + click-spot on this Mac", systemImage: "trackpad.and.arrow.up")
                    Label("Admin-issued bypass codes", systemImage: "key.fill")
                }
                .font(.subheadline)

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Simulated email OTP (prototype)")
                        .font(.subheadline)
                        .bold()

                    Text("Enter any 6-digit code below to continue in this demo. In a real system, this would be sent to your SBU email.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField("123456", text: $otpCode)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 160)

                    HStack {
                        Button("Back to login") {
                            appState.go(to: .login)
                        }

                        Spacer()

                        Button("Verify and continue") {
                            appState.go(to: .loginSuccess)
                        }
                        .keyboardShortcut(.defaultAction)
                        .disabled(otpCode.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(24)
            .frame(maxWidth: 640)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
            )

            Spacer()
        }
        .padding(32)
    }
}

#Preview {
    EmailOtpView()
        .environmentObject(AppState())
}
