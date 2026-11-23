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
    
    private let locationSwitcher: LocationSwitcher?
    
    enum BarcodeStatus: Equatable {
        case unchecked, checking, available, taken, failed
    }

    var barcodeStatus: BarcodeStatus = .unchecked

    /// Yeni məhsul üçün hər məkanın başlanğıc qalığı (məkan id → say).
    var stockByLocation: [Int: Int] = [:]
    
    var step = 1

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
    var unit: ProductUnit = .piece
    var weight = ""
    var weightUnit = "g"
    var size = ""
    
    var pickerItems: [PhotosPickerItem] = []
    private(set) var selectedImages: [SelectedImage] = []
    private let maxImages = 5

    var validationMessage: String?

    init(
        productStore: ProductsStore,
        imageUploadRepository: ImageUploadRepository,
        locationSwitcher: LocationSwitcher? = nil,
        product: ProductsResponse? = nil,
    ) {
        self.productStore = productStore
        self.imageUploadRepository = imageUploadRepository
        self.locationSwitcher = locationSwitcher
        self.product = product

        guard let product else { return }

        name = product.name
        sku = product.sku
        subcategory = product.subcategory
        description = product.description
        price = Self.text(product.price)
        discount = Self.text(product.discount)
        costPrice = product.costPrice.map { Self.text($0) } ?? ""
        quantity = String(product.quantity)
        lowStockLimit = String(product.lowStockLimit)
        imageUrls = product.imageUrls
        unit = product.unit ?? .piece
        weight = product.weight.map { String($0) } ?? ""
        weightUnit = product.weightUnit ?? "g"
        size = product.size ?? ""
        for stock in product.stocks {
            stockByLocation[stock.locationId] = stock.quantity
        }
    }
    
    /// 112.0 → "112", 12.5 → "12.5"
    private static func text(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(value)
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
    
    // MARK: - Barcode check

    /// Barkod dəyişəndə 0.5 san gözləyib yoxlayır (yazarkən hər hərfdə sorğu getməsin).
    func barcodeChanged() async {
        barcodeStatus = .unchecked
        try? await Task.sleep(for: .milliseconds(500))
        guard !Task.isCancelled else { return }
        await checkBarcode()
    }

    func checkBarcode() async {
        let code = sku.trimmingCharacters(in: .whitespaces)
        guard !code.isEmpty else {
            barcodeStatus = .unchecked
            return
        }
        // Redaktədə məhsulun öz barkodu "artıq var" sayılmır.
        if let product, product.sku.caseInsensitiveCompare(code) == .orderedSame {
            barcodeStatus = .unchecked
            return
        }

        barcodeStatus = .checking
        let result = await productStore.lookupProduct(sku: code)

        // Yoxlama gedərkən istifadəçi barkodu dəyişibsə köhnə nəticə atılır.
        guard code == sku.trimmingCharacters(in: .whitespaces) else { return }

        switch result {
        case .found: barcodeStatus = .taken
        case .notFound: barcodeStatus = .available
        case .failed: barcodeStatus = .failed
        }
    }

    /// Addım 1-dən 2-yə keçməzdən əvvəl: ad və barkod məcburidir, barkod təkrar olmamalıdır.
    func goToNextStep() async {
        guard !name.isBlank, !sku.isBlank else {
            validationMessage = "Name and barcode are required."
            return
        }

        if barcodeStatus != .available {
            await checkBarcode()
        }

        if barcodeStatus == .taken {
            validationMessage = "A product with this barcode already exists."
            return
        }

        validationMessage = nil
        step = 2
    }
    func goToPreviousStep() {
        validationMessage = nil
        step = 1
    }
    
    /// Redaktədə ixtiyari bölmə doludursa avtomatik açıq olsun.
    var hasExtraInfo: Bool {
        (discount.asDecimal ?? 0) > 0
        || !description.isBlank
        || !weight.isBlank
        || !size.isBlank
    }

    static let weightUnits = ["mg", "g", "kg", "ml", "l"]
    
    // MARK: - Profit

    /// Satış və alış qiyməti ikisi də yazılıbsa, bir satışdan qazanc.
    var profit: Double? {
        guard let sell = price.asDecimal, let cost = costPrice.asDecimal, sell > 0 else {
            return nil
        }
        return sell - cost
    }

    /// Marja faizi (qazanc / satış qiyməti).
    var margin: Double? {
        guard let profit, let sell = price.asDecimal, sell > 0 else { return nil }
        return profit / sell * 100
    }
    
    // MARK: - Stock by location

    var locations: [StoreLocation] {
        locationSwitcher?.locations ?? []
    }

    /// Yeni məhsulda başlanğıc qalıq, redaktədə düzəliş. İkisində də hər məkanın kartı görünür.
    var usesLocationStocks: Bool {
        !locations.isEmpty
    }

    var totalStock: Int {
        locations.reduce(0) { $0 + (stockByLocation[$1.id] ?? 0) }
    }

    func loadLocations() async {
        await locationSwitcher?.load()
    }

    /// İlk məkandakı sayı hamısına yazır ("Hamısına eyni").
    func applySameStockForAll() {
        guard let first = locations.first else { return }
        let value = stockByLocation[first.id] ?? 0
        for location in locations {
            stockByLocation[location.id] = value
        }
    }

    //MARK: - Validation
    
    func validateFields() -> Bool {
        // Ad və barkod 1-ci addıma aiddir: boşdursa oraya qaytarırıq.
        if name.isBlank || sku.isBlank {
            step = 1
            validationMessage = "Name and barcode are required."
            return false
        }

        if price.isBlank {
            validationMessage = "Selling price is required."
            return false
        }

        return true
    }
    
    
    /// Boş xana varsa default dəyər götürülür, yazılıb səhvdirsə nil qaytarır.
    private func number(_ text: String, default fallback: Double) -> Double? {
        text.isBlank ? fallback : text.asDecimal
    }

    private func integer(_ text: String, default fallback: Int) -> Int? {
        text.isBlank ? fallback : Int(text)
    }

    private func makeProductRequest() -> ProductRequest? {
        guard validateFields() else {
            return nil
        }

        guard
            let price = price.asDecimal,
            let discount = number(discount, default: 0),
            let costValue = costPrice.isBlank ? .some(nil) : costPrice.asDecimal.map(Optional.some),
            let quantity = integer(quantity, default: 0),
            let lowStockLimit = integer(lowStockLimit, default: 5),
            let weightValue = weight.isBlank ? .some(nil) : weight.asDecimal.map(Optional.some)
        else {
            validationMessage = "Please enter valid values."
            return nil
        }

        let trimmedSize = size.trimmingCharacters(in: .whitespaces)

        let stocks: [InitialStock]? = (product == nil && usesLocationStocks)
            ? locations.map {
                InitialStock(locationId: $0.id, quantity: stockByLocation[$0.id] ?? 0)
            }
            : nil

        return ProductRequest(
            name: name,
            sku: sku,
            description: description,
            price: price,
            discount: discount,
            costPrice: costValue,
            quantity: quantity,
            lowStockLimit: lowStockLimit,
            subcategory: subcategory,
            imageUrls: imageUrls,
            unit: unit,
            weight: weightValue,
            weightUnit: weightValue == nil ? nil : weightUnit,
            size: trimmedSize.isEmpty ? nil : trimmedSize,
            stocks: stocks
        )
    }

   
    //MARK: - Save
    
    /// Yalnız sayı dəyişmiş mağazalar üçün sorğu göndərir. Nəsə dəyişibsə true qaytarır.
    private func applyStockChanges(for product: ProductsResponse) async throws -> Bool {
        var changed = false
        for stock in product.stocks {
            guard let newValue = stockByLocation[stock.locationId],
                  newValue != stock.quantity else { continue }
            try await productStore.setStock(
                id: product.id,
                quantity: newValue,
                locationId: stock.locationId
            )
            changed = true
        }
        return changed
    }
    
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
            
            var response: ProductsResponse

            if let product {
                response = try await productStore.saveProduct(
                    id: product.id,
                    request: request
                )
                // Sayı dəyişmiş mağazalar üçün düzəliş göndərilir.
                if try await applyStockChanges(for: product) {
                    response = await productStore.refreshProduct(sku: response.sku) ?? response
                }
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
