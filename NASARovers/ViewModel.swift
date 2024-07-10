//
//  ViewModel.swift
//  NASARovers
//
//  Created by Viktor Prikolota on 10.07.2024.
//

import Foundation
import Combine

final class ViewModel: ObservableObject {
    private let photoProvider: PhotosProvider
    private let rover: Rover

    @Published var photoDict: [Int: String] = [:]
    private var cancellables = Set<AnyCancellable>()

    init(for rover: Rover) {
        self.rover = rover
        self.photoProvider = PhotosProviderImpl(for: rover)

        bind()
    }

    func bind() {
        photoProvider.fetchPhoto()
            .sink { completion in
                guard case .failure(let error) = completion else { return }

                print(error.description)
            } receiveValue: { [weak self] photos in
                guard let self else { return }
                print(photos.count)

                photoDict = photos

                photoProvider.fetchPhoto()
                    .sink { completion in
                        guard case .failure(let error) = completion else { return }

                        print(error.description)
                    } receiveValue: { [weak self] photos in
                        guard let self else { return }
                        print(photos.count)

                        photoDict = photos

                        self.photoProvider.fetchPhoto()
                            .sink { completion in
                                guard case .failure(let error) = completion else { return }

                                print(error.description)
                            } receiveValue: { [weak self] photos in
                                print(photos.count)

                                self?.photoDict = photos
                            }
                            .store(in: &self.cancellables)

                    }
                    .store(in: &cancellables)

            }
            .store(in: &cancellables)

    }
}
