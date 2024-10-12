//
//  ImageViewModel.swift
//  trip-tracker
//
//  Created by Raymond King on 11.10.24.
//

import SwiftUI

@Observable class ImageViewModel {
    private let accessKey = "MnVxMNJF2r7WBgA7eDhJKkTFXe--PLpXh6lGUSDLgs0"
    var imageUrl: URL?

    func searchSinglePhoto(forCountry country: String) async {
        let query = "famous tourist attractions in \(country)"
        let urlString = "https://api.unsplash.com/photos/random?client_id=\(accessKey)&query=\(query)"

        if let url = URL(string: urlString) {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let result = try JSONDecoder().decode(SearchResult.self, from: data)
                DispatchQueue.main.async {
                    self.imageUrl = URL(string: result.urls.small)
                }
            } catch {
                DispatchQueue.main.async {
                    self.imageUrl = nil
                }
            }
        }
    }

    private struct SearchResult: Codable {
        let urls: Urls
    }

    private struct Urls: Codable {
        let small: String
    }
}
