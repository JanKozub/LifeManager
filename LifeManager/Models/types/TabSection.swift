//
//  TabSelection.swift
//  LifeManager
//
//  Created by Jan Kozub on 01/07/2024.
//

import Foundation

enum TabSection: Identifiable, CaseIterable, Hashable {
    case spendings
    case meals
    
    var id: Int {
        switch self {
        case .spendings: 1
        case .meals: 2
        }
    }
    
    var displayName: String {
        switch self {
        case .spendings: "Spendings"
        case .meals: "Meals"
        }
    }
    
    var iconName: String {
        switch self {
        case .spendings: "folder"
        case .meals: "folder"
        }
    }
    
    static var allCases: [TabSection] {
        [.spendings, .meals]
    }
    
    static func == (lhs: TabSection, rhs: TabSection) -> Bool {
        lhs.id == rhs.id;
    }
}
