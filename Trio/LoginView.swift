import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState

    @State private var netId: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false

    // Pressure preview
    @State private var previewPressure: Double = 0.0
    @State private var wantsTrioPressure: Bool = true

    @State private var showMissingUserAlert = false

    private var isDev: Bool {
        appState.mode == .developerBeta
    }

    private var canSubmit: Bool {
        !netId.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }

    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                headerSection
                fieldsSection
                trioSection
                buttonsSection
            }
            .padding(24)
            .frame(maxWidth: 640)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
            )

            signupButton

            Spacer()
        }
        .padding(.horizontal, 40)
        .alert("User not found", isPresented: $showMissingUserAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("No Trio profile found for this NetID. Please sign up first, or use the help options.")
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Trio Login – \(isDev ? "Developer Beta" : "Public Beta")")
                .font(.largeTitle)
                .bold()
            Text("Sign in with your NetID and password. Trio can also use how you click as an extra factor.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var fieldsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NetID")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("example123", text: $netId)
                .textFieldStyle(.roundedBorder)

            Text("Password")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                if showPassword {
                    TextField("Required", text: $password)
                        .textFieldStyle(.roundedBorder)
                } else {
                    SecureField("Required", text: $password)
                        .textFieldStyle(.roundedBorder)
                }

                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                }
                .buttonStyle(.borderless)
                .help(showPassword ? "Hide password" : "Show password")
            }

            HStack {
                Button("Forgot password?") {
                    appState.go(to: .emailOtpFallback)
                }
                .buttonStyle(.borderless)

                Spacer()

                Button("Need help?") {
                    appState.go(to: .emailOtpFallback)
                }
                .buttonStyle(.borderless)
            }
            .font(.footnote)
        }
    }

    private var trioSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Use Trio pressure + click-spot as a seamless second factor", isOn: $wantsTrioPressure)
                .toggleStyle(.switch)

            if wantsTrioPressure {
                if isDev {
                    Text("Developer view: press in the area below to see your click classified as Soft / Medium / Firm.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Public beta: Trio silently uses your login click as an extra factor.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if isDev {
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

                        Text("Try your login click")
                            .font(.headline)
                    }

                    PressureIndicatorView(pressure: previewPressure)
                        .padding(.top, 4)
                }
            }
        }
        .padding(.top, 8)
    }

    private var buttonsSection: some View {
        HStack {
            Button("Back") {
                appState.go(to: .modeSelection)
            }

            Spacer()

            // Login button with pressure capture
            ZStack {
                PressureCaptureView(
                    onPressureChanged: { _ in },
                    onClickEnded: { maxP, spotPoint in
                        if canSubmit {
                            let sample = ClickSample(
                                pressure: maxP,
                                spot: LocationSpot(xNorm: spotPoint.x, yNorm: spotPoint.y)
                            )
                            handleLogin(sample: sample)
                        }
                    }
                )
                .frame(height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(canSubmit ? Color.accentColor : Color.gray.opacity(0.4), lineWidth: 1)
                )
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(canSubmit ? Color.accentColor.opacity(0.12) : Color.gray.opacity(0.08))
                )
                .opacity(canSubmit ? 1.0 : 0.6)

                Text("Log In")
                    .font(.headline)
                    .foregroundColor(canSubmit ? Color.accentColor : Color.secondary)
            }
            .frame(width: 160)
            .disabled(!canSubmit)
        }
    }

    private var signupButton: some View {
        Button {
            appState.go(to: .signupForm)
        } label: {
            Text("New to Trio? Sign up")
                .font(.subheadline.bold())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)
        .padding(.top, 10)
    }

    // MARK: - Logic

    private func handleLogin(sample: ClickSample) {
        if wantsTrioPressure {
            // Trio as second factor
            let ok = appState.attemptTrioLogin(netid: netId, sample: sample)
            if ok {
                appState.go(to: .loginSuccess)
            } else {
                appState.go(to: .emailOtpFallback)
            }
        } else {
            // Classic Duo-style path
            if appState.users.contains(where: { $0.netid == netId }) {
                appState.lastLoginSample = sample
                appState.go(to: .duoFactor)
            } else {
                showMissingUserAlert = true
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
