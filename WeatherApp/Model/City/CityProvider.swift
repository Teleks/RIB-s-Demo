//
//  CityProvider.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 19.10.2020.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

protocol CityProvider: AnyObject {
    var cities: Observable<[City]> { get }
}

protocol SearchableCityProvider: CityProvider {
    func findCities(withText text: String)
}

protocol UpdatableCityProvider: CityProvider {
    func addCity(_ cityName: String)
}

protocol CityRepository {
    func allCities() -> [City]
    func cityWithName(_ cityName: String) -> City?
    func citiesMatchingText(_ text: String) -> [City]

    func addCity(_ city: City) -> Single<City>
}

final class DefaultCityProvider: SearchableCityProvider, UpdatableCityProvider {

    var cities: Observable<[City]> { _cities.asObservable() }

    private let repository: CityRepository

    // MARK: - Lifecycle

    init(repository: CityRepository) {
        self.repository = repository
        prepareList()
		prepareSearchTextObservable()
    }

    // MARK: - Setup

    private func prepareList() {
        let cities = repository.allCities()

        if cities.isEmpty {
            addCity("Moscow")
            addCity("Minsk")
        }
    }

    // MARK: - Actions

    func findCities(withText text: String) {
        _searchText.accept(text)
    }

    func addCity(_ cityName: String) {
        let city = City(id: UUID().uuidString, cityName: cityName)

        repository.addCity(city)
            .map({ [unowned self] _ in
                citiesMatchingText(_searchText.value)
            })
            .subscribe(onSuccess: { [unowned self] in
                _cities.accept($0)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Private

    private let kCitySearchDelay: DispatchTimeInterval = .milliseconds(500)

    private let _cities = BehaviorRelay<[City]>(value: [])
    private let _searchText = BehaviorRelay<String>(value: "")

    private let disposeBag = DisposeBag()

    // MARK: Private - Setup

    private func prepareSearchTextObservable() {
        searchCitiesObserver()
            .subscribe(onNext: { [unowned self] in
                _cities.accept($0)
            })
            .disposed(by: disposeBag)
    }

    private func searchCitiesObserver(recover: Bool = false) -> Observable<[City]> {
        let observable = recover ? _searchText.asObservable().skip(1) : _searchText.asObservable()

        return observable
            .distinctUntilChanged()
            .debounce(kCitySearchDelay, scheduler: MainScheduler.asyncInstance)
            .map({ [unowned self] searchText -> [City] in
                print("Search by: \(searchText)")
                return citiesMatchingText(searchText)
            })
            .catchError({ [unowned self] (error) -> Observable<[City]> in
                print("Error: \(error)")
                return searchCitiesObserver(recover: true)
            })
    }

    private func citiesMatchingText(_ text: String) -> [City] {
        repository.citiesMatchingText(text)
            .sorted(by: { (str1, str2) -> Bool in
                return str1.cityName.compare(str2.cityName) == .orderedAscending
            })
    }
}
