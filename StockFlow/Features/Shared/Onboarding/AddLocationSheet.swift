//
//  AddLocationSheet.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

import SwiftUI

struct AddLocationSheet: View {

    enum Field: Hashable {
        case name, address
    }

    let locationRepository: LocationRepository
    var onAdded: () async -> Void = {}
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    @State private var kind: LocationKind = .store
    @State private var name = ""
    @State private var address = ""
    @State private var makeMain = false
    @State private var isSaving = false
    @State private var nameError: String?
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("New location")
                    .font(.inter(.bold, size: 20))
                    .foregroundStyle(.textPrimary)

                Picker("Type", selection: $kind) {
                    ForEach(LocationKind.allCases, id: \.self) { kind in
                        Text(kind.title).tag(kind)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: kind) {
                    if kind == .warehouse { makeMain = false }
                }

                AppTextFieldView(
                    title: kind == .store ? "Store name" : "Warehouse name",
                    placeholder: kind == .store ? "Branch name" : "Warehouse name",
                    icon: nil,
                    focusedField: Field.name,
                    errorMessage: nameError,
                    submitLabel: .next,
                    onSubmit: { focusedField = .address },
                    text: $name,
                    focusedFieldBinding: $focusedField
                )

                AppTextFieldView(
                    title: "Address",
                    placeholder: "Street, city",
                    icon: nil,
                    focusedField: Field.address,
                    submitLabel: .done,
                    onSubmit: { focusedField = nil },
                    text: $address,
                    focusedFieldBinding: $focusedField
                )

                if kind == .store {
                    Toggle(isOn: $makeMain) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Make main location")
                                .font(.inter(.medium, size: 15))
                                .foregroundStyle(.textPrimary)
                            Text("Sales go here by default")
                                .font(.inter(.regular, size: 12))
                                .foregroundStyle(.textSecondary)
                        }
                    }
                    .tint(Color.brandTeal)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                AppButtonView(
                    title: kind == .store
                        ? LocalizedStringKey("Add store")
                        : LocalizedStringKey("Add warehouse"),
                    isLoading: isSaving,
                    usesBrandGradient: true
                ) {
                    Task { await add() }
                }
                .padding(.top, 8)
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .presentationDetents([.medium, .large])
    }

    private func add() async {
        nameError = nil
        errorMessage = nil
        focusedField = nil

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            nameError = String(localized: "Name is required.")
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            _ = try await locationRepository.createLocation(
                CreateLocationRequest(
                    name: trimmedName,
                    kind: kind,
                    address: address.trimmingCharacters(in: .whitespacesAndNewlines),
                    isMain: kind == .store && makeMain
                )
            )
            await onAdded()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
