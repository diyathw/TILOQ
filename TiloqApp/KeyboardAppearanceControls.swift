import PhotosUI
import SwiftUI
import UIKit

struct KeyboardAppearanceControls: View {
    @AppStorage(
        TiloqSettings.rgbLightingKey,
        store: TiloqSettings.sharedDefaults
    ) private var rgbLightingEnabled = false
    @AppStorage(
        TiloqSettings.keyboardBackdropKey,
        store: TiloqSettings.sharedDefaults
    ) private var backdropValue = KeyboardBackdropStyle.none.rawValue
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showsImportError = false

    var body: some View {
        let isCustomSelected = backdropValue == KeyboardBackdropStyle.custom.rawValue

        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $rgbLightingEnabled) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("RGB Keys")
                    Text("Animated lighting and color around every key")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityHint("Adds gaming keyboard style lighting")

            Divider()

            Text("Keyboard Background")
                .font(.subheadline.weight(.medium))

            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(KeyboardBackdropStyle.allCases.filter { $0 != .custom }) { style in
                        Button {
                            backdropValue = style.rawValue
                            Haptics.tap()
                        } label: {
                            VStack(spacing: 6) {
                                KeyboardBackdropView(style: style)
                                    .frame(width: 62, height: 46)
                                    .clipShape(.rect(cornerRadius: 8))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(
                                                backdropValue == style.rawValue ? TypeTheme.rewrite : Color.white.opacity(0.12),
                                                lineWidth: backdropValue == style.rawValue ? 2 : 1
                                            )
                                    }
                                Text(style.rawValue)
                                    .font(.caption2)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(backdropValue == style.rawValue ? .isSelected : [])
                    }

                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        VStack(spacing: 6) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title3)
                                .frame(width: 62, height: 46)
                                .background(Color.white.opacity(0.07))
                                .clipShape(.rect(cornerRadius: 8))
                                .overlay {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(
                                            isCustomSelected ? TypeTheme.rewrite : Color.white.opacity(0.12),
                                            lineWidth: isCustomSelected ? 2 : 1
                                        )
                                }
                            Text("Choose Photo")
                                .font(.caption2)
                                .foregroundStyle(.primary)
                        }
                    }
                    .accessibilityHint("Selects a private keyboard background image")
                }
                .padding(.vertical, 2)
            }
            .scrollIndicators(.hidden)

            Text("Photos are resized and stored only on this device.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .onChange(of: selectedPhoto) { _, item in
            Task { await importPhoto(item) }
        }
        .alert("Couldn’t Use Photo", isPresented: $showsImportError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Choose another image and try again.")
        }
    }

    @MainActor
    private func importPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }

        do {
            guard let sourceData = try await item.loadTransferable(type: Data.self),
                  let optimizedData = optimizedImageData(from: sourceData),
                  let container = TiloqSettings.sharedContainerURL else {
                throw CocoaError(.fileReadCorruptFile)
            }

            try TiloqSettings.saveCustomBackdrop(optimizedData, in: container)
            backdropValue = KeyboardBackdropStyle.custom.rawValue
            Haptics.success()
        } catch {
            showsImportError = true
        }
    }

    @MainActor
    private func optimizedImageData(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let maximumDimension: CGFloat = 1280
        let largestDimension = max(image.size.width, image.size.height)
        let scale = min(1, maximumDimension / largestDimension)
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        format.scale = 1
        let rendered = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return rendered.jpegData(compressionQuality: 0.78)
    }
}
