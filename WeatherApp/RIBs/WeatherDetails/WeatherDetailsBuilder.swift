//
//  WeatherDetailsBuilder.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 19.10.2020.
//

import RIBs

protocol WeatherDetailsDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class WeatherDetailsComponent: Component<WeatherDetailsDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
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
        let interactor = WeatherDetailsInteractor(presenter: viewController)

        let citiesSelectionBuilder = CitiesSelectionBuilder(dependency: component)

        return WeatherDetailsRouter(interactor: interactor, viewController: viewController, citiesSelectionBuilder: citiesSelectionBuilder)
    }
}
