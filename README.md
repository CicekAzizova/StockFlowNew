# StockFlow

![Tests](https://github.com/CicekAzizova/StockFlow/actions/workflows/tests.yml/badge.svg)

StockFlow is an inventory and sales management app for small stores, built with SwiftUI.
A store **owner** manages products, the sales team and sales reports.
A **sales associate** scans products and records sales.

## Screenshots

| Splash | Login | Home |
|:--:|:--:|:--:|
| <img src="Screenshots/01-splash.png" width="220"> | <img src="Screenshots/02-login.png" width="220"> | <img src="Screenshots/03-products.png" width="220"> |

| Product Detail | Add Product | Edit Product |
|:--:|:--:|:--:|
| <img src="Screenshots/04-product-detail.png" width="220"> | <img src="Screenshots/05-add-product.png" width="220"> | <img src="Screenshots/09-edit-products.png" width="220"> |

| Scan Product | Sales | Sale Details |
|:--:|:--:|:--:|
| <img src="Screenshots/10-scan-product.png" width="220"> | <img src="Screenshots/06-sales.png" width="220"> | <img src="Screenshots/07-sale-details.png" width="220"> |

| Dark Mode |
|:--:|
| <img src="Screenshots/08-products-dark.png" width="220"> |

## Features

**Owner**
- Dashboard with today's sales, orders, low-stock products and recent sales
- Product management: create, edit, delete, up to 5 images, barcode (SKU) scanning
- Team management: add and remove sales associates, view each associate's sales
- Sales history with details

**Sales associate**
- Scan a product barcode (or enter the SKU manually) and complete a sale
- Own sales history and profile

**General**
- Splash screen while the session is restored
- JWT authentication, token stored in Keychain, automatic logout when the session expires
- Pagination, pull to refresh
- Product filter (All / In Stock / Low Stock / Out of Stock) is remembered between launches
- Camera permission handling: the app asks for access and offers a shortcut to Settings if it was denied
- Loading, error and empty states on every screen
- Dark mode support

## Tech Stack

- SwiftUI, NavigationStack, TabView, sheets
- Observation (`@Observable`), `@State`, `@Binding`
- Swift Concurrency (`async/await`)
- URLSession-based network layer
- Keychain for secure token storage, `UserDefaults` for lightweight preferences (selected product filter)
- PhotosUI (image picking), VisionKit `DataScanner` (barcode scanning)
- SwiftUI Previews with sample data (Success / Empty / Error / Loading states)
- Swift Testing + XCTest (unit and UI tests)
- GitHub Actions (CI)
- Backend: Node.js, Express, SQLite ([StockFlowBackend](https://github.com/CicekAzizova/StockFlowBackend))

## Architecture

The app follows **MVVM** with a repository layer and dependency injection.

```
View  →  ViewModel  →  Store / Repository  →  NetworkService  →  API
```

- **View**: SwiftUI views, no business logic or networking.
- **ViewModel**: `@Observable` classes that hold screen state (`idle / loading / loaded / error`) and call repositories.
- **Repository**: protocols (`ProductRepository`, `SalesRepository`, ...) with default implementations on top of `NetworkService`. Protocols make them easy to mock in tests.
- **Stores**: `ProductsStore` and `SalesStore` keep shared data in sync across screens (Home, Products, Low Stock, Product Detail).
- **Dependency injection**: `AppDependencies` creates repositories and builds every ViewModel. `UserDefaults` is injected into `ProductViewModel` too, so tests use an isolated instance.
- **Networking**: `Endpoint` protocol describes requests; `NetworkService` executes them. A `401` response posts a notification that logs the user out.

### Project structure

```
StockFlow/
├── App/            app entry point, app state, routing
├── Core/           config, DI, extensions, navigation, network, permissions, preview data, security, stores, reusable UI
├── Features/       Owner, SalesAssociate and Shared screens (View + ViewModel + State)
├── Models/         request and response models
├── Repositories/   repository protocols and implementations
└── Resources/      fonts, assets
StockFlowTests/     unit tests and mocks
StockFlowUITests/   UI tests
```

## Getting Started

> The app needs the backend running on the same Mac. Start it first, then run the app.

**Requirements:** Xcode 26+, Node.js 18+

### 1. Run the backend
```bash
git clone https://github.com/CicekAzizova/StockFlowBackend.git
cd StockFlowBackend
npm install
npm start
```
The server runs on `http://localhost:3000`. API docs: `http://localhost:3000/api-docs`.

### 2. Run the app
```bash
git clone https://github.com/CicekAzizova/StockFlow.git
open StockFlow/StockFlow.xcodeproj
```
Select an iPhone simulator and press `Cmd + R`. The simulator connects to `http://localhost:3000` automatically.

### Test accounts
| Role | Email | Password |
|------|-------|----------|
| Owner | owner@gmail.com | 123456 |
| Sales associate | seller2@test.com | 1234567 |

### Real device (optional)
Barcode scanning needs a real device (the simulator has no camera; use manual SKU entry there).
Set your Mac's address in `StockFlow/Core/Config/AppConfig.swift`, either its IP (`ipconfig getifaddr en0`) or its Bonjour name (`<LocalHostName>.local`, see `scutil --get LocalHostName`).
The iPhone and the Mac must be on the same
