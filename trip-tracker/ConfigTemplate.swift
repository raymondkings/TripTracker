//
//  Environment.swift
//  trip-tracker
//
//  Created by Raymond King on 08.04.25.
//

import Foundation

public enum ConfigTemplate {
    enum Keys {
        static let geminiApiKey = "GEMINI_API_KEY"
        static let unsplashAccessKey = "UNSPLASH_ACCESS_KEY"
    }
    
    private static let infoDictionary: [String:Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    static let geminiAPIKey: String = {
        guard let key = Bundle.main.infoDictionary?[Keys.geminiApiKey] as? String else {
           fatalError("API key not found in Info.plist")
       }
       return key
   }()
    
    static let unsplashAccessKey: String = {
        guard let key = Bundle.main.infoDictionary?[Keys.unsplashAccessKey] as? String else {
           fatalError("Unsplash Access key not found in Info.plist")
       }
       return key
   }()
}
