//
//  ScanTabModifier.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// Tab bara mərkəzi skan düyməsi əlavə edir və skan ekranını tam ekran açır.
struct ScanTabModifier: ViewModifier {

    @Binding var selection: MainTab
    let dependencies: AppDependencies

    @State private var isPresented = false

    func body(content: Content) -> some View {
        content
            .onChange(of: selection) { oldValue, newValue in
                // Ortadakı tab seçilsə, əvvəlki tab-a qayıdırıq və skanı açırıq.
                guard newValue == .scan else { return }
                selection = oldValue
                isPresented = true
            }
            .overlay(alignment: .bottom) {
                ScanTabButton { isPresented = true }
                    .padding(.bottom, 18)
            }
            .fullScreenCover(isPresented: $isPresented) {
                NewSaleView(dependencies: dependencies, startsWithScanner: true) {
                    selection = .sales
                }
            }
    }
}

extension View {
    func scanTab(selection: Binding<MainTab>, dependencies: AppDependencies) -> some View {
        modifier(ScanTabModifier(selection: selection, dependencies: dependencies))
    }
}
