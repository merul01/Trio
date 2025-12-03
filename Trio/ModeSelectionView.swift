import SwiftUI

struct ModeSelectionView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 24) {
            Text("Trio")
                .font(.system(size: 40, weight: .bold, design: .rounded))

            Text("Choose how you want to run Trio on this Mac.")
                .font(.title3)
                .foregroundStyle(.secondary)

            HStack(spacing: 20) {
                ModeCard(
                    title: AppMode.developerBeta.displayName,
                    description: AppMode.developerBeta.description
                ) {
                    appState.selectMode(.developerBeta)
                }

                ModeCard(
                    title: AppMode.publicBeta.displayName,
                    description: AppMode.publicBeta.description
                ) {
                    appState.selectMode(.publicBeta)
                }
            }

            Text("Developer Beta exposes pressure and click-spot visuals for debugging. Public Beta hides raw values and feels closer to a Duo-like login.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .padding(32)
    }
}

struct ModeCard: View {
    let title: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: 260, minHeight: 140, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .shadow(radius: 4, y: 3)
            )
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    ModeSelectionView()
        .environmentObject(AppState())
}
