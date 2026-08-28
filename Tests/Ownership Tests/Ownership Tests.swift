import Ownership
import Testing

@Suite
struct `Ownership Tests` {
    @Test
    func `Ownership provides the package namespace`() {
        #expect(MemoryLayout<Ownership>.size == 0)
    }
}
