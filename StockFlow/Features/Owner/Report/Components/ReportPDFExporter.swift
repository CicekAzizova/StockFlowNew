//
//  ReportPDFExporter.swift
//  StockFlow
//
//  Created by Cicek on 23.11.26.
//

import SwiftUI

/// ReportPDFView-ni PDF fayla çevirir (müvəqqəti qovluqda).
@MainActor
enum ReportPDFExporter {

    static func makePDF(
        report: SalesReport,
        period: ReportPeriod,
        locationName: String?,
        locale: Locale
    ) -> URL? {
        let content = ReportPDFView(report: report, period: period, locationName: locationName)
            .environment(\.locale, locale)

        let renderer = ImageRenderer(content: content)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Report-\(report.from)_\(report.to).pdf")

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
