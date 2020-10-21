//
//  CitiesSelectionRouter.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 19.10.2020.
//

import RIBs

protocol CitiesSelectionInteractable: Interactable {
    var router: CitiesSelectionRouting? { get set }
    var listener: CitiesSelectionListener? { get set }
}

protocol CitiesSelectionViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class CitiesSelectionRouter: ViewableRouter<CitiesSelectionInteractable, CitiesSelectionViewControllable>, CitiesSelectionRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: CitiesSelectionInteractable, viewController: CitiesSelectionViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
