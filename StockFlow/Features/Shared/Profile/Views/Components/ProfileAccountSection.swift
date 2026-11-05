//
//  ProfileAccountSection.swift
//  StockFlow
//
//  Created by Cicek on 03.11.26.
//

import SwiftUI

struct ProfileAccountSection: View {

    let user: User
    @Binding var path: NavigationPath
    let onChangePasswordTap: () -> Void

    var body: some View {
        AppSectionView("Account") {
            Button {
                path.append(ProfileRoute.personalInformation)
            } label: {
                AppRowView(icon: "person", tint: .blue, title: "Personal Information") {
                    AppRowDisclosure()
                }
            }

            if user.role == .owner {
                Button {
                    path.append(ProfileRoute.team)
                } label: {
                    AppRowView(icon: "person.2", tint: .brandCoral, title: "Team") {
                        AppRowDisclosure()
                    }
                }

                Button(action: onChangePasswordTap) {
                    AppRowView(icon: "lock", tint: .brandGreen, title: "Change Password") {
                        AppRowDisclosure()
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}
