import SwiftUI
import UIKit

struct KeyboardBackdropView: View {
    let style: KeyboardBackdropStyle
    @State private var customImage: UIImage?

    var body: some View {
        Group {
            switch style {
            case .none:
                TypeTheme.background
            case .carbon:
                LinearGradient(
                    colors: [.black, Color(white: 0.16), .black, Color(white: 0.10)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .aurora:
                LinearGradient(
                    colors: [Color(red: 0.02, green: 0.18, blue: 0.18), .black, Color(red: 0.20, green: 0.04, blue: 0.24)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .midnight:
                RadialGradient(
                    colors: [Color(red: 0.10, green: 0.16, blue: 0.34), .black],
                    center: .topTrailing,
                    startRadius: 10,
                    endRadius: 420
                )
            case .custom:
                if let customImage {
                    Image(uiImage: customImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    TypeTheme.background
                }
            }
        }
        .overlay(style == .none ? Color.clear : Color.black.opacity(0.34))
        .clipped()
        .task(id: style) {
            loadCustomImageIfNeeded()
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func loadCustomImageIfNeeded() {
        guard style == .custom,
              let container = TiloqSettings.sharedContainerURL else {
            customImage = nil
            return
        }

        let url = TiloqSettings.customBackdropURL(in: container)
        customImage = UIImage(contentsOfFile: url.path)
    }
}
