//
//  SegmentShapes.swift
//  NASARovers
//
//  Created by Viktor Prikolota on 13.07.2024.
//

import SwiftUI
import PureSwiftUI

struct Layout {
    static let layoutConfig = LayoutGuideConfig.grid(columns: 100, rows: 126)
}

struct OpportunitySegment: Shape {
    func path(in rect: CGRect) -> Path {
        let grid = Layout.layoutConfig.layout(in: rect)
        var path = Path()

        path.move(to: grid[4, 4])
        path.addLine(to: grid[90, 4])
        path.curve(grid[96, 9], cp1: grid[94, 4], cp2: grid[96, 6])

        path.addLine(to: grid[96, 30])
        path.curve(grid[93, 38], cp1: grid[96, 31], cp2: grid[96, 35])

        path.addLine(to: grid[57, 74])
        path.curve(grid[50, 74], cp1: grid[55, 76], cp2: grid[52, 76])

        path.addLine(to: grid[6, 30])
        path.curve(grid[4, 25], cp1: grid[4, 28], cp2: grid[4, 24])

        path.addLine(to: grid[4, 10])
        path.curve(grid[10, 4], cp1: grid[4, 6], cp2: grid[6, 4])

        return path
    }
}

struct SpiritSegment: Shape {
    func path(in rect: CGRect) -> Path {
        let grid = Layout.layoutConfig.layout(in: rect)
        var path = Path()

        path.move(to: grid[8, 39])
        path.addLine(to: grid[91, 122])
        path.curve(grid[89, 126], cp1: grid[92, 123], cp2: grid[92, 126])

        path.addLine(to: grid[9, 126])
        path.curve(grid[4, 121], cp1: grid[5, 126], cp2: grid[4, 122])

        path.addLine(to: grid[4, 41])
        path.curve(grid[8, 39], cp1: grid[4, 38], cp2: grid[7, 38])

        return path
    }
}

struct CuriositySegment: Shape {
    func path(in rect: CGRect) -> Path {
        let grid = Layout.layoutConfig.layout(in: rect)
        var path = Path()

        path.move(to: grid[96, 47])
        path.addLine(to: grid[96, 113])
        path.curve(grid[91, 115], cp1: grid[96, 115], cp2: grid[94, 117])

        path.addLine(to: grid[60, 84])
        path.curve(grid[60, 77], cp1: grid[58, 82], cp2: grid[58, 79])

        path.addLine(to: grid[92, 46])
        path.curve(grid[96, 48], cp1: grid[93, 45], cp2: grid[96, 44])

        return path
    }
}
