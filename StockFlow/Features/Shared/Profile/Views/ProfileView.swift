//
//  ProfileView.swift
//  StockFlow
//
//  Created by Cicek on 25.09.26.
//

import SwiftUI

struct ProfileView: View {
    @State var viewModel: ProfileViewModel
    let appStateManager: AppStateManager
    @Environment(AppLockManager.self) private var appLockManager
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                logoutButton
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.getUser()
        }
    }
    
    // MARK: - Profile Content
    
    @ViewBuilder
    private func profileView(user: User) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                profileHeader(user: user)
                
                profileInformation(user: user)
                
                languageSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - Header
    
    private func profileHeader(user: User) -> some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.primaryBlue.opacity(0.10))
                    .frame(width: 100, height: 100)
                
                Circle()
                    .stroke(Color.primaryBlue.opacity(0.18), lineWidth: 1)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.primaryBlue)
            }
            
            VStack(spacing: 6) {
                Text(user.name)
                    .font(.title2.bold())
                    .foregroundStyle(Color.primaryBlue)
                    .multilineTextAlignment(.center)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundStyle(Color.primaryBlue)
                    .multilineTextAlignment(.center)
            }
            
            Text(user.role.displayName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.primaryBlue)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Color.primaryBlue.opacity(0.10))
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.border)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.border, lineWidth: 1)
        }
    }
    
    // MARK: - Information
    
    private func profileInformation(user: User) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Information")
                .font(.headline)
                .foregroundStyle(Color.secondary)
            
            VStack(spacing: 0) {
                profileRow(
                    title: "Full Name",
                    value: user.name,
                    icon: "person.fill"
                )
                
                Divider()
                    .padding(.leading, 56)
                
                profileRow(
                    title: "Email Address",
                    value: user.email,
                    icon: "envelope.fill"
                )
                
                Divider()
                    .padding(.leading, 56)
                
                profileRow(
                    title: "Store",
                    value: user.storeName ?? String(localized: "Not specified"),
                    icon: "storefront.fill"
                )
            }
            .padding(.horizontal, 16)
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.border, lineWidth: 1)
            }
        }
    }
    
    private func profileRow(
        title: LocalizedStringKey,
        value: String,
        icon: String
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color.blue)
                .frame(width: 40, height: 40)
                .background(Color.primaryBlue.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                
                Text(value)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.secondary)
                    .textSelection(.enabled)
            }
            
            Spacer(minLength: 8)
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Logout
    
    private var logoutButton: some View {
        AppButtonView(
            title: "Log Out",
            background: .red
        ) {
            appStateManager.logout()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(Color.background)
    }
    
    //MARK: - Language
    
    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.inter(.regular, size: 14))
                .foregroundStyle(.textSecondary)
            VStack {
                HStack(spacing: 14) {
                    settingsIcon("globe")
                    
                    LanguagePickerView()
                        .tint(.brandPrimary)
                    
                }
                    if appLockManager.canUseBiometrics {
                        Divider()
                            .padding(.leading, 54)
                        faceIDRow
                    }
                
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.border, lineWidth: 1)
            }
        }
    }
    
    private var faceIDRow: some View {
        HStack(spacing: 14) {
            settingsIcon("faceid")
            Toggle("Face ID", isOn: faceIDBinding)
                .tint(.brandPrimary)
        }
        //.padding()
    }
    
    private var faceIDBinding: Binding<Bool> {
        Binding {
            appLockManager.isBiometricsEnabled
        } set: { isOn in
            if isOn {
                Task { await appLockManager.enableBiometrics()}
            } else {
                appLockManager.setBiometrics(false)
            }
        }

    }
    private func settingsIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(Color.blue)
            .frame(width: 40, height: 40)
            .background(Color.primaryBlue.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    
    // MARK: - State
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading profile...")
                .tint(Color.primaryBlue)
            
        case .loaded(let user):
            profileView(user: user)
            
        case .error(let message):
            ContentUnavailableView(
                "Unable to Load Profile",
                systemImage: "exclamationmark.triangle",
                description: Text(message)
            )
        }
    }
}

