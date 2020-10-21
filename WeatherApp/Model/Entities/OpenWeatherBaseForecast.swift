//
//  BaseWeather.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 20.10.2020.
//

import Foundation

struct OpenWeatherBaseForecast: Decodable {

    let id: Int
    let name: String
    let cod: Int
    let coord: Coordinate
    let weather: Weather
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: TimeInterval
    let sys: ServiceInfo

    struct Coordinate: Decodable {
        let lat: Double
        let lon: Double
    }

    struct Weather: Decodable {
        let id: Int
        let title: String
        let weatherDescription: String
        let icon: String

        enum CodingKeys: String, CodingKey {
            case id
            case title = "main"
            case weatherDescription = "description"
            case icon
        }
    }

    struct Main: Decodable {
        let temp: Double
        let pressure: Int
        let humidity: Int
        let tempMin: Double
        let tempMax: Double
    }

    struct Wind: Decodable {
        let speed: Double
        let deg: Int
    }

    struct Clouds: Decodable {
        let all: Int
    }

    struct ServiceInfo: Decodable {
        let type: Int
        let id: Int
        let message: Int
        let country: String
        let sunrise: TimeInterval
        let sunset: TimeInterval
    }
}
