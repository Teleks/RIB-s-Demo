//
//  RealmBaseForecast.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 21.10.2020.
//

import Foundation
import RealmSwift

final class RealmBaseForecast: Object {
    @objc dynamic var cityID: String = ""
    @objc dynamic var cityName: String = ""
    @objc dynamic var base: String = ""
    @objc dynamic var visibility: Int = 0
    @objc dynamic var timestamp: TimeInterval = 0.0

    @objc dynamic var lat: Double = Double(kCFNotFound)
    @objc dynamic var lon: Double = Double(kCFNotFound)

    @objc dynamic var weatherDescription: String = ""
    @objc dynamic var weatherIcon: String = ""

    @objc dynamic var temperature: Int = 0
    @objc dynamic var temperatureMin: Int = 0
    @objc dynamic var temperatureMax: Int = 0

    @objc dynamic var pressure: Int = 0
    @objc dynamic var humidity: Int = 0

    @objc dynamic var windSpeed: Double = 0.0
    @objc dynamic var windDirection: Int = 0

    @objc dynamic var clouds: Int = 0

    @objc dynamic var sunrise: TimeInterval = 0.0
    @objc dynamic var sunset: TimeInterval = 0.0

    override class func primaryKey() -> String? {
        return "cityID"
    }
}

extension RealmBaseForecast {

    convenience init(_ obj: BaseForecast) {
        self.init()
        update(with: obj)
    }

    func update(with obj: BaseForecast) {
        self.cityName = obj.cityName

        self.visibility = obj.conditions.visibility
        self.timestamp = obj.timestamp

        self.lat = obj.location.latitude
        self.lon = obj.location.longitude

        self.weatherDescription = obj.conditions.textDescription
        self.weatherIcon = obj.conditions.icon

        self.temperature = obj.temperature.current
        self.temperatureMin = obj.temperature.minimum
        self.temperatureMax = obj.temperature.maximum

        self.pressure = obj.conditions.pressure
        self.humidity = obj.conditions.humidity

        self.windSpeed = obj.wind.speed
        self.windDirection = obj.wind.direction

        self.clouds = obj.conditions.clouds
        self.sunrise = obj.sun.sunrise
        self.sunset = obj.sun.sunset
    }
}

extension RealmBaseForecast {

    func toBaseForecast() -> BaseForecast {
        let conditions = BaseForecast.Conditions(visibility: visibility,
                                                 pressure: pressure,
                                                 humidity: humidity,
                                                 clouds: clouds,
                                                 icon: weatherIcon,
                                                 textDescription: weatherDescription)

        return BaseForecast(cityID: cityID,
                            cityName: cityName,
                            location: BaseForecast.Coordinate(latitude: lat, longitude: lon),
                            temperature: BaseForecast.Temperature(current: temperature, minimum: temperatureMin, maximum: temperatureMax),
                            conditions: conditions,
                            wind: BaseForecast.Wind(speed: windSpeed, direction: windDirection),
                            sun: BaseForecast.Sun(sunrise: sunrise, sunset: sunset),
                            timestamp: timestamp)
    }
}

