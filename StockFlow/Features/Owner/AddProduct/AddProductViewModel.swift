//
//  AddProductsViewModel.swift
//  StockFlow
//
//  Created by Cicek on 27.09.26.
//

import PhotosUI
import UIKit
import _PhotosUI_SwiftUI

struct SelectedImage: Identifiable {
    let id = UUID()
    let data: Data
    let preview: UIImage
}

@Observable
@MainActor
final class AddProductViewModel {

    private let productStore: ProductsStore
    private let imageUploadRepository: ImageUploadRepository

    var state: AddProductViewState = .idle

    let product: ProductsResponse?

    var name = ""
    var sku = ""
    var subcategory: String?
    var description = ""
    var price = ""
    var discount = ""
    var costPrice = ""
    var quantity = ""
    var lowStockLimit = ""
    var imageUrls: [String]?
    
    var pickerItems: [PhotosPickerItem] = []
    private(set) var selectedImages: [SelectedImage] = []
    private let maxImages = 5

    var validationMessage: String?

    init(
        productStore: ProductsStore,
        imageUploadRepository: ImageUploadRepository,
        product: ProductsResponse? = nil,
    ) {
        self.productStore = productStore
        self.imageUploadRepository = imageUploadRepository
        self.product = product

        guard let product else { return }

        name = product.name
        sku = product.sku
        subcategory = product.subcategory
        description = product.description
        price = String(product.price)
        discount = String(product.discount)
        costPrice = String(product.costPrice)
        quantity = String(product.quantity)
        lowStockLimit = String(product.lowStockLimit)
        imageUrls = product.imageUrls
    }
    
    //MARK: - Images
    
    var existingImageUrls: [String] {
        imageUrls ?? []
    }
    
    var remainingImageSlots: Int {
        max(0, maxImages - existingImageUrls.count)
    }

    func removeExistingImage(at index: Int) {
        guard imageUrls?.indices.contains(index) == true else { return }
        imageUrls?.remove(at: index)
    }
    
    func loadSelectImages() async {
        var loaded: [SelectedImage] = []
        
        for item in pickerItems {
            guard
                let data = try? await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data)?.resized(maxDimension: 1200),
                let jpegData = image.jpegData(compressionQuality: 0.8) else { continue }
            
            loaded.append(SelectedImage(data: jpegData, preview: image))
        }
        selectedImages = loaded
    }
    
    func removeImage(at index: Int) {
        guard selectedImages.indices.contains(index),
              pickerItems.indices.contains(index) else { return }
        selectedImages.remove(at: index)
        pickerItems.remove(at: index)
    }

    //MARK: - Validation
    
    func validateFields() -> Bool {
        let fields = [
            name,
            sku,
            description,
            price,
            discount,
            costPrice,
            quantity,
            lowStockLimit
        ]

        guard fields.allSatisfy({
            !$0.isBlank
        }) else {
            validationMessage = "Please fill in all fields."
            return false
        }

        return true
    }
    
    private func makeProductRequest() -> ProductRequest? {
        guard validateFields() else {
            return nil
        }

        guard
            let price = price.asDecimal,
            let discount = discount.asDecimal,
            let costPrice = costPrice.asDecimal,
            let quantity = Int(quantity),
            let lowStockLimit = Int(lowStockLimit)
        else {
            validationMessage = "Please enter valid values."
            return nil
        }

        return ProductRequest(
            name: name,
            sku: sku,
            description: description,
            price: price,
            discount: discount,
            costPrice: costPrice,
            quantity: quantity,
            lowStockLimit: lowStockLimit,
            subcategory: subcategory,
            imageUrls: imageUrls
        )
    }

   
    //MARK: - Save
    
    func saveProduct() async {
        validationMessage = nil

        guard var request = makeProductRequest() else {
            return
        }

        state = .loading

        do {
            var uploadedUrls = imageUrls ?? []
            
            for image in selectedImages {
                let url = try await imageUploadRepository.uploadImage(image.data)
                uploadedUrls.append(url)
            }

            request.imageUrls = uploadedUrls
            
            let response: ProductsResponse

            if let product {
                response = try await productStore.saveProduct(
                    id: product.id,
                    request: request
                )
            } else {
                response = try await productStore.addProduct(request)
            }

            imageUrls = uploadedUrls
            pickerItems = []
            selectedImages = []
            state = .success(response)
            validationMessage = nil

        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
