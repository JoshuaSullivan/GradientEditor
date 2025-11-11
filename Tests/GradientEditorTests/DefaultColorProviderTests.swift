//
//  DefaultColorProviderTests.swift
//  GradientEditor
//
//  Created by Claude on 11/11/25.
//

import Testing
import SwiftUI
import CoreGraphics
@testable import GradientEditor

@Suite("DefaultColorProvider Tests")
@MainActor
struct DefaultColorProviderTests {

    // MARK: - Initialization Tests

    @Test("DefaultColorProvider initializes successfully")
    func initialization() {
        let provider = DefaultColorProvider()
        #expect(provider is ColorProvider)
    }

    // MARK: - ColorEditContext Tests

    @Test("ColorEditContext stores first color index correctly")
    func contextFirstColorIndex() {
        let context = ColorEditContext(
            colorIndex: .first,
            isSingleColorStop: true,
            accessibilityLabel: "Color"
        )

        #expect(context.colorIndex == .first)
        #expect(context.isSingleColorStop == true)
        #expect(context.accessibilityLabel == "Color")
    }

    @Test("ColorEditContext stores second color index correctly")
    func contextSecondColorIndex() {
        let context = ColorEditContext(
            colorIndex: .second,
            isSingleColorStop: false,
            accessibilityLabel: "Second Color"
        )

        #expect(context.colorIndex == .second)
        #expect(context.isSingleColorStop == false)
        #expect(context.accessibilityLabel == "Second Color")
    }

    @Test("ColorEditContext handles dual color stop configuration")
    func contextDualColorStop() {
        let context = ColorEditContext(
            colorIndex: .first,
            isSingleColorStop: false,
            accessibilityLabel: "First Color"
        )

        #expect(context.isSingleColorStop == false)
    }

    // MARK: - View Creation Tests

    @Test("DefaultColorProvider creates view for single color stop")
    func viewCreationSingleColor() {
        let provider = DefaultColorProvider()

        let context = ColorEditContext(
            colorIndex: .first,
            isSingleColorStop: true,
            accessibilityLabel: "Color"
        )

        let view = provider.colorView(
            currentColor: .red,
            onColorChange: { _ in },
            context: context
        )

        #expect(view is AnyView)
    }

    @Test("DefaultColorProvider creates view for first color in dual stop")
    func viewCreationDualFirstColor() {
        let provider = DefaultColorProvider()

        let context = ColorEditContext(
            colorIndex: .first,
            isSingleColorStop: false,
            accessibilityLabel: "First Color"
        )

        let view = provider.colorView(
            currentColor: .blue,
            onColorChange: { _ in },
            context: context
        )

        #expect(view is AnyView)
    }

    @Test("DefaultColorProvider creates view for second color in dual stop")
    func viewCreationDualSecondColor() {
        let provider = DefaultColorProvider()

        let context = ColorEditContext(
            colorIndex: .second,
            isSingleColorStop: false,
            accessibilityLabel: "Second Color"
        )

        let view = provider.colorView(
            currentColor: .green,
            onColorChange: { _ in },
            context: context
        )

        #expect(view is AnyView)
    }

    // MARK: - Context Variations Tests

    @Test("DefaultColorProvider handles various color values")
    func variousColorValues() {
        let provider = DefaultColorProvider()
        let red: CGColor = .red
        let blue: CGColor = .blue
        let green: CGColor = .green
        let yellow: CGColor = .yellow
        let purple: CGColor = .purple
        let colors = [red, blue, green, yellow, purple]

        for color in colors {
            let context = ColorEditContext(
                colorIndex: .first,
                isSingleColorStop: true,
                accessibilityLabel: "Color"
            )

            let view = provider.colorView(
                currentColor: color,
                onColorChange: { _ in },
                context: context
            )

            #expect(view is AnyView)
        }
    }

    @Test("DefaultColorProvider handles different accessibility labels")
    func variousAccessibilityLabels() {
        let provider = DefaultColorProvider()
        let labels = ["Color", "First Color", "Second Color", "Custom Label"]

        for label in labels {
            let context = ColorEditContext(
                colorIndex: .first,
                isSingleColorStop: true,
                accessibilityLabel: label
            )

            let view = provider.colorView(
                currentColor: .red,
                onColorChange: { _ in },
                context: context
            )

            #expect(view is AnyView)
        }
    }

    // MARK: - Protocol Conformance Tests

    @Test("DefaultColorProvider conforms to ColorProvider protocol")
    func protocolConformance() {
        let provider: any ColorProvider = DefaultColorProvider()
        #expect(provider is DefaultColorProvider)
    }

    // MARK: - Sendable Tests

    @Test("ColorEditContext is Sendable")
    func contextSendable() {
        let context = ColorEditContext(
            colorIndex: .first,
            isSingleColorStop: true,
            accessibilityLabel: "Color"
        )
        let sendable: any Sendable = context
        #expect(sendable is ColorEditContext)
    }
}
