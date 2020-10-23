//
//  WeatherDetailsBuilder.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 19.10.2020.
//

import RIBs

protocol WeatherDetailsDependency: Dependency {

}

final class WeatherDetailsComponent: Component<WeatherDetailsDependency>, WeatherDetailsScreenSettings {
    let weatherProvider: WeatherProvider = DefaultWeatherProvider(weatherRepository: DefaultWeatherRepository(),
                                                                  cityRepository: DefaultCityRepository())

    var city: City? = nil
}

// MARK: - Builder

protocol WeatherDetailsBuildable: Buildable {
    func build() -> LaunchRouting
}

final class WeatherDetailsBuilder: Builder<WeatherDetailsDependency>, WeatherDetailsBuildable {

    override init(dependency: WeatherDetailsDependency) {
        super.init(dependency: dependency)
    }

    func build() -> LaunchRouting {
        let component = WeatherDetailsComponent(dependency: dependency)
        let storyboard = UIStoryboard(name: "WeatherDetails", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WeatherDetailsViewController") as! WeatherDetailsViewController
        let interactor = WeatherDetailsInteractor(presenter: viewController, weatherProvider: component.weatherProvider, settings: component)

        let citiesSelectionBuilder = CitiesSelectionBuilder(dependency: component)

        return WeatherDetailsRouter(interactor: interactor, viewController: viewController, citiesSelectionBuilder: citiesSelectionBuilder)
    }
}
