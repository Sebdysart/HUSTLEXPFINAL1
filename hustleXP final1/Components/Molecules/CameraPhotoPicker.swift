//
//  CameraPhotoPicker.swift
//  hustleXP final1
//
//  Reusable camera + photo library picker component
//

import SwiftUI
import PhotosUI

struct CameraPhotoPicker: View {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool

    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var photoPickerItem: PhotosPickerItem?

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 12) {
                    Text("Add Photo")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                        .padding(.top, 20)

                    // Camera option
                    Button {
                        showCamera = true
                    } label: {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.title3)
                            Text("Take Photo")
                                .font(.body.weight(.medium))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.textTertiary)
                        }
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }

                    Divider().background(Color.surfaceBorder)

                    // Photo library option
                    PhotosPicker(selection: $photoPickerItem, matching: .images) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title3)
                            Text("Choose from Library")
                                .font(.body.weight(.medium))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.textTertiary)
                        }
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }

                    Divider().background(Color.surfaceBorder)

                    // Cancel
                    Button {
                        isPresented = false
                    } label: {
                        Text("Cancel")
                            .font(.body.weight(.medium))
                            .foregroundColor(.errorRed)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                }
                .background(Color.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 16)
                .padding(.bottom, 34)
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPickerView(image: $selectedImage, isPresented: $showCamera)
                .ignoresSafeArea()
        }
        .onChange(of: photoPickerItem) { _, newValue in
            if let newValue {
                Task {
                    if let data = try? await newValue.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Camera Picker View (UIKit wrapper)
struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView

        init(_ parent: CameraPickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}
