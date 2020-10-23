//
//  RealmCity.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 20.10.2020.
//

import Foundation
import RealmSwift

final class RealmCity: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var cityName: String = ""

    override class func primaryKey() -> String? {
        return "cityName"
    }
}

extension RealmCity {

    convenience init(city: City) {
        self.init()

        self.id = city.id
        self.cityName = city.cityName
    }

    func toCity() -> City {
        City(id: id, cityName: cityName)
    }
}
