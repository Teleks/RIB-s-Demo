//
//  CityRepository.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 20.10.2020.
//

import Foundation
import RealmSwift
import RxSwift

final class DefaultCityRepository: CityRepository {

	// MARK: - Actions

    func allCities() -> [City] {
        return Realm.shared.objects(RealmCity.self).map({ $0.toCity() })
    }

    func cityWithName(_ cityName: String) -> City? {
        return Realm.shared.object(ofType: RealmCity.self, forPrimaryKey: cityName)?.toCity()
    }

    func citiesMatchingText(_ text: String) -> [City] {
        guard !text.isEmpty else { return allCities() }
        return allCities().filter({ $0.cityName.lowercased().contains(text.lowercased()) })
    }

    func addCity(_ city: City) -> Single<City> {
        Single<City>.create { (s) -> Disposable in
            do {
                let realm = try Realm()

                guard realm.object(ofType: RealmCity.self, forPrimaryKey: city.cityName) == nil else {
                    s(.success(city))
                    return Disposables.create()
                }

                try realm.write {
                    let obj = RealmCity(city: city)
                    realm.add(obj)

                    s(.success(obj.toCity()))
                }
            } catch {
                s(.error(error))
            }

            return Disposables.create()
        }
    }
}
