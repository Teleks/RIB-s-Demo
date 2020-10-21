//
//  CommonError.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 20.10.2020.
//

import Foundation

enum CommonError: LocalizedError {
    case noData(context: String?)

    var errorDescription: String? {
        switch self {
        case .noData(let context):
            return (context != nil) ? "No data. \(context!)" : "No data."
        }
    }
}
