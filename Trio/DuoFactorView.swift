import SwiftUI

struct DuoFactorView: View {
    @EnvironmentObject var appState: AppState

    @State private var selectedMethod: AuthMethod = .push
    @State private var rememberDevice: Bool = false

    enum AuthMethod: String, CaseIterable, Identifiable {
        case push
        case mobilePasscode
        case bypass
        case touchId

        var id: String { rawValue }

        var title: String {
            switch self {
            case .push:           return "Duo Push"
            case .mobilePasscode: return "Use Mobile Passcode"
            case .bypass:         return "Use Bypass Code"
            case .touchId:        return "Use Touch ID"
            }
        }

        var subtitle: String {
            switch self {
            case .push:
                return "Send a login request to your phone. (Recommended)"
            case .mobilePasscode:
                return "Enter a passcode from the Duo mobile app."
            case .bypass:
                return "Use a one-time bypass code."
            case .touchId:
                return "Approve using this Mac's Touch ID."
            }
        }
    }

    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Classic Duo-style step")
                        .font(.title)
                        .bold()
                    Text("This path is used when Trio pressure is turned off.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 12) {
                    methodRow(for: .push)
                        .overlay(alignment: .topTrailing) {
                            if selectedMethod == .push {
                                Text("Last used")
                                    .font(.caption2)
                                    .padding(6)
                                    .background(
                                        Capsule()
                                            .fill(Color.blue.opacity(0.12))
                                    )
                                    .padding(8)
                            }
                        }

                    Divider()

                    methodRow(for: .mobilePasscode)
                    methodRow(for: .bypass)
                    methodRow(for: .touchId)
                }

                Toggle("Remember this device for 30 days", isOn: $rememberDevice)
                    .font(.subheadline)

                HStack {
                    Button("Back to login") {
                        appState.go(to: .login)
                    }

                    Spacer()

                    Button("Simulate approval and continue") {
                        appState.go(to: .loginSuccess)
                    }
                    .keyboardShortcut(.defaultAction)
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
        .padding(.horizontal, 40)
    }

    @ViewBuilder
    private func methodRow(for method: AuthMethod) -> some View {
        Button {
            selectedMethod = method
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: selectedMethod == method ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(selectedMethod == method ? Color.accentColor : Color.secondary)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text(method.title)
                        .font(.headline)
                    Text(method.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(selectedMethod == method ?
                      Color.accentColor.opacity(0.1) :
                      Color.clear)
        )
    }
}

#Preview {
    DuoFactorView()
        .environmentObject(AppState())
}
