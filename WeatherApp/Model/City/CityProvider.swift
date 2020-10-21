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
    var cities: Observable<[String]> { get }
}

protocol SearchableCityProvider: CityProvider {
    func findCities(withText text: String)
}

protocol UpdatableCityProvider: CityProvider {
    func addCity(_ city: String)
}

protocol CityRepository {
    func allCities() -> [String]
    func citiesMatchingText(_ text: String) -> [String]

    func addCity(_ city: String) -> Single<String>
}

final class DefaultCityProvider: SearchableCityProvider, UpdatableCityProvider {

    var cities: Observable<[String]> { _cities.asObservable() }

    private let repository: CityRepository

    // MARK: - Lifecycle

    init(repository: CityRepository) {
        self.repository = repository
		prepareSearchTextObservable()
    }

    // MARK: - Actions

    func findCities(withText text: String) {
        _searchText.accept(text)
    }

    func addCity(_ city: String) {
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

    private let _cities = BehaviorRelay<[String]>(value: [])
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

    private func searchCitiesObserver(recover: Bool = false) -> Observable<[String]> {
        let observable = recover ? _searchText.asObservable().skip(1) : _searchText.asObservable()

        return observable
            .distinctUntilChanged()
            .debounce(kCitySearchDelay, scheduler: MainScheduler.asyncInstance)
            .map({ [unowned self] searchText -> [String] in
                print("Search by: \(searchText)")
                return citiesMatchingText(searchText)
            })
            .catchError({ [unowned self] (error) -> Observable<[String]> in
                print("Error: \(error)")
                return searchCitiesObserver(recover: true)
            })
    }

    private func citiesMatchingText(_ text: String) -> [String] {
        repository.citiesMatchingText(text)
        .sorted(by: { (str1, str2) -> Bool in
            return str1.compare(str2) == .orderedAscending
        })
    }
}

struct City {
    let cityName: String
}
