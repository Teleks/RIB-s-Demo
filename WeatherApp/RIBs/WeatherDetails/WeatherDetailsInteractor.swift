//
//  WeatherDetailsInteractor.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 19.10.2020.
//

import RIBs
import RxSwift

protocol WeatherDetailsRouting: ViewableRouting {
    func routeToCitiesSelection()
    func routeToWeatherDetails()
}

protocol WeatherDetailsPresentable: Presentable {
    var listener: WeatherDetailsPresentableListener? { get set }

    func showWeather(for city: String)
}

protocol WeatherDetailsListener: class {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class WeatherDetailsInteractor: PresentableInteractor<WeatherDetailsPresentable>, WeatherDetailsInteractable, WeatherDetailsPresentableListener {

    weak var router: WeatherDetailsRouting?
    weak var listener: WeatherDetailsListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: WeatherDetailsPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }

    func selectCities() {
        router?.routeToCitiesSelection()
    }

    // MARK: - Events

    func didSelectCities(_ city: String) {
        presenter.showWeather(for: city)
        router?.routeToWeatherDetails()
    }

    func didCancelCitySelection() {
        router?.routeToWeatherDetails()
    }
}
