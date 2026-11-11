//
//  ProfileView.swift
//  StockFlow
//
//  Created by Cicek on 25.09.26.
//

import SwiftUI

struct ProfileView: View {

    @State private var viewModel: ProfileViewModel
    let appStateManager: AppStateManager

    @Binding var path: NavigationPath

    @State private var isAvatarOptionsPresented = false
    @State private var isEditProfilePresented = false
    @State private var isChangePasswordPresented = false
    @State private var isDeleteAccountPresented = false

    init(
        viewModel: ProfileViewModel,
        appStateManager: AppStateManager,
        path: Binding<NavigationPath>
    ) {
        _viewModel = State(initialValue: viewModel)
        _path = path
        self.appStateManager = appStateManager
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.background
                .ignoresSafeArea()

            if let user = viewModel.user {
                profileView(user: user)
            } else {
                ProgressView()
                    .tint(.brandTeal)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.loadStats() }
        .deleteAccountAlert(isPresented: $isDeleteAccountPresented) { password in
            await viewModel.deleteAccount(password: password)
        }
        .sheet(isPresented: $isEditProfilePresented) {
            if let user = viewModel.user {
                EditProfileView(viewModel: viewModel, user: user)
            }
        }
        .sheet(isPresented: $isChangePasswordPresented) {
            ChangePasswordView(viewModel: viewModel)
        }
    }

    // MARK: - Loaded

    private func profileView(user: User) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                BrandScreenHeader(title: "Profile") {
                    BrandHeaderIconButton(
                        systemImage: "bell",
                        accessibilityLabel: "Notifications"
                    ) {
                        // Bildirişlər sonra bağlanacaq
                    }
                }

                header(user: user)
            }
            .padding(.bottom, 6)
            .brandHeaderBackground()
            

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if let error = viewModel.avatarError {
                        Text(verbatim: error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    ProfileAccountSection(
                        user: user,
                        path: $path,
                        onChangePasswordTap: { isChangePasswordPresented = true }
                    )

                    ProfileSettingsSection(user: user) { code in
                        await viewModel.updateCurrency(code)
                    }

                    ProfileAccountActionsSection(
                        user: user,
                        onLogout: { appStateManager.logout() },
                        onDeleteAccount: { isDeleteAccountPresented = true }
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
        }
    }

    private func header(user: User) -> some View {
        ProfileHeaderCard(
            user: user,
            stats: stats,
            isUploadingAvatar: viewModel.isUploadingAvatar,
            onAvatarTap: { isAvatarOptionsPresented = true },
            onEditTap: { isEditProfilePresented = true }
        )
        .imageSourcePicker(
            isPresented: $isAvatarOptionsPresented,
            title: "Profile photo",
            maxSelectionCount: 1,
            onDelete: deleteAvatarAction(for: user)
        ) { images in
            guard let image = images.first else {
                viewModel.avatarError = String(localized: "Could not read the selected image.")
                return
            }
            Task { await viewModel.setAvatar(image) }
        }
    }
    // MARK: - Helpers

    private var stats: [StatItem] {
        [
            StatItem(value: viewModel.productsCount.formatted(), title: "Products"),
            StatItem(value: viewModel.ordersCount.formatted(), title: "Orders")
        ]
    }

    private func deleteAvatarAction(for user: User) -> (() -> Void)? {
        guard user.avatarUrl != nil else { return nil }
        return { Task { await viewModel.removeAvatar() } }
    }
}
