import SwiftUI

struct PressureIndicatorView: View {
    var pressure: Double

    private var level: PressureLevel {
        PressureLevel.from(pressure: pressure)
    }

    private var color: Color {
        switch level {
        case .soft:   return .green
        case .medium: return .orange
        case .firm:   return .red
        }
    }

    var body: some View {
        Text("\(level.displayName) • \(String(format: "%.2f", pressure))")
            .font(.callout.bold())
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(color.opacity(0.9))
            )
            .foregroundColor(.white)
    }
}

#Preview {
    VStack(spacing: 12) {
        PressureIndicatorView(pressure: 0.15)
        PressureIndicatorView(pressure: 0.55)
        PressureIndicatorView(pressure: 0.9)
    }
    .padding()
}
