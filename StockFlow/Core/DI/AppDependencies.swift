//
//  AppDependencies.swift
//  StockFlow
//
//  Created by Cicek on 21.09.26.
//


final class AppDependencies {
    let networkService: NetworkService
    
    let tokenStorage: TokenStoring
    
    let appLockManager: AppLockManager
    
    let languageManager: LanguageManager
    
    let appPreferences: AppPreferences
    
    let authRepository: AuthRepository
    
    let storeRepository: StoreRepository
    
    let userRepository: UserRepository
    
    let productRepository: ProductRepository
    
    let imageUploadRepository: ImageUploadRepository
    
    let productsStore: ProductsStore
    
    let sellerRepository: SellerRepository
    
    let salesStore: SalesStore
    let salesRepository: SalesRepository
    
    

    init() {
        let tokenStorage = KeychainWrapper()
        
        let pinStore = KeychainPinStore(keychain: KeychainService())
        
        let appLockManager = AppLockManager(pinStore: pinStore, biometrics: BiometricAuthenticator())
        
        let languageManager = LanguageManager()
        
        let appPreferences = AppPreferences()
        
        let networkService = DefaultNetworkService(tokenStoring: tokenStorage, tokenRefresher: TokenRefresher(tokenStorage: tokenStorage))

 
        let authRepository = DefaultAuthRepository(
            networkService: networkService,
            tokenStorage: tokenStorage
        )

        let storeRepository = DefaultStoreRepository(
            networkService: networkService,
            tokenStorage: tokenStorage
        )
        
        let userRepository = DefaultUserRepository(
            networkService: networkService, tokenStorage: tokenStorage
        )
        
        let productRepository = DefaultProductRepository(networkService: networkService)
        
        let imageUploadRepository = DefaultImageUploadRepository(networkService: networkService)
        
        let productsStore = ProductsStore(productRepository: productRepository)
        
        let sellerRepository = DefaultSellerRepository(networkService: networkService)
 
        let salesRepository = DefaultSalesRepository(networkService: networkService)
        let salesStore = SalesStore(salesRepository: salesRepository)
        
        self.tokenStorage = tokenStorage
        self.networkService = networkService
        self.appLockManager = appLockManager
        self.languageManager = languageManager
        self.appPreferences = appPreferences

        self.authRepository = authRepository
        
        self.storeRepository = storeRepository
        
        self.userRepository = userRepository
        
        self.productRepository = productRepository
        
        self.imageUploadRepository = imageUploadRepository
        
        self.productsStore = productsStore
        
        self.sellerRepository = sellerRepository
        
        self.salesRepository = salesRepository
        self.salesStore = salesStore
    }

    #if DEBUG
    init(
        tokenStorage: TokenStoring,
        authRepository: AuthRepository,
        storeRepository: StoreRepository,
        userRepository: UserRepository,
        productRepository: ProductRepository,
        imageUploadRepository: ImageUploadRepository,
        sellerRepository: SellerRepository,
        salesRepository: SalesRepository
    ) {
        self.tokenStorage = tokenStorage
        self.appLockManager = AppLockManager(pinStore: KeychainPinStore(keychain: KeychainService()), biometrics: BiometricAuthenticator())
        self.networkService = DefaultNetworkService(tokenStoring: tokenStorage, tokenRefresher: TokenRefresher(tokenStorage: tokenStorage))
        self.authRepository = authRepository
        self.storeRepository = storeRepository
        self.userRepository = userRepository
        self.productRepository = productRepository
        self.imageUploadRepository = imageUploadRepository
        self.productsStore = ProductsStore(productRepository: productRepository)
        self.sellerRepository = sellerRepository
        self.salesRepository = salesRepository
        self.salesStore = SalesStore(salesRepository: salesRepository)
        self.languageManager = LanguageManager()
        self.appPreferences = AppPreferences()
    }
    #endif

    @MainActor
    func makeLoginViewModel(    appStateManager: AppStateManager) -> LoginViewModel {
        LoginViewModel(
            authRepository: authRepository, appStateManager: appStateManager
        )
    }

    @MainActor
    func makeCreateStoreViewModel(appStateManager: AppStateManager) -> CreateStoreViewModel {
        CreateStoreViewModel(
            storeRepository: storeRepository, appStateManager: appStateManager
        )
    }
    
    @MainActor
    func makeProfileViewModel(appStateManager: AppStateManager) -> ProfileViewModel {
        ProfileViewModel(
            userRepository: userRepository,
            appStateManager: appStateManager,
            productsStore: productsStore,
            salesStore: salesStore,
            storeRepository: storeRepository
        )
    }
    
    @MainActor
    func makeAddProductViewModel(product: ProductsResponse? = nil) -> AddProductViewModel {
        AddProductViewModel(productStore: productsStore, imageUploadRepository: imageUploadRepository,
            product: product)
    }
    
    @MainActor
    func makeProductViewModel() -> ProductViewModel {
        ProductViewModel(productStore: productsStore)
    }
    
    @MainActor
    func makeProductDetailViewModel(product: ProductsResponse) -> ProductDetailViewModel {
        ProductDetailViewModel(productStore: productsStore, product: product)
    }
    
    @MainActor
    func makeHomeViewModel(includesTeam: Bool = false) -> HomeViewModel {
        HomeViewModel(
            productStore: productsStore,
            salesStore: salesStore,
            sellerRepository: includesTeam ? sellerRepository : nil
        )
    }
    
    @MainActor
    func makeAddSellerViewModel(seller: SellerResponse? = nil) -> AddSellerViewModel {
        AddSellerViewModel(repository: sellerRepository, associate: seller)
    }
    
    @MainActor
    func makeTeamViewModel() -> TeamViewModel {
        TeamViewModel(repository: sellerRepository)
    }
    
    @MainActor
    func makeSellerDetailViewModel(seller: SellerResponse) -> SellerDetailViewModel {
        SellerDetailViewModel(repository: sellerRepository, salesRepository: salesRepository, associate: seller)
    }
    
    @MainActor
    func makeSellerSalesViewModel() -> SellerSalesViewModel {
        SellerSalesViewModel(salesStore: salesStore)
    }
    
    @MainActor
    func makeSalesHistoryViewModel() -> SalesHistoryViewModel {
        SalesHistoryViewModel(salesStore: salesStore)
    }
    
    @MainActor
    func makeLowStockViewModel() -> LowStockViewModel {
        LowStockViewModel(productStore: productsStore)
    }
    
    func makeScanProductViewModel() -> ScanProductViewModel {
        ScanProductViewModel(
            productRepository: productRepository,
            salesStore: salesStore, productsStore: productsStore
        )
    }
}
