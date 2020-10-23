//
//  CitiesSelectionInteractor.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 19.10.2020.
//

import RIBs
import RxSwift
import RxCocoa

protocol CitiesSelectionRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol CitiesSelectionPresentable: Presentable {
    var listener: CitiesSelectionPresentableListener? { get set }

    func showCities(_ cities: [CityRecord])
    func showTemperature(at cityIndex: Int, temperature: Int?)
}

protocol CitiesSelectionListener: class {
    func didSelectCities(_ city: City)
    func didCancelCitySelection()
}

final class CitiesSelectionInteractor: PresentableInteractor<CitiesSelectionPresentable>, CitiesSelectionInteractable, CitiesSelectionPresentableListener {

	typealias CityProvider = UpdatableCityProvider & SearchableCityProvider

    weak var router: CitiesSelectionRouting?
    weak var listener: CitiesSelectionListener?

    private let cityProvider: CityProvider
    private let weatherProvider: WeatherProvider

    private let disposeBag = DisposeBag()

	// MARK: - Lifecycle

    init(presenter: CitiesSelectionPresentable, cityProvider: CityProvider, weatherProvider: WeatherProvider) {
        self.cityProvider = cityProvider
        self.weatherProvider = weatherProvider

        super.init(presenter: presenter)
        presenter.listener = self

		subscribeToCitiesUpdate()
		subscribeToTemperatureUpdate()
    }

    // MARK: - Setup

    private func subscribeToCitiesUpdate() {
        cityProvider.cities
            .asDriver(onErrorJustReturn: [])
            .map({ [unowned self] in
                $0.map({
                    let temperature = weatherProvider.temperature(in: $0)
                    return CityRecord(cityName: $0.cityName, temperature: temperature)
                })
            })
            .drive(onNext: { [unowned presenter] in
                presenter.showCities($0)
            })
            .disposed(by: disposeBag)
    }

    private func subscribeToTemperatureUpdate() {
        weatherProvider.baseForecast
            .withLatestFrom(cityProvider.cities.asDriver(onErrorJustReturn: []), resultSelector: { (forecast, cities) in
                guard let forecast = forecast, let cityIndex = cities.firstIndex(where: { $0.id == forecast.cityID }) else {
                    return (cityIndex: nil, temperature: nil)
                }
                return (cityIndex: cityIndex, temperature: forecast.temperature.current)
            })
            .drive(onNext: { [unowned self] (cityIndex: Int?, temperature: Int?) in
                guard let cityIndex = cityIndex else { return }
                self.presenter.showTemperature(at: cityIndex, temperature: temperature)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Actions

    override func didBecomeActive() {
        super.didBecomeActive()
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }

    func selectCity(atIndex cityIndex: Int) {
        city(at: cityIndex)
            .bind(onNext: { [unowned self] in
                listener?.didSelectCities($0)
            })
            .disposed(by: disposeBag)
    }

    func cancel() {
        listener?.didCancelCitySelection()
    }

    func searchCity(withText text: String) {
        cityProvider.findCities(withText: text)
    }

    func addCity(city: String) {
        cityProvider.addCity(city)
    }


    // MARK: - Private

    private func city(at cityIndex: Int) -> Observable<City> {
        Observable<Int>.just(cityIndex)
            .withLatestFrom(cityProvider.cities, resultSelector: { $1[$0] })
    }
}
