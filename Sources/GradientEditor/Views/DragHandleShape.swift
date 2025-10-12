//
//  DragHandleShape.swift
//  DragHandleTest
//
//  Created by Joshua Sullivan on 4/2/24.
//

import SwiftUI

struct DragHandleShape: View {
    var body: some View {
        GeometryReader { geometry in
            let h = geometry.size.height
            let w: CGFloat = geometry.size.width
            
            Path { path in
                path.move(to: CGPoint(x: 0, y: h/2))
                path.addLine(to: CGPoint(x: h/2, y: 0))
                path.addLine(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: w, y: h))
                path.addLine(to: CGPoint(x: h/2, y: h))
                path.addLine(to: CGPoint(x: 0, y: h/2))
                path.closeSubpath()
            }
        }
    }
}

#Preview {
    DragHandleShape()
        .frame(width: 80, height: 40)
}
