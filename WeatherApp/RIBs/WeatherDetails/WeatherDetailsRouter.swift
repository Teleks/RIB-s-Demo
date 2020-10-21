//
//  WeatherDetailsRouter.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 19.10.2020.
//

import RIBs

protocol WeatherDetailsInteractable: Interactable, CitiesSelectionListener {
    var router: WeatherDetailsRouting? { get set }
    var listener: WeatherDetailsListener? { get set }
}

protocol WeatherDetailsViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class WeatherDetailsRouter: LaunchRouter<WeatherDetailsInteractable, WeatherDetailsViewControllable>, WeatherDetailsRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    init(interactor: WeatherDetailsInteractable,
                  viewController: WeatherDetailsViewControllable,
                  citiesSelectionBuilder: CitiesSelectionBuilder)
    {
        self.citiesSelectionBuilder = citiesSelectionBuilder

        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    // MARK: - Routing

    func routeToCitiesSelection() {
        let routing = citiesSelectionBuilder.build(withListener: interactor)

        let vc = routing.viewControllable.uiviewController
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        nc.modalTransitionStyle = .flipHorizontal

        viewController.uiviewController.present(nc, animated: true, completion: nil)
        attachChild(routing)

        currentChild = routing
    }

    func routeToWeatherDetails() {
        detachCurrentChild()
    }

    // MARK: - Private

    private let citiesSelectionBuilder: CitiesSelectionBuilder

    private var currentChild: ViewableRouting?

    private func detachCurrentChild() {
        guard let currentChild = currentChild else { return }

        currentChild.viewControllable.uiviewController.dismiss(animated: true, completion: nil)
        detachChild(currentChild)

        self.currentChild = nil
    }
}
