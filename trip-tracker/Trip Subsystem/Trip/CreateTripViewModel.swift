//
//  CreateTripViewModel.swift
//  trip-tracker
//
//  Created by Raymond King on 12.10.24.
//

import Foundation
import os
import SwiftUI

// This viewModel is just used to abstract the createEditTrip since it contains a lot of logic
@Observable class CreateTripViewModel {
    private let logger = Logger(subsystem: "trip-tracker", category: "CreateTripViewModel")
    var tripName: String = ""
    var startDate: Date = .init()
    var endDate: Date = .init()
    var searchText: String = ""
    var isShowingDropdown: Bool = false
    var isTripNameValid: Bool = true
    var isValidCountry: Bool = true
    var isLoading: Bool = false

    let countries: [String]

    init() {
        let locale = Locale.current
        self.countries = Locale.Region.isoRegions
            .compactMap { region in
                locale.localizedString(forRegionCode: region.identifier)
            }
            .sorted()
        logger.info("Initialized CreateTripViewModel with countries: \(self.countries.count) available.")
    }

    var isFormValid: Bool {
        !tripName.isEmpty && isValidCountry
    }

    var filteredCountries: [String] {
        return countries.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    func validateCountry() {
        isValidCountry = countries.contains(searchText)
        isShowingDropdown = !searchText.isEmpty && !isValidCountry

        if isValidCountry {
            logger.info("Country '\(self.searchText)' is valid.")
        } else {
            logger.warning("Country '\(self.searchText)' is not valid.")
        }
    }

    func handleEditingChanged(_ isEditing: Bool) {
        isShowingDropdown = isEditing && !searchText.isEmpty
        logger.debug("Dropdown showing state changed to \(self.isShowingDropdown) while editing.")
    }

    func selectCountry(_ country: String) {
        searchText = country
        isShowingDropdown = false
        isValidCountry = true
        logger.info("Selected country: \(country). Dropdown closed.")
    }

    func validateCountry(_ newValue: String) {
        isValidCountry = countries.contains(newValue)
        isShowingDropdown = !newValue.isEmpty && !isValidCountry
    }

    func reset() {
        tripName = ""
        searchText = ""
        isTripNameValid = true
        isValidCountry = true
        startDate = Date()
        endDate = Date()
        logger.info("Reset CreateTripViewModel state.")
    }
}
