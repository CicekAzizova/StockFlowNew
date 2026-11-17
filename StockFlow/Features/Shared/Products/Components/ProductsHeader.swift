//
//  ProductsHeader.swift
//  StockFlow
//
//  Created by Cicek on 09.10.26.
//

import SwiftUI

struct ProductsHeader: View {
    
    let count: Int
    var onAdd: (() -> Void)?
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Products")
                        .font(.inter(.bold, size: 24))
                    Text("\(count)")
                        .font(.inter(.regular, size: 14))
                        .foregroundStyle(.textSecondary)
                    ActiveLocationChip()
                }
                Spacer()
                
                if let onAdd {
                    Button(action: onAdd) {
                        Image(systemName: "plus")
                            .font(.inter(.extraBold, size: 18))
                            .foregroundStyle(.white)
                            .frame(width: 44,height: 44)
                            .background(.brandPrimary.opacity(0.95))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            
        }
    }
}
