//
//  CountriesInteractor.swift
//  CountriesSwiftUI
//
//  Created by Alexey on 7/11/24.
//  Copyright © 2024 Alexey Naumov. All rights reserved.
//

protocol CountriesInteractor {
    func refreshCountriesList() async throws
    func loadCountryDetails(country: DBModel.Country, forceReload: Bool) async throws -> DBModel.CountryDetails
}

struct RealCountriesInteractor: CountriesInteractor {

    let webRepository: CountriesWebRepository
    let dbRepository: CountriesDBRepository

    func refreshCountriesList() async throws {
        // MVVM flow: View triggers this action, Interactor fetches remote data, Repository persists it.
        let remoteCountries = try await webRepository.countries()
        try await dbRepository.store(countries: remoteCountries)
    }

    func loadCountryDetails(
        country: DBModel.Country, forceReload: Bool
    ) async throws -> DBModel.CountryDetails {
        if !forceReload,
           let cachedDetails = try? await dbRepository.countryDetails(for: country) {
            return cachedDetails
        }
        let remoteDetails = try await webRepository.details(country: country)
        try await dbRepository.store(countryDetails: remoteDetails, for: country)
        guard let persistedDetails = try? await dbRepository.countryDetails(for: country) else {
            throw ValueIsMissingError()
        }
        return persistedDetails
    }
}

struct StubCountriesInteractor: CountriesInteractor {

    func refreshCountriesList() async throws {
    }

    func loadCountryDetails(country: DBModel.Country, forceReload: Bool) async throws -> DBModel.CountryDetails {
        throw ValueIsMissingError()
    }
}
