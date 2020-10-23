//
//  DailyForecast.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 23.10.2020.
//

import Foundation

struct DailyForecast {
    let cityID: String
    let date: Date
    let icon: String
    let humidity: Double
    let minTemperature: Double
    let maxTemperature: Double
}

extension DailyForecast {

    init(_ obj: OpenWeatherDailyForecast.Item, cityID: String) {
        self.cityID = cityID
        self.date = Date(timeIntervalSince1970: obj.dt)
        self.icon = obj.icon
        self.humidity = obj.humidity
        self.minTemperature = obj.tempMin
        self.maxTemperature = obj.tempMax
    }
}
