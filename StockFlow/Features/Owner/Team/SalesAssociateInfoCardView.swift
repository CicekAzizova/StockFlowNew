//
//  SalesAssociateCardView.swift
//  StockFlow
//
//  Created by Cicek on 05.10.26.
//

import SwiftUI

struct SalesAssociateInfoCardView: View {
    
    var name: String
    var surname: String
    var todaySalesText: String?
    var price: Double?
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.brandPrimary.opacity(0.5))
                    .frame(width: 50,height: 50)
                Text("\(name.prefix(1).uppercased()) \(surname.prefix(1).uppercased())")
                    .font(.inter(.semiBold, size: 16))
                    .foregroundStyle(Color.primary)
            }
        
            VStack(alignment: .leading) {
                Text(name)
                Text(surname)
            }
            .foregroundStyle(.textPrimary)

            Spacer()
            
            if let price {
                VStack(alignment: .leading) {
                    Text("Today's Sales")
                        .foregroundStyle(.textPrimary)
                    Text(
                        price.asCurrency
                    )
                    
                    .foregroundStyle(.textSecondary)                }
                
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.border)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        
    }
}
