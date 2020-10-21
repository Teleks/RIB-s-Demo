//
//  WeatherRepository.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 21.10.2020.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa

final class DefaultWeatherRepository: WeatherRepository {
    
    func temperature(in city: String) -> Int? {
        return forecast(for: city, in: Realm.shared)?.temperature.current
    }

    func forecast(for city: String, in realm: Realm) -> BaseForecast? {
        guard let entity = realm.object(ofType: RealmBaseForecast.self, forPrimaryKey: city) else { return nil }
        return entity.toBaseForecast()
    }

    func saveForecast(for city: String, with forecast: BaseForecast) -> Single<BaseForecast> {
        Single<BaseForecast>.create { (s) -> Disposable in
            do {
                let realm = try Realm()

                try realm.write({
                    let cityForecast: RealmBaseForecast

                    if let entity = realm.object(ofType: RealmBaseForecast.self, forPrimaryKey: city) {
                        entity.update(with: forecast)
                        cityForecast = entity
                    } else {
                        let entity = RealmBaseForecast(forecast)
                        realm.add(entity)
                        cityForecast = entity
                    }

                    s(.success(cityForecast.toBaseForecast()))
                })
            } catch {
                s(.error(error))
            }

            return Disposables.create()
        }
    }



}
