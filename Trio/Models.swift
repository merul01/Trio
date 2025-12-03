import Foundation

// MARK: - Modes

enum AppMode: String, CaseIterable, Identifiable, Codable {
    case developerBeta
    case publicBeta

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .developerBeta:
            return "Developer Beta Testing"
        case .publicBeta:
            return "Public Beta"
        }
    }

    var description: String {
        switch self {
        case .developerBeta:
            return "Shows raw pressures, spots, and debugging info for HCI testing."
        case .publicBeta:
            return "Looks like a polished Duo-style login with Trio running quietly."
        }
    }
}

// MARK: - Navigation

enum AuthStep {
    case modeSelection
    case login
    case duoFactor
    case emailOtpFallback
    case dashboard
    case signupForm
    case signupUnknowingReview
    case signupSuccess
    case loginSuccess
    case signupPressureTry
}

// MARK: - Behavioral Types

enum PressureLevel: String, Codable {
    case soft
    case medium
    case firm

    var displayName: String {
        switch self {
        case .soft: return "Soft"
        case .medium: return "Medium"
        case .firm: return "Firm"
        }
    }

    var representativeValue: Double {
        switch self {
        case .soft: return 0.2
        case .medium: return 0.6
        case .firm: return 0.9
        }
    }

    /// Map a numeric value 0...1 into discrete levels.
    /// With our new capture logic, we mainly see 0.0, 0.6, 0.9.
    static func from(pressure value: Double) -> PressureLevel {
        switch value {
        case ..<0.3: return .soft
        case ..<0.8: return .medium
        default:      return .firm
        }
    }
}

struct LocationSpot: Codable {
    var xNorm: Double  // 0...1 within element width
    var yNorm: Double  // 0...1 within element height
}

// Main profiles used for authentication

struct PressureProfile: Codable {
    var baselineLevel: PressureLevel
    var baselineValue: Double  // numeric mean, used for adaptation
}

struct LocationProfile: Codable {
    var baselineSpot: LocationSpot
    var tolerance: Double      // radius in normalized units, e.g. 0.25
}

// For single clicks (used both in signup & login)

struct ClickSample: Codable {
    var pressure: Double
    var spot: LocationSpot
}

// Stored user — note: only NetID + behavioral choices & profiles

struct TrioUser: Identifiable, Codable {
    var id: UUID = UUID()
    var netid: String

    var usesPressure: Bool
    var usesLocation: Bool

    var pressureProfile: PressureProfile?
    var locationProfile: LocationProfile?
}

// Pending signup before we create a TrioUser

struct PendingSignupData {
    var netid: String
    var usesPressure: Bool
    var usesLocation: Bool

    var unknowing: ClickSample?
    var knowing: ClickSample?
}
