//
//  BarcodeInputView.swift
//  StockFlow
//
//  Created by Cicek on 13.10.26.
//

import SwiftUI
import VisionKit

struct BarcodeInputView: View {
    
    @State private var access = CameraPermission.current
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    var placeholder = "Enter barcode manually"
    var showsManualEntry = true
    let onCode: (String) -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            camera
                .ignoresSafeArea()
            
            if showsManualEntry {
                ManualCodeEntryView(placeholder: placeholder, onSubmit: onCode)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                access = CameraPermission.current
            }
        }
    }
    
    @ViewBuilder
    private var camera: some View {
        switch access {
        case .granted:
            if BarcodeScannerView.isAvailable {
                BarcodeScannerView(onScan: onCode)
            } else {
                unavailableView
            }
            
        case .notDetermined:
            ProgressView()
                .task { access = await CameraPermission.request() }
            
        case .denied:
            ContentUnavailableView {
                Label("Camera access needed", systemImage: "camera.slash")
            } description: {
                Text(showsManualEntry
                     ? "Allow camera access in Settings, or enter the code manually below."
                     : "Allow camera access in Settings to scan barcodes.")
            } actions: {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
            }
        }
    }
    
    private var unavailableView: some View {
        ContentUnavailableView {
            Label("Camera unavailable", systemImage: "camera.slash")
        } description: {
            Text(
                DataScannerViewController.isSupported
                ? "If you just allowed camera access, close the app completely and open it again."
                : (showsManualEntry
                   ? "Enter the code manually below."
                   : "Close this screen and type the barcode.")
            )
        }
    }
}
