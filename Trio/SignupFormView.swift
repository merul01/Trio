import SwiftUI

struct SignupFormView: View {
    @EnvironmentObject var appState: AppState

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var sbuId = ""
    @State private var sbuEmail = ""
    @State private var netId = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    // Devices
    @State private var usesBuiltInTrackpad = true
    @State private var usesMouse = false
    @State private var usesExternalTrackpad = false

    // Factors
    @State private var wantsPressure = true
    @State private var wantsLocation = true

    @State private var showValidationError = false
    @State private var validationMessage = ""

    private var canSubmit: Bool {
        !netId.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty &&
        password == confirmPassword
    }

    private var isDev: Bool {
        appState.mode == .developerBeta
    }

    var body: some View {
        VStack {
            Spacer()

            HStack(alignment: .top, spacing: 24) {
                identityCard
                securityCard
            }
            .frame(maxWidth: 900)

            HStack {
                Button("Back to login") {
                    appState.go(to: .login)
                }

                Spacer()

                // Sign Up button with pressure + spot capture
                ZStack {
                    PressureCaptureView(
                        onPressureChanged: { _ in },
                        onClickEnded: { maxP, spotPoint in
                            if canSubmit {
                                let sample = ClickSample(
                                    pressure: maxP,
                                    spot: LocationSpot(xNorm: spotPoint.x, yNorm: spotPoint.y)
                                )
                                handleCreateAccount(unknowingSample: sample)
                            } else {
                                validationMessage = "Please enter NetID and matching passwords."
                                showValidationError = true
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

                    Text("Sign Up with Trio")
                        .font(.headline)
                        .foregroundColor(canSubmit ? Color.accentColor : Color.secondary)
                }
                .frame(width: 220)
                .disabled(!canSubmit)
            }
            .padding(.horizontal, 4)
            .padding(.top, 8)

            Spacer()
        }
        .padding(32)
        .alert("Check your details", isPresented: $showValidationError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
    }

    private var identityCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Create your Trio account")
                .font(.title2)
                .bold()

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("First name")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        TextField("First", text: $firstName)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Last name")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        TextField("Last", text: $lastName)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("SBU ID")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextField("117430677", text: $sbuId)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("SBU email")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextField("firstname.lastname@stonybrook.edu", text: $sbuEmail)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("NetID (stored for Trio)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextField("example123", text: $netId)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Password (not stored by Trio)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    SecureField("Demo only", text: $password)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Confirm password")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    SecureField("Re-type", text: $confirmPassword)
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        )
    }

    private var securityCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How do you usually click?")
                .font(.title3)
                .bold()

            Text("Trio uses your NetID plus how you click as a behavioral factor. Developer beta shows more details; public beta hides them.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Pointer devices on this Mac")
                    .font(.subheadline)
                    .bold()

                Toggle("Built-in trackpad", isOn: $usesBuiltInTrackpad)
                Toggle("External mouse", isOn: $usesMouse)
                Toggle("External trackpad", isOn: $usesExternalTrackpad)
            }
            .toggleStyle(.checkbox)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Use Trio security signals")
                    .font(.subheadline)
                    .bold()

                Toggle("Use click pressure", isOn: $wantsPressure)
                    .toggleStyle(.switch)

                Toggle("Use where I click (click-spot)", isOn: $wantsLocation)
                    .toggleStyle(.switch)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Try Trio pressure")
                    .font(.subheadline)
                    .bold()

                Text("Open a separate page to experiment with click pressure before you sign up.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button {
                    appState.go(to: .signupPressureTry)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "waveform.path.ecg")
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Open Trio pressure tester")
                                .font(.callout.bold())
                            Text("See live Soft / Medium / Firm feedback while you click.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.accentColor.opacity(0.08))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        )
    }

    private func handleCreateAccount(unknowingSample: ClickSample) {
        guard canSubmit else {
            validationMessage = "Please enter NetID and matching passwords."
            showValidationError = true
            return
        }

        appState.startPendingSignup(
            netid: netId,
            usesPressure: wantsPressure,
            usesLocation: wantsLocation,
            unknowingSample: unknowingSample
        )
        appState.go(to: .signupUnknowingReview)
    }
}

#Preview {
    SignupFormView()
        .environmentObject(AppState())
}
