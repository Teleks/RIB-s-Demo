//
//  BaseWeather.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 20.10.2020.
//

import Foundation

struct BaseForecast {

    let cityID: String
    let cityName: String
    let location: Coordinate

    let temperature: Temperature
    let conditions: Conditions
    let wind: Wind
    let sun: Sun

    let timestamp: TimeInterval

    struct Coordinate {
        let latitude: Double
        let longitude: Double
    }

    struct Temperature {
        let current: Int
        let minimum: Int
        let maximum: Int
    }

    struct Wind {
        let speed: Double
        let direction: Int
    }

    struct Sun {
        let sunrise: TimeInterval
        let sunset: TimeInterval
    }

    struct Conditions {
        let visibility: Int
        let pressure: Int
        let humidity: Int

        let clouds: Int

        let icon: String
        let textDescription: String
    }
}

extension BaseForecast {

    init(_ obj: OpenWeatherBaseForecast, cityID: String) {
        self.cityID = cityID
        self.cityName = obj.name
        self.location = Coordinate(latitude: obj.coord.lat, longitude: obj.coord.lon)

        let main = obj.main
        let weather = obj.weather.first!

        self.temperature = Temperature(current: Int(main.temp), minimum: Int(main.tempMin), maximum: Int(main.tempMax))
        self.conditions = Conditions(visibility: obj.visibility,
                                     pressure: main.pressure,
                                     humidity: main.humidity,
                                     clouds: obj.clouds.all,
                                     icon: weather.icon,
                                     textDescription: weather.weatherDescription)

        self.wind = Wind(speed: obj.wind.speed, direction: obj.wind.deg)
        self.sun = Sun(sunrise: obj.sys.sunrise, sunset: obj.sys.sunset)

        self.timestamp = obj.dt
    }
}
