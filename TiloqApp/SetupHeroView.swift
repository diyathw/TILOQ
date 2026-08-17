import SwiftUI

struct SetupHeroView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(TypeTheme.elevated)
                    .frame(width: 88, height: 88)
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 6)
                Text("T")
                    .font(.largeTitle.bold())
                    .frame(width: 88, height: 88)
                Image(systemName: "sparkles")
                    .font(.caption.bold())
                    .foregroundStyle(TypeTheme.rewrite)
                    .padding(12)
            }
            .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("TILOQ")
                    .font(.title.bold())
                    .tracking(3)
                Text("Write. Fix. Done.")
                    .font(.headline)
                Text("Ready in under a minute.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}
