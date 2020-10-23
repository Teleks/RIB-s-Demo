//
//  CitiesSelectionBuilder.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 19.10.2020.
//

import RIBs

protocol CitiesSelectionDependency: Dependency {
    var weatherProvider: WeatherProvider { get }

    var isCancellable: Bool { get }
}

final class CitiesSelectionComponent: Component<CitiesSelectionDependency> {

    var weatherProvider: WeatherProvider { dependency.weatherProvider }

    fileprivate let cityProvider = DefaultCityProvider(repository: DefaultCityRepository())
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
        viewController.isCancellable = dependency.isCancellable

        let interactor = CitiesSelectionInteractor(presenter: viewController,
                                                   cityProvider: component.cityProvider,
                                                   weatherProvider: component.weatherProvider)
        interactor.listener = listener

        return CitiesSelectionRouter(interactor: interactor, viewController: viewController)
    }
}
