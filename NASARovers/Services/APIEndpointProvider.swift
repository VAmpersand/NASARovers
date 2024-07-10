//
//  APIEndpointProvider.swift
//  NASARovers
//
//  Created by Viktor Prikolota on 03.07.2024.
//

import Foundation

enum Endpount {
    case manifests(rover: Rover)
    case photoForSol(Int, rover: Rover, page: Int)
    case photoForDate(Date,  rover: Rover, page: Int)
    case roverPage(rover: Rover)
}

final class APIEndpointProvider {
    private let apiKey: String
    private let baseURL: URL
    private let pageURLs: [String: String]

    init() {
        var format = PropertyListSerialization.PropertyListFormat.xml

        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let data = FileManager.default.contents(atPath: path),
              let config = try? PropertyListSerialization.propertyList(
                from: data,
                options: .mutableContainersAndLeaves,
                format: &format
              ) as? [String: Any] else {
            fatalError("Config.plist not found")
        }

        self.apiKey = config["apiKey"] as! String
        self.pageURLs = config["roverPageURL"] as! [String: String]
        let api = config["api"] as! [String: Any]

        var urlComponents = URLComponents()
        urlComponents.scheme = api["scheme"] as! String
        urlComponents.host = api["domen"] as! String
        urlComponents.path = (api["subDomen"] as! String) + (api["version"] as! String)

        baseURL = urlComponents.url!
    }

    func getURL(for endpoint: Endpount) -> URL{
        var url = baseURL

        switch endpoint {
        case .manifests(let rover):
            url.append(path: "manifests/\(rover.rawValue)")
        case .photoForDate(let date, let rover, let page):
            url.append(path: "rovers/\(rover.rawValue)/photos")

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            url.append(queryItems: [
                URLQueryItem(name: "earth_date", value: dateFormatter.string(from: date)),
                URLQueryItem(name: "page", value: String(page))
            ])

        case .photoForSol(let sol, let rover, let page):
            url.append(path: "rovers/\(rover.rawValue)/photos")

            url.append(queryItems: [
                URLQueryItem(name: "sol", value: String(sol)),
                URLQueryItem(name: "page", value: String(page))
            ])
        case .roverPage(let rover):
            guard let urlStr = pageURLs[rover.rawValue],
                  let url = URL(string: urlStr) else { return baseURL }

            return url
        }

        url.append(queryItems: [
            URLQueryItem(name: "api_key", value: apiKey)
        ])

        return url
    }
}
