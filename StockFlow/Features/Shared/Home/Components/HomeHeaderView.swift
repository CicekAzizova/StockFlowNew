//
//  HomeHeaderView.swift
//  StockFlow
//
//  Created by Cicek on 08.10.26.
//

import SwiftUI

struct HomeHeaderView: View {

    let user: User
    let subtitle: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading) {
            Text("Hello, \(user.name)")
                .font(.inter(.regular, size: 13))
                .foregroundStyle(.textPrimary)

            Text(user.storeName ?? "")
                .font(.inter(.extraBold, size: 20))

            Text(subtitle)
                .font(.inter(.regular, size: 13))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.success.opacity(0.2))
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )
        }
    }
}
