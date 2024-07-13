//
//  ContentView.swift
//  NASARovers
//
//  Created by Viktor Prikolota on 03.07.2024.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ZStack {
            Color($viewModel.photoDict.wrappedValue.isEmpty ? .white : .red)
                .ignoresSafeArea()

            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
            .padding()
        }
    }
}

#Preview {
    ContentView(viewModel: ViewModel(for: .curiosity))
}
