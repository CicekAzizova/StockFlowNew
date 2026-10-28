//
//  SummaryGridView.swift
//  StockFlow
//
//  Created by Cicek on 06.10.26.
//
import SwiftUI

struct SummaryGridView: View {
    
    let title: LocalizedStringKey
    let value: String
    let icon: String
    let iconColor: Color
    var compactValue: String? = nil
    
    init(title: LocalizedStringKey, amount: Double, icon: String, iconColor: Color) {
        self.title = title
        self.value = amount.asCurrency
        self.compactValue = amount.asCompactCurrency
        self.icon = icon
        self.iconColor = iconColor
    }
    
    init(title: LocalizedStringKey, value: String, icon: String, iconColor: Color) {
        self.title = title
        self.value = value
        self.compactValue = nil
        self.icon = icon
        self.iconColor = iconColor
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 50, height: 50)
                .background(iconColor.opacity(0.08))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                ViewThatFits(in: .horizontal){
                    amountText(value)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    amountText(compactValue ?? value)
                        .fixedSize(horizontal: true, vertical: false)
                    amountText(compactValue ?? value)
                        .minimumScaleFactor(0.5)
                }
                
                Text(title)
                    .font(.inter(.regular, size: 12))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 0)
            
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
        .background(.border)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.15), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
    
    private func amountText(_ text: String) -> some View {
        Text(text)
            .font(.inter(.extraBold, size: 22))
            .foregroundStyle(.primary)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
    }
    
}
