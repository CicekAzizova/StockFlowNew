//
//  CameraPicker.swift
//  StockFlow
//
//  Created by Cicek on 03.11.26.
//

import SwiftUI
import UIKit

struct CameraPicker: UIViewControllerRepresentable {
    
    let onImage: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onImage: onImage, onClose: { dismiss() })
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        private let onImage: (UIImage) -> Void
        private let onClose: () -> Void
        
        init(onImage: @escaping (UIImage) -> Void, onClose: @escaping () -> Void) {
            self.onImage = onImage
            self.onClose = onClose
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImage(image)
            }
            onClose()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onClose()
        }
        
    }
}
