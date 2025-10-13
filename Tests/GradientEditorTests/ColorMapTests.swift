import Testing
import Foundation
import CoreGraphics
@testable import GradientEditor

@Suite("ColorMap Tests")
struct ColorMapTests {

    // MARK: - Initialization Tests

    @Test("ColorMap initializes with stops")
    func initialization() {
        let stops = [
            ColorStop(position: 0.0, type: .single(.red)),
            ColorStop(position: 1.0, type: .single(.blue))
        ]
        let colorMap = ColorMap(stops: stops)

        #expect(colorMap.stops.count == 2)
        #expect(colorMap.stops[0].position == 0.0)
        #expect(colorMap.stops[1].position == 1.0)
    }

    @Test("ColorMap preserves stop order from input")
    func preserveOrder() {
        let stops = [
            ColorStop(position: 0.8, type: .single(.green)),
            ColorStop(position: 0.2, type: .single(.red)),
            ColorStop(position: 0.5, type: .single(.blue))
        ]
        let colorMap = ColorMap(stops: stops)

        // ColorMap stores stops in the order provided
        #expect(colorMap.stops[0].position == 0.8)
        #expect(colorMap.stops[1].position == 0.2)
        #expect(colorMap.stops[2].position == 0.5)
    }

    @Test("ColorMap initializes with empty stops")
    func emptyInitialization() {
        let colorMap = ColorMap(stops: [])
        #expect(colorMap.stops.isEmpty)
    }

    // MARK: - Codable Tests

    @Test("ColorMap encodes and decodes")
    func codable() throws {
        let stops = [
            ColorStop(position: 0.0, type: .single(.red)),
            ColorStop(position: 0.5, type: .dual(.blue, .green)),
            ColorStop(position: 1.0, type: .single(.yellow))
        ]
        let original = ColorMap(stops: stops)

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ColorMap.self, from: data)

        #expect(decoded.stops.count == original.stops.count)
        for (index, stop) in decoded.stops.enumerated() {
            #expect(stop.position == original.stops[index].position)
            #expect(stop.id == original.stops[index].id)
        }
    }

    @Test("ColorMap with empty stops encodes and decodes")
    func codableEmpty() throws {
        let original = ColorMap(stops: [])

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ColorMap.self, from: data)

        #expect(decoded.stops.isEmpty)
    }

    // MARK: - Sendable Conformance Tests

    @Test("ColorMap is Sendable")
    func sendableConformance() {
        let colorMap: any Sendable = ColorMap(stops: [])
        #expect(colorMap is ColorMap)
    }

    // MARK: - Edge Case Tests

    @Test("ColorMap handles single stop")
    func singleStop() {
        let stops = [ColorStop(position: 0.5, type: .single(.red))]
        let colorMap = ColorMap(stops: stops)

        #expect(colorMap.stops.count == 1)
        #expect(colorMap.stops[0].position == 0.5)
    }

    @Test("ColorMap handles many stops")
    func manyStops() {
        let stops = (0..<10).map { i in
            ColorStop(position: Double(i) / 9.0, type: .single(.red))
        }
        let colorMap = ColorMap(stops: stops)

        #expect(colorMap.stops.count == 10)
        #expect(colorMap.stops.first?.position == 0.0)
        #expect(colorMap.stops.last?.position == 1.0)
    }

    @Test("ColorMap handles duplicate positions")
    func duplicatePositions() {
        let stops = [
            ColorStop(position: 0.5, type: .single(.red)),
            ColorStop(position: 0.5, type: .single(.blue)),
            ColorStop(position: 0.5, type: .single(.green))
        ]
        let colorMap = ColorMap(stops: stops)

        #expect(colorMap.stops.count == 3)
        #expect(colorMap.stops.allSatisfy { $0.position == 0.5 })
    }
}
