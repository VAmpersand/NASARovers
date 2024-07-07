//
//  PhotosResponse.swift
//  NASARovers
//
//  Created by Viktor Prikolota on 07.07.2024.
//

import Foundation

struct PhotosResponse: Codable {
    let photos: [Photo]
}

struct Photo: Codable, Identifiable {
    let id: Int
    let sol: Int
    let camera: Camera
    let imgSrc: String
    let earthDate: String
    let rover: RoverData
}

struct Camera: Codable {
    let id: Int
    let name: String
    let roverId: Int
    let fullName: String
}

struct RoverData: Codable {
    let id: Int
    let name: String
    let landingDate: String
    let launchDate: String
    let status: String
}
