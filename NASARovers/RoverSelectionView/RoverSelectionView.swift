//
//  RoverSelectionView.swift
//  NASARovers
//
//  Created by Viktor Prikolota on 03.07.2024.
//

import SwiftUI

struct RoverSelectionView: View {
    @ObservedObject var viewModel: RoverSelectionViewModel

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack {
                        ZStack {
                            ForEach(Rover.allCases, id: \.self) { rover in
                                Image("\(rover.rawValue)_shape_bg")
                                    .resizable()
                                    .scaledToFill()

                                    .modifier(ClipAnimatedShape(rover: rover, selectedRover: viewModel.selectedRover))
                                    .onTapGesture {
                                        withAnimation { viewModel.selectedRover = rover }
                                    }
                            }
                        }
                        .frame(UIScreen.width, UIScreen.width * 1.255, .trailing)
                        .padding(.top, 10)

                        Text(String(localized: "roverSelection_fetchAll_title").uppercased())
                            .padding(.horizontal, Layout.offset)
                            .padding(.top, 10)
                            .font(.system(size: 12, weight: .bold))
                            .frame(UIScreen.width, .infinity, .leading)
                            .foregroundColor(Color.gray)

                        TabView(selection: $viewModel.selectedRover.animation(.linear(duration: 0.15))) {
                            ForEach(Rover.allCases, id: \.self) { rover in
                                RoverInfoView(rover: rover)
                                    .onTapGesture {

                                    }
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(UIScreen.width, 250, .leading)

                        Spacer()
                            .height(100)
                    }
                }

                VStack {
                    Spacer()

                    HStack(spacing: 20) {
                        Button {

                        } label: {

                            Text(String(localized: "roverSelection_fetchAll").uppercased())
                                .font(.system(size: 15, weight: .bold))
                                .frame(UIScreen.width - 200, .infinity)
                                .foregroundColor(Color.white)
                                .padding()
                        }
                        .background(Color.blue)
                        .frame(.infinity, 50)
                        .clipCapsule()

                        Button {

                        } label: {
                            Image(systemName: "calendar")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFill()
                                .frame(20)
                                .foregroundColor(.white)
                                .padding(.vertical)
                                .padding(.horizontal, 25)
                        }
                        .background(Color.blue)
                        .frame(.infinity, 50)
                        .clipCapsule()
                    }
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: -3)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)

                }
            }
            .ignoresSafeArea()
            .navigationBarHidden(true)
        }
    }
}

// MARK: - RoverInfoView
struct RoverInfoView: View {
    var rover: Rover

    var body: some View {
        VStack {
            Text(rover.rawValue.uppercased())
                .font(.system(size: 32, weight: .semibold))
                .padding(.horizontal, Layout.offset)
                .padding(.bottom, 10)
                .frame(UIScreen.width, .infinity, .leading)
                .foregroundColor(Color.gray)

            Text(String(localized: "roverSelection_mission").uppercased())
                .padding(.horizontal, Layout.offset)
                .font(.system(size: 12, weight: .bold))
                .frame(UIScreen.width, .infinity, .leading)
                .foregroundColor(Color.gray)

            Text(getMissionInfo(for: rover))
                .padding(.horizontal, Layout.offset)
                .padding(.top, 3)
                .font(.system(size: 12))
                .frame(UIScreen.width, .infinity, .leading)
                .foregroundColor(Color.gray.opacity(0.9))
                .lineLimit(10)

            HStack {
                Text(String(localized: "roverSelection_more").uppercased())
                    .font(.system(size: 12))
                    .frame(.infinity, .infinity, .trailing)
                    .foregroundColor(Color.gray)

                Image(systemName: "ellipsis.circle")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFill()
                    .frame(20)
                    .foregroundColor(Color.gray)

            }
            .padding(.horizontal, Layout.offset)
            .frame(UIScreen.width, 32, .trailing)
        }
    }

    func getMissionInfo(for rover: Rover) -> String {
        switch rover {
        case .opportunity: return String(localized: "roverSelection_opportunityDescription")
        case .spirit: return String(localized: "roverSelection_spiritDescription")
        case .curiosity: return String(localized: "roverSelection_curiosityDescription")
        }
    }
}

// MARK: - ClipAnimatedShape
struct ClipAnimatedShape: ViewModifier {
    var rover: Rover
    var selectedRover: Rover

    func body(content: Content) -> some View {
        let offset: CGFloat = rover == selectedRover ? UIScreen.width * 0.025 : 0

        switch rover {
        case .opportunity:
            content
                .clipShape(OpportunitySegment())
                .contentShape(OpportunitySegment())
                .scaleEffect(rover == selectedRover ? 1.2 : 1)
                .offset(-offset * 0.2, -offset * 1.3)

        case .spirit:
            content
                .clipShape(SpiritSegment())
                .contentShape(SpiritSegment())
                .scaleEffect(rover == selectedRover ? 1.2 : 1)
                .offset(-offset * 4, -offset * 5)

        case .curiosity:
            content
                .clipShape(CuriositySegment())
                .contentShape(CuriositySegment())
                .scaleEffect(rover == selectedRover ? 1.2 : 1)
                .offset(offset * 0.07, -offset * 1.2)
        }
    }
}

fileprivate extension Layout {
    static var offset: CGFloat {
        UIScreen.width * 0.04
    }
}

#Preview {
    RoverSelectionView(viewModel: RoverSelectionViewModel(for: .curiosity))
}
