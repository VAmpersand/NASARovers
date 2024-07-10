//
//  PhotosProvider.swift
//  NASARovers
//
//  Created by Viktor Prikolota on 07.07.2024.
//

import Foundation

protocol PhotosProvider {
    func fetchPhoto(_ completion: @escaping  ([Int: String]) -> ())
    func addToFavorite(_ photo: Photo)
    func removeFromFavorite(_ photo: Photo)
}

final class PhotosProviderImpl: PhotosProvider {
    private let apiDataProvider = APIDataProvider()
    private let udStorageManager = UDStorageManager()

    private let rover: Rover
    private var photoManifest: Manifest?
    private var currentSolData: ManifestPhoto?
    private var currentPage = 0

    private var photoURLCaches: [Int: String] = [:]

    private var favoritePhotoIDs: Set<Int> {
        udStorageManager.object(forKey: .favoritePhotos) ?? []
    }

    init(for rover: Rover) {
        self.rover = rover
    }

    func fetchPhoto(_ completion: @escaping ([Int: String]) -> ()) {
        if let photoManifest {
            getMorePhoto(completion)
        } else {
            apiDataProvider.getData(for: .manifests(rover: rover)) { [weak self] (data: ManifestResponse) in
                guard let self else { return }

                self.photoManifest = data.photoManifest
                currentSolData = data.photoManifest.sortedPhotos.first(where: { $0.sol == self.photoManifest?.maxSol })

                print(photoManifest!.sortedPhotos.map(\.sol))
                getMorePhoto(completion)
            } errorHandler: { error in
                print(error.description)
            }
        }
    }

    private func getMorePhoto(_ completion: @escaping ([Int: String]) -> ()) {
        guard let currentSolData else { return }

        apiDataProvider.getData(
            for: .photoForSol(
                currentSolData.sol,
                rover: rover,
                page: currentPage
            )
        ) { [weak self] (data: PhotosResponse) in
            guard let self else { return }

            print(currentSolData.sol, currentSolData.pagesCount, currentPage)
            currentPage += 1
            if currentPage > currentSolData.pagesCount {
                currentPage = 0

                let currentSolDataIndex = photoManifest?.sortedPhotos.firstIndex(where: { $0.sol == currentSolData.sol }) ?? 0
                let nextSolDataIndex = currentSolDataIndex + 1
                if photoManifest?.sortedPhotos.indices.contains(nextSolDataIndex) == true {
                    self.currentSolData = photoManifest?.sortedPhotos[nextSolDataIndex]
                }
            }

            data.photos.forEach { self.photoURLCaches[$0.id] = $0.imgSrc }
            completion(photoURLCaches)
        } errorHandler: { error in
            print(error.description)
        }
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
