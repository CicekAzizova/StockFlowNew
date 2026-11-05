//
//  ImageSourcePickerModifier.swift
//  StockFlow
//
//  Created by Cicek on 03.11.26.
//
import PhotosUI
import SwiftUI

struct ImageSourcePickerModifier: ViewModifier {

    @Binding var isPresented: Bool
    let title: LocalizedStringKey
    let maxSelectionCount: Int
    let onDelete: (() -> Void)?
    let onImages: ([UIImage]) -> Void

    @Environment(\.openURL) private var openURL

    @State private var isLibraryPresented = false
    @State private var isCameraPresented = false
    @State private var isCameraDeniedPresented = false
    @State private var pickerItems: [PhotosPickerItem] = []

    private var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func body(content: Content) -> some View {
        content
            .confirmationDialog(title, isPresented: $isPresented, titleVisibility: .visible) {
                sourceActions
            }
            .photosPicker(
                isPresented: $isLibraryPresented,
                selection: $pickerItems,
                maxSelectionCount: max(1, maxSelectionCount),
                matching: .images
            )
            .fullScreenCover(isPresented: $isCameraPresented) {
                CameraPicker { image in
                    onImages([image])
                }
                .ignoresSafeArea()
            }
            .alert("Camera access needed", isPresented: $isCameraDeniedPresented) {
                Button("Open Settings", action: openSettings)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Allow camera access in Settings to take photos.")
            }
            .task(id: pickerItems) {
                await loadImages(from: pickerItems)
            }
    }

    // MARK: - Dialog actions

    @ViewBuilder
    private var sourceActions: some View {
        if isCameraAvailable {
            Button("Take Photo") {
                Task { await openCamera() }
            }
        }

        Button("Choose from Library") {
            isLibraryPresented = true
        }

        if let onDelete {
            Button("Delete Photo", role: .destructive, action: onDelete)
        }

        Button("Cancel", role: .cancel) {}
    }

    // MARK: - Camera

    private func openCamera() async {
        switch CameraPermission.current {
        case .granted:
            isCameraPresented = true
        case .notDetermined:
            let access = await CameraPermission.request()
            if access == .granted {
                isCameraPresented = true
            } else {
                isCameraDeniedPresented = true
            }
        case .denied:
            isCameraDeniedPresented = true
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }

    // MARK: - Library

    private func loadImages(from items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }

        var images: [UIImage] = []

        for item in items {
            guard
                let data = try? await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data)
            else { continue }

            images.append(image)
        }

        guard !Task.isCancelled else { return }

        onImages(images)
        pickerItems = []
    }
}

extension View {
    func imageSourcePicker(
        isPresented: Binding<Bool>,
        title: LocalizedStringKey,
        maxSelectionCount: Int = 1,
        onDelete: (() -> Void)? = nil,
        onImages: @escaping ([UIImage]) -> Void
    ) -> some View {
        modifier(
            ImageSourcePickerModifier(
                isPresented: isPresented,
                title: title,
                maxSelectionCount: maxSelectionCount,
                onDelete: onDelete,
                onImages: onImages
            )
        )
    }
}
