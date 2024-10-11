//
//  Image.swift
//  trip-tracker
//
//  Created by Raymond King on 11.10.24.
//

import SwiftUI

struct UnsplashImage: Identifiable, Codable {
    var id: String
    var urls: URLs

    struct URLs: Codable {
        var small: String
        var full: String
    }
}
