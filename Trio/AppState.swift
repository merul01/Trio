import SwiftUI
import Combine
import Foundation

final class AppState: ObservableObject {
    @Published var mode: AppMode? = nil
    @Published var authStep: AuthStep = .modeSelection

    @Published var users: [TrioUser] = []
    @Published var currentUser: TrioUser? = nil

    // Pending signup, stored only until signup finishes
    @Published var pendingSignup: PendingSignupData? = nil

    // Last login click (for success + dashboard display)
    @Published var lastLoginSample: ClickSample? = nil

    // Last signup unknowing click (for review screen)
    @Published var signupUnknowingSample: ClickSample? = nil

    func go(to step: AuthStep) {
        withAnimation {
            authStep = step
        }
    }

    func selectMode(_ newMode: AppMode) {
        mode = newMode
        go(to: .login)
    }

    // MARK: - Sign up helpers

    func startPendingSignup(netid: String,
                            usesPressure: Bool,
                            usesLocation: Bool,
                            unknowingSample: ClickSample) {
        let pending = PendingSignupData(
            netid: netid,
            usesPressure: usesPressure,
            usesLocation: usesLocation,
            unknowing: unknowingSample,
            knowing: nil
        )
        pendingSignup = pending
        signupUnknowingSample = unknowingSample
    }

    func storeKnowingSample(_ sample: ClickSample) {
        guard var pending = pendingSignup else { return }
        pending.knowing = sample
        pendingSignup = pending
    }

    func finalizeSignup() {
        guard let pending = pendingSignup,
              let unknowing = pending.unknowing,
              let knowing = pending.knowing else {
            return
        }

        // Build pressure profile if enabled
        var pressureProfile: PressureProfile? = nil
        if pending.usesPressure {
            let avg = (unknowing.pressure + knowing.pressure) / 2.0
            let level = PressureLevel.from(pressure: avg)
            pressureProfile = PressureProfile(
                baselineLevel: level,
                baselineValue: avg
            )
        }

        // Build location profile if enabled
        var locationProfile: LocationProfile? = nil
        if pending.usesLocation {
            let avgX = (unknowing.spot.xNorm + knowing.spot.xNorm) / 2.0
            let avgY = (unknowing.spot.yNorm + knowing.spot.yNorm) / 2.0
            let baseline = LocationSpot(xNorm: avgX, yNorm: avgY)
            locationProfile = LocationProfile(
                baselineSpot: baseline,
                tolerance: 0.25  // generous quarter-of-button radius
            )
        }

        let user = TrioUser(
            netid: pending.netid,
            usesPressure: pending.usesPressure,
            usesLocation: pending.usesLocation,
            pressureProfile: pressureProfile,
            locationProfile: locationProfile
        )

        users.removeAll { $0.netid == user.netid }
        users.append(user)
        currentUser = user

        pendingSignup = nil
        signupUnknowingSample = nil
    }

    // MARK: - Trio authentication on login

    func attemptTrioLogin(netid: String, sample: ClickSample) -> Bool {
        guard let idx = users.firstIndex(where: { $0.netid == netid }) else {
            return false
        }

        var user = users[idx]

        var pressureOK = true
        var locationOK = true

        // Pressure factor: numeric tolerance around baselineValue
        if user.usesPressure, var profile = user.pressureProfile {
            let diff = abs(sample.pressure - profile.baselineValue)
            let tolerance: Double = 0.18   // narrower: clearly separates Medium vs Firm

            if diff <= tolerance {
                // Accepted; adapt baseline slightly towards new sample
                let alpha = 0.3
                profile.baselineValue =
                    profile.baselineValue * (1 - alpha) + sample.pressure * alpha
                profile.baselineLevel = PressureLevel.from(pressure: profile.baselineValue)
                user.pressureProfile = profile
            } else {
                pressureOK = false
            }
        }

        // Location factor: generous radius
        if user.usesLocation, var locProfile = user.locationProfile {
            let dx = sample.spot.xNorm - locProfile.baselineSpot.xNorm
            let dy = sample.spot.yNorm - locProfile.baselineSpot.yNorm
            let dist = sqrt(dx * dx + dy * dy)

            if dist <= locProfile.tolerance {
                // Adapt baseline spot slightly
                let alpha = 0.3
                let newX = locProfile.baselineSpot.xNorm * (1 - alpha) + sample.spot.xNorm * alpha
                let newY = locProfile.baselineSpot.yNorm * (1 - alpha) + sample.spot.yNorm * alpha
                locProfile.baselineSpot = LocationSpot(xNorm: newX, yNorm: newY)
                user.locationProfile = locProfile
            } else {
                locationOK = false
            }
        }

        let ok = pressureOK && locationOK
        users[idx] = user

        if ok {
            currentUser = user
            lastLoginSample = sample
        }

        return ok
    }

    func clearForNewSession() {
        currentUser = nil
        lastLoginSample = nil
        pendingSignup = nil
        signupUnknowingSample = nil
        // users remain in memory; full reset when the app restarts
    }
}
