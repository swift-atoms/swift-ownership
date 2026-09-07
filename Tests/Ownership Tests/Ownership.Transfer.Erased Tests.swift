import Ownership
import Testing

@Suite
struct `Ownership Transfer Erased Tests` {
    @Suite struct Outgoing {}
    @Suite struct Incoming {}
}

extension `Ownership Transfer Erased Tests`.Outgoing {
    @Test
    func `make then consume round-trips a struct payload`() {
        struct Payload: Equatable {
            var a: Int
            var b: Int
        }
        let raw = unsafe Ownership.Transfer.Erased.Outgoing.make(Payload(a: 3, b: 4))
        let payload: Payload = unsafe Ownership.Transfer.Erased.Outgoing.consume(raw)
        #expect(payload == Payload(a: 3, b: 4))
    }

    @Test
    func `destroy runs the payload destructor and deallocates`() {
        final class Sentinel {}
        weak var probe: Sentinel?
        do {
            let sentinel = Sentinel()
            probe = sentinel
            let raw = unsafe Ownership.Transfer.Erased.Outgoing.make(sentinel)
            unsafe Ownership.Transfer.Erased.Outgoing.destroy(raw)
        }

        #expect(probe == nil)
    }
}

extension `Ownership Transfer Erased Tests`.Incoming {
    @Test
    func `token.store then consume round-trips a boxed struct`() {
        struct Payload: Equatable {
            var a: Int
            var b: Int
        }
        let incoming = Ownership.Transfer.Erased.Incoming()
        let token = incoming.token
        let raw = unsafe Ownership.Transfer.Erased.Outgoing.make(Payload(a: 1, b: 2))
        unsafe token.store(raw)
        let payload: Payload? = unsafe incoming.consume(Payload.self)
        #expect(payload == Payload(a: 1, b: 2))
    }

    @Test
    func `consume() returns nil on an empty slot`() {
        let incoming = Ownership.Transfer.Erased.Incoming()
        let value: Int? = unsafe incoming.consume(Int.self)
        #expect(value == nil)
    }
}
