//
//  SaleRowView.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// Siyahıda bir satış: avatar, qəbz №, saat · satıcı · məhsul sayı, məbləğ, ödəniş nişanı.
struct SaleRowView: View {

    let sale: SaleResponse
    
    var showsLocation = false

    var body: some View {
        HStack(spacing: 12) {
            avatar

            VStack(alignment: .leading, spacing: 3) {
                Text(verbatim: receiptTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)

                subtitle
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                Text(verbatim: sale.totalPrice.formatted(.number.precision(.fractionLength(0...2))))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.textPrimary)

                paymentBadge
            }
        }
        .brandCard()
    }

    // MARK: - Hissələr

    @ViewBuilder
    private var avatar: some View {
        if let url = sale.sellerAvatarUrl, !url.isEmpty {
            RemoteImageView(imageUrl: url, width: 38, height: 38, cornerRadius: 19)
        } else {
            initialsAvatar
        }
    }

    private var initialsAvatar: some View {
        Text(verbatim: initials)
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .frame(width: 38, height: 38)
            .background(
                LinearGradient(
                    colors: [.brandDark, .brandGreen],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Circle()
            )
    }

    private var subtitle: some View {
        let time = sale.createdAt.formatted(date: .omitted, time: .shortened)
        let seller = sale.sellerName ?? "-"
        var prefix = "\(time) · \(seller)"
        if showsLocation, let location = sale.locationName {
            prefix += " · \(location)"
        }

        return HStack(spacing: 0) {
            Text(verbatim: "\(prefix) · ")
            Text("\(sale.itemsCount) items")
        }
    }

    private var paymentBadge: some View {
        VStack {
            Text(sale.paymentMethod.title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.brandGreen)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.brandGreen.opacity(0.12), in: Capsule())
            if sale.isReturned {
                Text("Returned")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.brandCoral)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.brandCoral.opacity(0.12), in: Capsule())
            }
        }
    }
    
    /// Qəbz nömrəsi yoxdursa (köhnə satışlar), satış id-si göstərilir.
    private var receiptTitle: String {
        if let receiptNo = sale.receiptNo {
            return "#\(receiptNo)"
        }
        return "#\(sale.id)"
    }

    private var initials: String {
        let words = (sale.sellerName ?? "").split(separator: " ")
        let letters = words.prefix(2).compactMap { $0.first }
        return letters.isEmpty ? "?" : String(letters).uppercased()
    }
}

/// Günün başlığı: Bu gün / Dünən / tarix.
struct SalesDayHeader: View {

    let day: Date

    var body: some View {
        title
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color.textSecondary)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 6)
    }

    @ViewBuilder
    private var title: some View {
        if Calendar.current.isDateInToday(day) {
            Text("Today")
        } else if Calendar.current.isDateInYesterday(day) {
            Text("Yesterday")
        } else {
            Text(day, format: .dateTime.day().month(.wide).year())
        }
    }
}
