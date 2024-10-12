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

    func searchSinglePhoto(forCountry country: String) {
        let query = "famous tourist attractions in \(country)"
        let urlString = "https://api.unsplash.com/photos/random?client_id=\(accessKey)&query=\(query)"

        guard let url = URL(string: urlString) else {
            imageUrl = nil
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.imageUrl = nil
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.imageUrl = nil
                }
                return
            }

            do {
                let result = try JSONDecoder().decode(SearchResult.self, from: data)
                DispatchQueue.main.async {
                    self.imageUrl = URL(string: result.urls.small)
                }
            } catch {
                print("Error decoding JSON")
                DispatchQueue.main.async {
                    self.imageUrl = nil
                }
            }
        }
        task.resume()
    }

    private struct SearchResult: Codable {
        let urls: Urls
    }

    private struct Urls: Codable {
        let small: String
    }
}
