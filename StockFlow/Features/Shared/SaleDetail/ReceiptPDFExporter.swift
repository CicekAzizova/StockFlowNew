//
//  ReceiptPDFExporter.swift
//  StockFlow
//
//  Created by Cicek on 27.11.26.
//

import SwiftUI

/// Qəbzi PDF fayla çevirir (müvəqqəti qovluqda). Paylaşma pəncərəsindən çap da etmək olur.
@MainActor
enum ReceiptPDFExporter {

    static func makePDF(
        sale: SaleResponse,
        storeName: String,
        locationName: String?,
        locale: Locale
    ) -> URL? {
        let content = ReceiptPDFView(sale: sale, storeName: storeName, locationName: locationName)
            .environment(\.locale, locale)

        let renderer = ImageRenderer(content: content)
        let name = sale.receiptNo.map { "\($0)" } ?? "\(sale.id)"
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Receipt-\(name).pdf")

        var isWritten = false
        renderer.render { size, draw in
            var box = CGRect(origin: .zero, size: size)
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
            pdf.beginPDFPage(nil)
            draw(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
            isWritten = true
        }
        return isWritten ? url : nil
    }
}
