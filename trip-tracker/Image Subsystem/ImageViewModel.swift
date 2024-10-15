//
//  ImageViewModel.swift
//  trip-tracker
//
//  Created by Raymond King on 11.10.24.
//

import os
import SwiftUI

@Observable class ImageViewModel {
    private let logger = Logger(subsystem: "trip-tracker", category: "ImageViewModel")
    private let accessKey = "MnVxMNJF2r7WBgA7eDhJKkTFXe--PLpXh6lGUSDLgs0"
    var imageUrl: URL?

    func searchSinglePhoto(forCountry country: String) async throws {
        let query = "famous tourist attractions in \(country)"
        let urlString = "https://api.unsplash.com/photos/random?client_id=\(accessKey)&query=\(query)"

        logger.debug("Initiating photo search for \(country). URL: \(urlString, privacy: .public)")

        if let url = URL(string: urlString) {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)

                // Log response status code
                if let httpResponse = response as? HTTPURLResponse {
                    logger.info("Received HTTP status code: \(httpResponse.statusCode)")

                    if httpResponse.statusCode == 401 {
                        logger.error("Authentication error: Invalid API access key.")
                        throw URLError(.userAuthenticationRequired)
                    } else if httpResponse.statusCode == 403 {
                        logger.error("Access denied: Check API permissions.")
                        throw URLError(.badServerResponse)
                    }
                }

                // Attempt to decode the JSON response
                let result = try JSONDecoder().decode(SearchResult.self, from: data)
                logger.info("Successfully decoded the photo URL for \(country).")

                imageUrl = URL(string: result.urls.small)
            } catch {
                // Log error details and reset imageUrl
                DispatchQueue.main.async {
                    self.imageUrl = nil
                }
                logger.error("Failed to fetch or decode photo for \(country). Error: \(error.localizedDescription, privacy: .public)")
                throw error
            }
        } else {
            logger.error("Invalid URL: \(urlString, privacy: .public)")
        }
    }

    private struct SearchResult: Codable {
        let urls: Urls
    }

    private struct Urls: Codable {
        let small: String
    }
}
