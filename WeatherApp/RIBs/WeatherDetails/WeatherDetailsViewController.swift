//
//  WeatherDetailsViewController.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 19.10.2020.
//

import RIBs
import RxSwift
import UIKit

protocol WeatherDetailsPresentableListener: class {

    func selectCities()
}

final class WeatherDetailsViewController: UIViewController, WeatherDetailsPresentable, WeatherDetailsViewControllable {

    @IBOutlet weak var cityNameLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var temperatureRangeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    weak var listener: WeatherDetailsPresentableListener?

	// MARK: - Update

    func showWeather(for city: String) {
        cityNameLabel.text = city
    }

    // MARK: - Actions

    @IBAction func onSelectCityButtonTouch(_ sender: UIButton) {
        listener?.selectCities()
    }
}
