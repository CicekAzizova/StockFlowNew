//
//  AddProductImageView.swift
//  StockFlow
//
//  Created by Cicek on 28.09.26.
//

import SwiftUI
import PhotosUI
import UIKit

struct AddProductImageView: View {
    
    @Bindable var viewModel: AddProductViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Product images")
                .font(.inter(.regular, size: 16))
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 12) {
                    
                    ForEach(Array(viewModel.existingImageUrls.enumerated()), id: \.offset) { index, url in
                        
                        ZStack(alignment: .topTrailing) {
                            
                            RemoteImageView(imageUrl: url, width: 85, height: 85, cornerRadius: 12)
                            
                            removeButton {
                                viewModel.removeExistingImage(at: index)
                            }
                        }
                    }
                    
                    ForEach(Array(viewModel.selectedImages.enumerated()), id: \.element.id) { index, image in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image.preview)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 85, height: 85)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            removeButton {
                                viewModel.removeImage(at: index)
                            }
                        }
                    }
                    if viewModel.remainingImageSlots - viewModel.pickerItems.count > 0 {
                        
                        PhotosPicker(
                            selection: $viewModel.pickerItems,
                            maxSelectionCount: viewModel.remainingImageSlots,
                            matching: .images
                        ) {
                            
                            VStack(spacing: 6) {
                                
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 24))
                                
                                Text("Add images")
                                    .font(.inter(.regular, size: 14))
                            }
                            .foregroundStyle(.textPrimary)
                            .frame(width: 120, height: 85)
                            .background(.border)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 14)
                            )
                        }
                    }
                }
                .padding(12)
            }
            .frame(height: 110)
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        .gray,
                        style: StrokeStyle(
                            lineWidth: 1,
                            dash: [6, 4]
                        )
                    )
            }
        }
        .onChange(of: viewModel.pickerItems) { _, _ in
            Task {
                await viewModel.loadSelectImages()
            }
        }
    }
    
    private func removeButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.white, .red)
                .font(.system(size: 20))
        }
        .offset(x: 6, y: -6)
    }
}
