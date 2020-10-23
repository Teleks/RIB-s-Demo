//
//  Double+Converter.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 22.10.2020.
//

import Foundation

extension Int {
    var celsius: Int { Int(round(Double(self) - 273.15)) }
    var fahrengeit: Int { Int(round((Double(self) - 273.15) * 9.0 / 5.0 + 32.0)) }
}
