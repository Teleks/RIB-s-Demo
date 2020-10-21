//
//  Realm+Shared.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 21.10.2020.
//

import Foundation
import RealmSwift

extension Realm {
    static let shared = try! Realm()
}

