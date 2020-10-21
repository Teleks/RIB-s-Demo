//
//  RealmCity.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 20.10.2020.
//

import Foundation
import RealmSwift

final class RealmCity: Object {
    @objc dynamic var title: String = ""

    override class func primaryKey() -> String? {
        return "title"
    }
}

extension RealmCity {

    convenience init(title: String) {
        self.init()
        self.title = title
    }
}
