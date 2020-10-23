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

    @IBOutlet weak var currentWeatherView: UIView!
    @IBOutlet weak var cityNameLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var temperatureRangeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var cloudsLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!

    @IBOutlet weak var weatherIconImageVIew: UIImageView!

    private let kDailyForecastCell = "DailyForecastCell"

    private let disposeBag = DisposeBag()
    
    weak var listener: WeatherDetailsPresentableListener?

    private var dailyForecast: [DailyForecast] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        weatherIconImageVIew.layer.shadowColor = UIColor.black.cgColor
        weatherIconImageVIew.layer.shadowRadius = 3.0
        weatherIconImageVIew.layer.shadowOpacity = 0.75
        weatherIconImageVIew.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)

        currentWeatherView.layer.shadowColor = UIColor.black.cgColor
        currentWeatherView.layer.shadowRadius = 3.0
        currentWeatherView.layer.shadowOpacity = 0.75
        currentWeatherView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
    }

	// MARK: - Update

    func showForecast(_ forecast: BaseForecast, for city: City) {
        cityNameLabel.text = city.cityName

        dateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: forecast.timestamp))
        temperatureLabel.text = "\(forecast.temperature.current.fahrengeit) °F"

        temperatureRangeLabel.text = "\(forecast.temperature.minimum.fahrengeit) °F — \(forecast.temperature.maximum.fahrengeit) °F"

        cloudsLabel.text = "\(forecast.conditions.clouds) %"
        humidityLabel.text = "\(forecast.conditions.humidity) %"
        windSpeedLabel.text = "\(forecast.wind.speed) mps"
        pressureLabel.text = "\(Int(Double(forecast.conditions.pressure) * 0.0145038)) psi"

        loadIcon(withID: forecast.conditions.icon)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe { [unowned self] (image) in
                weatherIconImageVIew.image = image
            } onError: { (error) in
                print(error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }

    private func loadIcon(withID iconID: String) -> Single<UIImage?> {
        Single<UIImage?>.create { (s) -> Disposable in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let url = URL(string: "http://openweathermap.org/img/wn/\(iconID)@2x.png")!
                    let data = try Data(contentsOf: url)
                    let icon = UIImage(data: data)

                    s(.success(icon))
                } catch {
                    s(.error(error))
                }
            }

            return Disposables.create()
        }
    }

    func showDailiyForecast(_ forecast: [DailyForecast]) {
        dailyForecast = forecast
        tableView.reloadData()
    }

    // MARK: - Actions

    @IBAction func onSelectCityButtonTouch(_ sender: UIButton) {
        listener?.selectCities()
    }

    // MARK: - Private

    private let dateFormatter: DateFormatter = {
		let df = DateFormatter()
        df.dateFormat = ""

        return df
    }()
}

extension WeatherDetailsViewController: UITableViewDataSource, UITableViewDelegate {

    private static let weekdayFormatter: DateFormatter = {
		let df = DateFormatter()
        df.dateFormat = "EEEE HH:mm"

        return df
    }()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyForecast.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = dailyForecast[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: kDailyForecastCell) as! DailyForecastCell
        cell.humidityLabel.text = String(format: "%.2f%%", item.humidity)
        cell.maxTemperatureLabel.text = "\(Int(round(item.maxTemperature)).fahrengeit) °F"
        cell.minTemperatureLabel.text = "\(Int(round(item.minTemperature)).fahrengeit) ... "
        cell.weekdayLabel.text = WeatherDetailsViewController.weekdayFormatter.string(from: item.date)

        loadIcon(withID: item.icon)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [unowned tableView, unowned cell] image in
                guard let cellIndexPath = tableView.indexPath(for: cell), cellIndexPath == indexPath else { return }
                cell.weatherIconImageView.image = image
            })
            .disposed(by: disposeBag)

        return cell
    }
}
