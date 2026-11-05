//
//  ProfileTitleBar.swift
//  StockFlow
//
//  Created by Cicek on 04.11.26.
//

import SwiftUI

struct ProfileTitleBar: View {

    var onBellTap: () -> Void = {}

    var body: some View {
        HStack {
            Text("Profile")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Spacer()

            Button(action: onBellTap) {
                Image(systemName: "bell")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}
