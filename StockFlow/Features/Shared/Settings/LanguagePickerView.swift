//
//  LanguagePickerView.swift
//  StockFlow
//
//  Created by Cicek on 28.10.26.
//
import SwiftUI

struct LanguagePickerView: View {
    @Environment(LanguageManager.self) private var languageManager
    
    var body: some View {
         @Bindable var languageManager = languageManager
        
        Picker("Language" , selection: $languageManager.language) {
            ForEach(AppLanguage.allCases) { language in
                Text(language.displayName).tag(language)
            }
        }
    }
}


