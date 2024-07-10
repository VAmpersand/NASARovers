//
//  ContentView.swift
//  NASARovers
//
//  Created by Viktor Prikolota on 03.07.2024.
//

import SwiftUI

struct ContentView: View {
    private let photoProvider: PhotosProvider

    init(for rover: Rover) {
        self.photoProvider = PhotosProviderImpl(for: rover)

        photoProvider.fetchPhoto { [self] dict in
            print(dict.count, "\n\n")

            self.photoProvider.fetchPhoto { [self] dict in
                print(dict.count, "\n\n")

                self.photoProvider.fetchPhoto { [self] dict in
                    print(dict.count, "\n\n")

                    self.photoProvider.fetchPhoto { [self] dict in
                        print(dict.count, "\n\n")

                        self.photoProvider.fetchPhoto { dict in
                            print(dict.count, "\n\n")
                        }
                    }
                }
            }
        }
    }

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView(for: .curiosity)
}
