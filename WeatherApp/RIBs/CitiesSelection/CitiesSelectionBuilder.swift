//
//  CitiesSelectionBuilder.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 19.10.2020.
//

import RIBs

protocol CitiesSelectionDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class CitiesSelectionComponent: Component<CitiesSelectionDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol CitiesSelectionBuildable: Buildable {
    func build(withListener listener: CitiesSelectionListener) -> CitiesSelectionRouting
}

final class CitiesSelectionBuilder: Builder<CitiesSelectionDependency>, CitiesSelectionBuildable {

    override init(dependency: CitiesSelectionDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: CitiesSelectionListener) -> CitiesSelectionRouting {
        let component = CitiesSelectionComponent(dependency: dependency)
        let storyboard = UIStoryboard(name: "CitiesSelection", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CitiesSelectionViewController") as! CitiesSelectionViewController

        let cityRepo = DefaultCityRepository()
        let cityProvider = DefaultCityProvider(repository: cityRepo)
        let weatherProvider = DefaultWeatherProvider(repository: DefaultWeatherRepository())
        let interactor = CitiesSelectionInteractor(presenter: viewController, cityProvider: cityProvider, weatherProvider: weatherProvider)
        interactor.listener = listener

        return CitiesSelectionRouter(interactor: interactor, viewController: viewController)
    }
}
