//
//  WeatherProvider.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 20.10.2020.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

protocol WeatherProvider {
    var baseForecast: Driver<BaseForecast?> { get }

    func loadBaseWeather(for city: City)
    func temperature(in city: City) -> Int?
    func dailyForecast(in city: City) -> Single<[DailyForecast]>
}

protocol WeatherRepository {
    func temperature(in city: String) -> Int?
    func saveForecast(for city: String, with forecast: BaseForecast) -> Single<BaseForecast>
}

final class DefaultWeatherProvider: WeatherProvider {

    var baseForecast: Driver<BaseForecast?> { _baseForecast.asDriver() }

    // MARK: - Lifecycle

    init(weatherRepository: WeatherRepository, cityRepository: CityRepository) {
        self.weatherRepository = weatherRepository
        self.cityRepository = cityRepository
    }

    // MARK: - Actions

    func temperature(in city: City) -> Int? {
        return weatherRepository.temperature(in: city.id)
    }

    func dailyForecast(in city: City) -> Single<[DailyForecast]> {
        let queryParams: [String: String] = [
            "q": city.cityName,
            "appId": AppConfig.weatherApiKey
        ]

        var urlComps = URLComponents(url: AppConfig.weatherApiUrl, resolvingAgainstBaseURL: false)!
        urlComps.path = "\(urlComps.path)/forecast"
        urlComps.queryItems = queryParams.map(URLQueryItem.init)

        let request = URLRequest(url: urlComps.url!)

        return urlSession.rx.data(request: request)
            .map({ [unowned self] in
                return try jsonResponseDecoder.decode(OpenWeatherDailyForecast.self, from: $0)
            })
            .map({ $0.list.map({ DailyForecast($0, cityID: city.id) }) })
            .observeOn(MainScheduler.asyncInstance)
            .asSingle()
    }

    // MARK: - Private

    private let _baseForecast = BehaviorRelay<BaseForecast?>(value: nil)
    private let disposeBag = DisposeBag()
    private let urlSession = URLSession.shared

    private let cityRepository: CityRepository
    private let weatherRepository: WeatherRepository

    private let jsonResponseDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return decoder
    }()

    func loadBaseWeather(for city: City) {
        let queryParams: [String: String] = [
            "q": city.cityName,
            "appId": AppConfig.weatherApiKey
        ]

        var urlComps = URLComponents(url: AppConfig.weatherApiUrl, resolvingAgainstBaseURL: false)!
        urlComps.path = "\(urlComps.path)/weather"
        urlComps.queryItems = queryParams.map(URLQueryItem.init)
        
        let request = URLRequest(url: urlComps.url!)

        urlSession.rx.data(request: request)
            .map({ [unowned self] in
                return try jsonResponseDecoder.decode(OpenWeatherBaseForecast.self, from: $0)
            })
            .map({ BaseForecast($0, cityID: city.id) })
            .observeOn(MainScheduler.asyncInstance)
            .asSingle()
            .flatMap({ [unowned self] forecast -> Single<BaseForecast> in
                return weatherRepository.saveForecast(for: city.id, with: forecast)
            })
            .subscribe({ [unowned self] (event) in
                switch event {
                case .success(let forecast):
                    _baseForecast.accept(forecast)
                case .error(let error):
                    print("Failed to update forecast: \(error)")
                }
            })
            .disposed(by: disposeBag)
    }
}
