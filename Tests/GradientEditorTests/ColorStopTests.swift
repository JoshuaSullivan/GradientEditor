import Testing
import Foundation
import CoreGraphics
@testable import GradientEditor

@Suite("ColorStop Tests")
struct ColorStopTests {

    // MARK: - Initialization Tests

    @Test("ColorStop initializes with position and type")
    func initialization() {
        let stop = ColorStop(position: 0.5, type: .single(.red))

        #expect(stop.position == 0.5)
        if case .single(let color) = stop.type {
            #expect(color == .red)
        } else {
            Issue.record("Expected single color type")
        }
    }

    @Test("ColorStop initializes with dual color type")
    func dualColorInitialization() {
        let stop = ColorStop(position: 0.3, type: .dual(.blue, .green))

        #expect(stop.position == 0.3)
        if case .dual(let colorA, let colorB) = stop.type {
            #expect(colorA == .blue)
            #expect(colorB == .green)
        } else {
            Issue.record("Expected dual color type")
        }
    }

    // MARK: - Comparable Tests

    @Test("ColorStops compare by position")
    func comparison() {
        let stop1 = ColorStop(position: 0.2, type: .single(.red))
        let stop2 = ColorStop(position: 0.5, type: .single(.blue))
        let stop3 = ColorStop(position: 0.8, type: .single(.green))

        #expect(stop1 < stop2)
        #expect(stop2 < stop3)
        #expect(stop1 < stop3)
        #expect(!(stop2 < stop1))
    }

    @Test("ColorStops with equal positions are not less than each other")
    func equalPositionComparison() {
        let stop1 = ColorStop(position: 0.5, type: .single(.red))
        let stop2 = ColorStop(position: 0.5, type: .single(.blue))

        #expect(!(stop1 < stop2))
        #expect(!(stop2 < stop1))
    }

    // MARK: - Identifiable Tests

    @Test("ColorStop generates unique IDs")
    func uniqueIdentifiers() {
        let stop1 = ColorStop(position: 0.5, type: .single(.red))
        let stop2 = ColorStop(position: 0.5, type: .single(.red))

        #expect(stop1.id != stop2.id)
    }

    @Test("ColorStop maintains ID across copies")
    func idPersistence() {
        let stop1 = ColorStop(position: 0.5, type: .single(.red))
        let stop2 = ColorStop(id: stop1.id, position: 0.5, type: .single(.red))

        #expect(stop1.id == stop2.id)
    }

    // MARK: - Codable Tests

    @Test("ColorStop encodes and decodes single color")
    func codableSingleColor() throws {
        let original = ColorStop(position: 0.5, type: .single(.red))

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ColorStop.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.position == original.position)
        if case .single(let color) = decoded.type {
            #expect(color == .red)
        } else {
            Issue.record("Expected single color type after decoding")
        }
    }

    @Test("ColorStop encodes and decodes dual color")
    func codableDualColor() throws {
        let original = ColorStop(position: 0.3, type: .dual(.blue, .green))

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ColorStop.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.position == original.position)
        if case .dual(let colorA, let colorB) = decoded.type {
            #expect(colorA == .blue)
            #expect(colorB == .green)
        } else {
            Issue.record("Expected dual color type after decoding")
        }
    }

    // MARK: - Edge Case Tests

    @Test("ColorStop handles position at boundaries")
    func boundaryPositions() {
        let stopStart = ColorStop(position: 0.0, type: .single(.red))
        let stopEnd = ColorStop(position: 1.0, type: .single(.blue))

        #expect(stopStart.position == 0.0)
        #expect(stopEnd.position == 1.0)
        #expect(stopStart < stopEnd)
    }
}
