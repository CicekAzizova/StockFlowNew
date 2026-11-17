//
//  ActiveLocationStore.swift
//  StockFlow
//
//  Created by Cicek on 17.11.26.
//

import Foundation

/// Sahibin hazırda işlədiyi məkanın ID-si. Yoxdursa server əsas məkanı götürür.
enum ActiveLocationStore {
    private static let key = "activeLocationId"

    static var id: Int? {
        get {
            let value = UserDefaults.standard.integer(forKey: key)
            return value > 0 ? value : nil
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    
    private static let nameKey = "activeLocationName"

    /// Seçilmiş (əsas olmayan) məkanın adı. Əsas məkan seçiliykən nil.
    static var name: String? {
        get { UserDefaults.standard.string(forKey: nameKey) }
        set { UserDefaults.standard.set(newValue, forKey: nameKey) }
    }
}
