//
//  ManifestResponse.swift
//  NASARovers
//
//  Created by Viktor Prikolota on 07.07.2024.
//

import Foundation

struct ManifestResponse: Codable {
    let photoManifest: Manifest
}

struct Manifest: Codable {
    let name: String
    let landingDate: String
    let launchDate: String
    let status: String
    let maxSol: Int
    let maxDate: String
    let totalPhotos: Int
    private let photos: [ManifestPhoto]

    var sortedPhotos: [ManifestPhoto] {
        photos.reversed()
    }
}

extension Manifest {
    var rover: Rover { Rover(rawValue: name.lowercased()) ?? .opportunity }
}

struct ManifestPhoto: Codable {
    let sol: Int
    let earthDate: String
    let totalPhotos: Int
    let cameras: [String]

    var pagesCount: Int {
        var pages = totalPhotos / 25
        pages += totalPhotos % 25 == 0 ? 0 : 1
        return pages
    }
}
