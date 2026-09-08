import Ownership
import Testing

@Suite
struct `The Ownership namespace is available to clients` {
    @Test
    func `Ownership provides the package namespace`() {
        #expect(MemoryLayout<Ownership>.size == 0)
    }
}
