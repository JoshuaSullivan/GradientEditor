import Testing
import Foundation
import CoreGraphics
@testable import GradientEditor

@Suite("ColorStopType Tests")
struct ColorStopTypeTests {

    // MARK: - Initialization Tests

    @Test("Single color type stores color correctly")
    func singleColorInit() {
        let type = ColorStopType.single(.red)

        if case .single(let color) = type {
            #expect(color == .red)
        } else {
            Issue.record("Expected single color type")
        }
    }

    @Test("Dual color type stores both colors correctly")
    func dualColorInit() {
        let type = ColorStopType.dual(.blue, .green)

        if case .dual(let colorA, let colorB) = type {
            #expect(colorA == .blue)
            #expect(colorB == .green)
        } else {
            Issue.record("Expected dual color type")
        }
    }

    // MARK: - Helper Property Tests

    @Test("startColor returns correct color for single type")
    func singleStartColor() {
        let type = ColorStopType.single(.red)
        #expect(type.startColor == .red)
    }

    @Test("startColor returns first color for dual type")
    func dualStartColor() {
        let type = ColorStopType.dual(.blue, .green)
        #expect(type.startColor == .blue)
    }

    @Test("endColor returns correct color for single type")
    func singleEndColor() {
        let type = ColorStopType.single(.red)
        #expect(type.endColor == .red)
    }

    @Test("endColor returns second color for dual type")
    func dualEndColor() {
        let type = ColorStopType.dual(.blue, .green)
        #expect(type.endColor == .green)
    }

    // MARK: - Codable Tests

    @Test("Single color type encodes and decodes")
    func codableSingle() throws {
        let original = ColorStopType.single(.red)

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ColorStopType.self, from: data)

        #expect(decoded.startColor == original.startColor)
        #expect(decoded.endColor == original.endColor)
    }

    @Test("Dual color type encodes and decodes")
    func codableDual() throws {
        let original = ColorStopType.dual(.blue, .green)

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ColorStopType.self, from: data)

        #expect(decoded.startColor == original.startColor)
        #expect(decoded.endColor == original.endColor)
    }

    // MARK: - Sendable Conformance Tests

    @Test("ColorStopType is Sendable")
    func sendableConformance() {
        let type: any Sendable = ColorStopType.single(.red)
        #expect(type is ColorStopType)
    }
}
