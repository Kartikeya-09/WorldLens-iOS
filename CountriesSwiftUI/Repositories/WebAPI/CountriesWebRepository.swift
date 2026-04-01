//
//  CountriesWebRepository.swift
//  CountriesSwiftUI
//
//  Created by Alexey on 7/11/24.
//  Copyright © 2024 Alexey Naumov. All rights reserved.
//

import Foundation

protocol CountriesWebRepository: WebRepository {
    func countries() async throws -> [ApiModel.Country]
    func details(country: DBModel.Country) async throws -> ApiModel.CountryDetails
}

struct RealCountriesWebRepository: CountriesWebRepository {

    let session: URLSession
    let baseURL: String

    init(session: URLSession) {
        self.session = session
        self.baseURL = "https://restcountries.com/v2"
    }

    func countries() async throws -> [ApiModel.Country] {
        return try await call(endpoint: API.allCountries)
    }

    func details(country: DBModel.Country) async throws -> ApiModel.CountryDetails {
        return try await call(endpoint: API.countryDetails(alpha3Code: country.alpha3Code))
    }
}

// MARK: - Endpoints

extension RealCountriesWebRepository {
    enum API {
        case allCountries
        case countryDetails(alpha3Code: String)
    }
}

extension RealCountriesWebRepository.API: APICall {
    var path: String {
        switch self {
        case .allCountries:
            return "/all?fields=name,translations,population,flag,alpha3Code"
        case let .countryDetails(alpha3Code):
            return "/alpha/\(alpha3Code)"
        }
    }
    var method: String {
        switch self {
        case .allCountries, .countryDetails:
            return "GET"
        }
    }
    var headers: [String: String]? {
        return ["Accept": "application/json"]
    }
    func body() throws -> Data? {
        return nil
    }
}
