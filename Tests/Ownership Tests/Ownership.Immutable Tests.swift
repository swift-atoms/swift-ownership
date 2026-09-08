import Ownership
import Testing

@Suite
struct `Immutable ownership preserves shared values and identity` {
    @Suite struct `Immutable owners retain their value across repeated reads and shared references` {}
    @Suite struct `Immutable owners preserve struct and class payloads` {}
    @Suite struct `Sendable immutable owners preserve their value across tasks` {}
}

extension `Immutable ownership preserves shared values and identity`.`Immutable owners retain their value across repeated reads and shared references` {
    @Test
    func `init(_:) stores the value`() {
        let immutable = Ownership.Immutable(42)
        #expect(immutable.value == 42)
    }

    @Test
    func `value is immutable — repeated reads return the same value`() {
        let immutable = Ownership.Immutable("hello")
        #expect(immutable.value == "hello")
        #expect(immutable.value == "hello")
    }

    @Test
    func `ARC sharing — multiple references see same identity`() {
        let immutable = Ownership.Immutable(7)
        let alias = immutable
        #expect(immutable === alias)
        #expect(alias.value == 7)
    }
}

extension `Immutable ownership preserves shared values and identity`.`Immutable owners preserve struct and class payloads` {
    @Test
    func `An immutable owner preserves its stored struct value`() {
        struct Point: Equatable, Sendable {
            var x: Int
            var y: Int
        }
        let immutable = Ownership.Immutable(Point(x: 3, y: 4))
        #expect(immutable.value == Point(x: 3, y: 4))
    }

    @Test
    func `An immutable owner exposes its stored class payload`() {
        final class Node: Sendable {
            let id: Int
            init(_ id: Int) { self.id = id }
        }
        let immutable = Ownership.Immutable(Node(1))
        #expect(immutable.value.id == 1)
    }
}

extension `Immutable ownership preserves shared values and identity`.`Sendable immutable owners preserve their value across tasks` {
    @Test
    func `An immutable owner preserves its value in a detached task`() async {
        let immutable = Ownership.Immutable(99)
        let captured = await Task.detached { () -> Int in
            immutable.value
        }.value
        #expect(captured == 99)
    }
}
