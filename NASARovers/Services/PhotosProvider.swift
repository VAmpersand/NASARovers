//
//  PhotosProvider.swift
//  NASARovers
//
//  Created by Viktor Prikolota on 07.07.2024.
//

import Foundation
import Combine

protocol PhotosProvider {
    func fetchPhoto() -> AnyPublisher<[Int: String], AppError> 
    func addToFavorite(_ photo: Photo)
    func removeFromFavorite(_ photo: Photo)
}

final class PhotosProviderImpl: PhotosProvider {
    private let apiDataProvider = APIDataProvider()
    private let udStorageManager = UDStorageManager()

    private var cancellables = Set<AnyCancellable>()

    private let rover: Rover
    private var manifest: Manifest?
    private var currentSolData: ManifestPhoto?
    private var currentPage = 1

    private var photoURLCaches: [Int: String] = [:]


    private var favoritePhotoIDs: Set<Int> {
        udStorageManager.object(forKey: .favoritePhotos) ?? []
    }

    init(for rover: Rover) {
        self.rover = rover
    }

    private func fetchManifest() -> AnyPublisher<Manifest, AppError> {
        if let manifest {
            return Just(manifest)
                .setFailureType(to: AppError.self)
                .eraseToAnyPublisher()
        } else {
            return apiDataProvider.request(with: .manifests(rover: rover))
                .map { (response: ManifestResponse) in
                    return response.photoManifest
                }
                .eraseToAnyPublisher()
        }
    }

    private func fetchPhotoPackage() -> AnyPublisher<PhotosResponse, AppError> {
        guard let currentSolData else {
            return Fail(error: AppError.other("Sol data invalid"))
                .eraseToAnyPublisher()
        }

        return apiDataProvider.request(with: .photoForSol(currentSolData.sol, rover: rover, page: currentPage))
    }

    func fetchPhoto() -> AnyPublisher<[Int: String], AppError> {
        return fetchManifest()
            .flatMap { [weak self] manifest -> AnyPublisher<[Int: String], AppError> in
                guard let self else {
                    return Fail(error: AppError.unknown)
                        .eraseToAnyPublisher()
                }
                self.manifest = manifest
                if currentSolData == nil {
                    currentSolData = manifest.sortedPhotos.first
                }

                return fetchPhotoPackage()
                    .flatMap { response -> AnyPublisher<[Int: String], AppError> in

                        self.currentPage += 1
                        if let currentSolData = self.currentSolData,
                           self.currentPage > currentSolData.pagesCount {
                            self.currentPage = 0

                            let currentSolDataIndex = manifest.sortedPhotos.firstIndex(where: { $0.sol == currentSolData.sol }) ?? 0
                            let nextSolDataIndex = currentSolDataIndex + 1
                            if manifest.sortedPhotos.indices.contains(nextSolDataIndex) == true {
                                self.currentSolData = manifest.sortedPhotos[nextSolDataIndex]
                            }
                        }
                        response.photos.forEach { self.photoURLCaches[$0.id] = $0.imgSrc }

                        return Just(self.photoURLCaches)
                            .setFailureType(to: AppError.self)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func addToFavorite(_ photo: Photo) {
        var favoritePhotoIDs = favoritePhotoIDs
        favoritePhotoIDs.insert(photo.id)
        udStorageManager.set(object: favoritePhotoIDs, fotKey: .favoritePhotos)
    }

    func removeFromFavorite(_ photo: Photo) {
        var favoritePhotoIDs = favoritePhotoIDs
        favoritePhotoIDs.remove(photo.id)
        udStorageManager.set(object: favoritePhotoIDs, fotKey: .favoritePhotos)
    }
}
