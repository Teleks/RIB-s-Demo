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

    func allCities() -> [String] {
        return Realm.shared.objects(RealmCity.self).map(\.title)
    }

    func citiesMatchingText(_ text: String) -> [String] {
        guard !text.isEmpty else { return allCities() }
        return allCities().filter({ $0.contains(text) })
    }

    func addCity(_ city: String) -> Single<String> {
        Single<String>.create { (s) -> Disposable in
            do {
                let realm = try Realm()

                guard realm.object(ofType: RealmCity.self, forPrimaryKey: city) == nil else {
                    s(.success(city))
                    return Disposables.create()
                }

                try realm.write {
                    let obj = RealmCity(title: city)
                    realm.add(obj)

                    s(.success(obj.title))
                }
            } catch {
                s(.error(error))
            }

            return Disposables.create()
        }
    }
}
