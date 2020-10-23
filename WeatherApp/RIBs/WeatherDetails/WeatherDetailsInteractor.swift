//
//  WeatherDetailsInteractor.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 19.10.2020.
//

import RIBs
import RxSwift

protocol WeatherDetailsScreenSettings: AnyObject {
    var city: City? { get set }
}

protocol WeatherDetailsRouting: ViewableRouting {
    func routeToCitiesSelection(cancellable: Bool)
    func routeToWeatherDetails()
}

protocol WeatherDetailsPresentable: Presentable {
    var listener: WeatherDetailsPresentableListener? { get set }

    func showForecast(_ forecast: BaseForecast, for city: City)
    func showDailiyForecast(_ forecast: [DailyForecast])
}

protocol WeatherDetailsListener: class {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class WeatherDetailsInteractor: PresentableInteractor<WeatherDetailsPresentable>, WeatherDetailsInteractable, WeatherDetailsPresentableListener {

    weak var router: WeatherDetailsRouting?
    weak var listener: WeatherDetailsListener?
    weak var settings: WeatherDetailsScreenSettings?

    // MARK: - Lifecycle

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(presenter: WeatherDetailsPresentable, weatherProvider: WeatherProvider, settings: WeatherDetailsScreenSettings) {
        self.weatherProvider = weatherProvider
        self.settings = settings

        super.init(presenter: presenter)
        presenter.listener = self

        observeForecast()
    }

	// MARK: - Setup

    private func observeForecast() {
        weatherProvider.baseForecast
            .filter({ [unowned self] in ($0 != nil && $0!.cityID == settings?.city?.id) })
            .drive(onNext: { [unowned self] in
                guard let forecast = $0, let city = settings?.city else { return }
                presenter.showForecast(forecast, for: city)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Actions

    override func didBecomeActive() {
        super.didBecomeActive()

        if settings?.city == nil {
            router?.routeToCitiesSelection(cancellable: false)
        }
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }

    func selectCities() {
        router?.routeToCitiesSelection(cancellable: true)
    }

    // MARK: - Events

    func didSelectCities(_ city: City) {
        settings?.city = city

        weatherProvider.loadBaseWeather(for: city)
        loadDailyForecast()
        router?.routeToWeatherDetails()
    }

    func didCancelCitySelection() {
        router?.routeToWeatherDetails()
    }

    // MARK: - Private

    private let disposeBag = DisposeBag()
    private let weatherProvider: WeatherProvider

    private func loadDailyForecast() {
        guard let city = settings?.city else { return }
        weatherProvider.dailyForecast(in: city)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [unowned self] in
                presenter.showDailiyForecast($0)
            })
            .disposed(by: disposeBag)
    }
}
