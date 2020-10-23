//
//  OpenWeatherDailyForecast.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 23.10.2020.
//

import Foundation

struct OpenWeatherDailyForecast: Decodable {

    let city: City
    let list: [Item]

    struct Item: Decodable {
        let temp: Double
        let tempMin: Double
        let tempMax: Double

        let pressure: Double
        let humidity: Double
        let clouds: Int

        let windSpeed: Double
        let windDirection: Double

        let icon: String

        let dt: TimeInterval

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            dt = try container.decode(TimeInterval.self, forKey: .dt)

            let main = try container.nestedContainer(keyedBy: MainCodingKeys.self, forKey: .main)
            let clouds = try container.nestedContainer(keyedBy: CloudsCodingKeys.self, forKey: .clouds)
            let wind = try container.nestedContainer(keyedBy: WindCodingKeys.self, forKey: .wind)

            self.icon = (try container.decode([Weather].self, forKey: .weather).first?.icon)!

            self.temp = try main.decode(Double.self, forKey: .temp)
            self.tempMin = try main.decode(Double.self, forKey: .tempMin)
            self.tempMax = try main.decode(Double.self, forKey: .tempMax)

            self.pressure = try main.decode(Double.self, forKey: .pressure)
            self.humidity = try main.decode(Double.self, forKey: .humidity)
            self.clouds = try clouds.decode(Int.self, forKey: .all)

            self.windSpeed = try wind.decode(Double.self, forKey: .speed)
            self.windDirection = try wind.decode(Double.self, forKey: .deg)
        }


        // Subtypes

        enum CodingKeys: String, CodingKey {
            case dt
			case main
            case weather
            case clouds
            case wind
        }

        enum MainCodingKeys: String, CodingKey {
            case temp
            case tempMin
            case tempMax
            case pressure
            case humidity
        }

        enum WeatherCodingKeys: String, CodingKey {
            case icon
        }

        enum CloudsCodingKeys: String, CodingKey {
            case all
        }

        enum WindCodingKeys: String, CodingKey {
    		case speed
            case deg
        }
    }

    struct City: Decodable {
        let name: String
        let coord: Coordinate
    }

    struct Coordinate: Decodable {
        let lat: Double
        let lon: Double
    }

    struct Weather: Decodable {
        let icon: String
    }
}
