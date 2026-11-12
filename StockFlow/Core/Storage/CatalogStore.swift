//
//  CatalogStore.swift
//  StockFlow
//
//  Created by Cicek on 11.11.26.
//
import Foundation

@Observable
@MainActor
final class CatalogStore {
    private let catalogRepository: CatalogRepository

    var categories: [CatalogCategory] = []
    var isLoading = false
    var errorMessage: String?

    init(catalogRepository: CatalogRepository) {
        self.catalogRepository = catalogRepository
    }

    /// Artıq yüklənibsə təkrar sorğu göndərmir.
    func loadIfNeeded() async {
        guard categories.isEmpty, !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            categories = try await catalogRepository.getCategories()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func category(code: String) -> CatalogCategory? {
        categories.first { $0.code == code }
    }

    /// Verilən əsas kateqoriyaların alt kateqoriyaları (məhsul əlavə edəndə lazım olacaq).
    func categories(for codes: [String]) -> [CatalogCategory] {
        categories.filter { codes.contains($0.code) }
    }

    /// "food.dairy" kodundan alt kateqoriyanı tapır.
    func subcategory(code: String) -> CatalogSubcategory? {
        categories.lazy.flatMap(\.subcategories).first { $0.code == code }
    }
}
