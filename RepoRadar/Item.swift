//
//  Item.swift
//  RepoRadar
//
//  Created by Pavel Belenkow on 01.12.2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
