extension BinaryFloatingPoint {
    @inlinable
    func lerp(to: Self, by t: Self) -> Self { self + (to - self) * t }
}
