import SwiftUI

struct SetupStepCard: View {
    let step: SetupGuideContent.Step

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(TypeTheme.elevated)
                Image(systemName: step.symbol)
                    .font(.headline)
                    .foregroundStyle(step.id == 4 ? TypeTheme.rewrite : .white)
            }
            .frame(width: 48, height: 48)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text("STEP \(step.id)")
                    .font(.caption)
                    .tracking(1.5)
                    .foregroundStyle(.secondary)
                Text(step.title)
                    .font(.headline)
                Text(step.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color.secondary.opacity(0.12))
        .clipShape(.rect(cornerRadius: 10))
        .accessibilityElement(children: .combine)
    }
}
