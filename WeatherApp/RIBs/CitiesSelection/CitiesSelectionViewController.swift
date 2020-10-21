//
//  CitiesSelectionViewController.swift
//  WeatherApp
//
//  Created by Nikita Egoshin on 19.10.2020.
//

import RIBs
import RxSwift
import UIKit
import RxSwift
import RxCocoa

protocol CitiesSelectionPresentableListener: class {
    func selectCity(atIndex cityIndex: Int)
    func searchCity(withText text: String)
    func addCity(city: String)
    func cancel()
}

final class CitiesSelectionViewController: UIViewController, CitiesSelectionPresentable, CitiesSelectionViewControllable {

	@IBOutlet weak var tableView: UITableView!

    weak var listener: CitiesSelectionPresentableListener?

    private let kCityCell = "kCityCell"

    private let disposeBag = DisposeBag()

    private var cities: [CityRecord] = []

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Action handlers

    func showCities(_ cities: [CityRecord]) {
        self.cities = cities
        tableView?.reloadData()
    }

    func showTemperature(at cityIndex: Int, temperature: Int?) {
        guard cityIndex < self.cities.count else { return }

        let record = self.cities[cityIndex]
        self.cities[cityIndex] = CityRecord(cityName: record.cityName, temperature: temperature)

        tableView.reloadRows(at: [IndexPath(row: cityIndex, section: 0)], with: .automatic)
    }

    // MARK: - Actions

    @IBAction func onCloseButtonTouch(_ sender: Any) {
        listener?.cancel()
    }
    
    @IBAction func onAddCityButtonTouch(_ sender: Any) {
        showAddCityAlert()
    }

    // MARK: - Alerts

    private func showAddCityAlert() {
        let alertVC = UIAlertController(title: "Add city", message: nil, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "Add", style: .default) { [weak alertVC, weak self] _ in
            guard let alertVC = alertVC, let self = self else { return }
            guard let cityName = alertVC.textFields?.first?.text, !cityName.isEmpty else { return }

            self.listener?.addCity(city: cityName)
        }

        alertVC.addTextField { [self] in
            $0.placeholder = "Type your city name..."

            $0.rx.text
                .map({ !($0 ?? "").isEmpty })
                .bind(to: okAction.rx.isEnabled)
                .disposed(by: disposeBag)
        }

        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertVC.addAction(okAction)

        present(alertVC, animated: true, completion: nil)
    }
}

extension CitiesSelectionViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: kCityCell) as? CityRecordCell else {
            fatalError("Cell with ID \'\(kCityCell)\' is not registered!")
        }

        let record = cities[indexPath.row]

        cell.cityNameLabel.text = record.cityName

        if let temperature = record.temperature {
        	cell.temperatureLabel.text = String(format: "%d° C", temperature)
        } else {
            cell.temperatureLabel.text = "—"
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        listener?.selectCity(atIndex: indexPath.row)
    }
}

extension CitiesSelectionViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        listener?.searchCity(withText: searchText)
    }
}
