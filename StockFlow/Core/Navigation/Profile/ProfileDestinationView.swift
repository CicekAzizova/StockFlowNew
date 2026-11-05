//
//  ProfileDestinationView.swift
//  StockFlow
//
//  Created by Cicek on 04.11.26.
//

import SwiftUI

struct ProfileDestinationView: View {

    let route: ProfileRoute
    let user: User?
    let dependencies: AppDependencies
    @Binding var path: NavigationPath
    var canManageTeam: Bool = false

    var body: some View {
        switch route {
        case .personalInformation:
            if let user {
                PersonalInformationView(user: user)
            }

        case .team where canManageTeam:
            TeamView(
                path: $path,
                viewModel: dependencies.makeTeamViewModel()
            )
        default:
            EmptyView()
        }
    }
}
