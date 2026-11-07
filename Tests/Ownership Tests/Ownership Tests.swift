import Ownership
import Testing

enum `Ownership Tests` {}

extension `Ownership Tests` {
    @Suite
    struct `The Ownership namespace is available to clients` {
        @Test
        func `Ownership provides the package namespace`() {
            #expect(MemoryLayout<Ownership>.size == 0)
        }
    }
}
