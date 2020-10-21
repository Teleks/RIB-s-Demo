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

    func temperature(in city: String) -> Int?
}

protocol WeatherRepository {
    func temperature(in city: String) -> Int?
    func saveForecast(for city: String, with forecast: BaseForecast) -> Single<BaseForecast>
}

final class DefaultWeatherProvider: WeatherProvider {

    var baseForecast: Driver<BaseForecast?> { _baseForecast.asDriver() }

	// MARK: - Lifecycle

    init(repository: WeatherRepository) {
        self.repository = repository
    }

    // MARK: - Actions

    func temperature(in city: String) -> Int? {
        return repository.temperature(in: city)
    }

    // MARK: - Private

    private let _baseForecast = BehaviorRelay<BaseForecast?>(value: nil)
	private let disposeBag = DisposeBag()
    private let urlSession = URLSession.shared

    private let repository: WeatherRepository

    private let jsonResponseDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return decoder
    }()

    private func queryString(with params: [String: String]) -> String {
		params
            .map({ "\($0)=\($1)" })
            .joined(separator: "&")
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }

    private func loadBaseWeather(for city: String) {
        let queryParams: [String: String] = [
            "q": city,
            "appId": AppConfig.weatherApiKey
        ]

        let url = AppConfig.weatherApiUrl.appendingPathComponent("weather")
            .appendingPathComponent("?q=\(queryString(with: queryParams))")

        let request = URLRequest(url: url)

        urlSession.rx.data(request: request)
            .map({ [unowned self] in
                return try jsonResponseDecoder.decode(OpenWeatherBaseForecast.self, from: $0)
            })
            .map(BaseForecast.init)
            .flatMapLatest({ [unowned self] in
                repository.saveForecast(for: city, with: $0)
            })
            .asSingle()
            .subscribe({ [unowned self] in
                switch $0 {
                case .success(let forecast):
                    _baseForecast.accept(forecast)
                case .error(let error):
                    print("Failed to update forecast: \(error)")
                }
            })
            .disposed(by: disposeBag)
    }
}
