import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            switch appState.authStep {
            case .modeSelection:
                ModeSelectionView()
            case .login:
                LoginView()
            case .duoFactor:
                DuoFactorView()
            case .emailOtpFallback:
                EmailOtpView()
            case .dashboard:
                DashboardView()
            case .signupForm:
                SignupFormView()
            case .signupUnknowingReview:
                SignupUnknowingReviewView()
            case .signupSuccess:
                SignupSuccessView()
            case .loginSuccess:
                LoginSuccessView()
            case .signupPressureTry:
                SignupPressureTryView()
            }
        }
        .frame(minWidth: 760, minHeight: 520)
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
}
