import Ownership
import Testing

@Suite

struct `Transfer wrappers preserve payloads reference identity and release behavior` {
    @Suite struct `Outgoing value tokens expose the stored payload through copyable handles` {}
    @Suite struct `Incoming value tokens store payloads for optional consumption` {}
    @Suite struct `Outgoing retained transfers preserve object identity and release abandoned references` {}
    @Suite struct `Incoming retained transfers preserve object identity through optional consumption` {}
    @Suite struct `Composed incoming and outgoing transfers preserve channel payloads and identity` {}
}

extension `Transfer wrappers preserve payloads reference identity and release behavior`.`Outgoing value tokens expose the stored payload through copyable handles` {
    @Test
    func `token take() retrieves the stored value`() {
        let outgoing = Ownership.Transfer.Value<Int>.Outgoing(42)
        let token = outgoing.token()
        #expect(token.take() == 42)
    }

    @Test
    func `token is Copyable — can be captured by multiple closures`() {
        let outgoing = Ownership.Transfer.Value<Int>.Outgoing(10)
        let token = outgoing.token()
        let captureA: () -> Void = { _ = token }
        let captureB: () -> Void = { _ = token }
        captureA()
        captureB()
        #expect(token.take() == 10)
    }

    @Test
    func `An outgoing value token preserves its struct payload`() {
        struct Payload: Equatable {
            var a: Int
            var b: Int
        }
        let outgoing = Ownership.Transfer.Value<Payload>.Outgoing(Payload(a: 1, b: 2))
        let token = outgoing.token()
        #expect(token.take() == Payload(a: 1, b: 2))
    }
}

extension `Transfer wrappers preserve payloads reference identity and release behavior`.`Incoming value tokens store payloads for optional consumption` {
    @Test
    func `token.store(_) then consume() round-trips`() {
        let incoming = Ownership.Transfer.Value<Int>.Incoming()
        incoming.token.store(77)
        #expect(incoming.consume() == 77)
    }

    @Test
    func `token is Copyable`() {
        let incoming = Ownership.Transfer.Value<Int>.Incoming()
        let token = incoming.token
        let _: () -> Void = { _ = token }
        token.store(99)
        #expect(incoming.consume() == 99)
    }

    @Test
    func `consume() returns nil on an empty slot`() {
        let incoming = Ownership.Transfer.Value<Int>.Incoming()
        #expect(incoming.consume() == nil)
    }
}

extension `Transfer wrappers preserve payloads reference identity and release behavior`.`Outgoing retained transfers preserve object identity and release abandoned references` {
    @Test
    func `consume() returns the strong reference`() {
        final class Node {
            let id: Int
            init(_ id: Int) { self.id = id }
        }
        let node = Node(5)
        let outgoing = unsafe Ownership.Transfer.Retained<Node>.Outgoing(node)
        let taken = outgoing.consume()
        #expect(taken.id == 5)
    }

    @Test
    func `An outgoing retained transfer preserves object identity`() {
        final class Marker {
            let tag: Int
            init(_ tag: Int) { self.tag = tag }
        }
        let marker = Marker(1)
        let outgoing = unsafe Ownership.Transfer.Retained<Marker>.Outgoing(marker)
        let received = outgoing.consume()
        #expect(received === marker)
    }

    @Test
    func `abandoned Outgoing releases the retain (no leak)`() {
        final class Probe { init() {} }
        weak var weakProbe: Probe?
        do {
            let probe = Probe()
            weakProbe = probe

            unsafe (_ = Ownership.Transfer.Retained<Probe>.Outgoing(probe))
        }
        #expect(weakProbe == nil, "Outgoing dropped without consume must release the retain")
    }
}

extension `Transfer wrappers preserve payloads reference identity and release behavior`.`Incoming retained transfers preserve object identity through optional consumption` {
    @Test
    func `token.store then consume round-trips an object`() {
        final class Service {
            let id: Int
            init(_ id: Int) { self.id = id }
        }
        let incoming = Ownership.Transfer.Retained<Service>.Incoming()
        let token = incoming.token
        token.store(Service(42))
        let received = incoming.consume()
        #expect(received?.id == 42)
    }

    @Test
    func `consume() returns nil on an empty slot`() {
        final class Service { init() {} }
        let incoming = Ownership.Transfer.Retained<Service>.Incoming()
        #expect(incoming.consume() == nil)
    }

    @Test
    func `An incoming retained transfer preserves object identity`() {
        final class Marker {
            let tag: Int
            init(_ tag: Int) { self.tag = tag }
        }
        let marker = Marker(7)
        let markerID = ObjectIdentifier(marker)
        let incoming = Ownership.Transfer.Retained<Marker>.Incoming()

        incoming.token.store(marker)
        let received = incoming.consume()
        #expect(received.map(ObjectIdentifier.init) == markerID)
    }
}

extension `Transfer wrappers preserve payloads reference identity and release behavior`.`Composed incoming and outgoing transfers preserve channel payloads and identity` {
    @Test
    func `Outgoing + Incoming together model a bidirectional channel`() {
        let request = Ownership.Transfer.Value<Int>.Outgoing(42)
        let reply = Ownership.Transfer.Value<Int>.Incoming()

        let requestToken = request.token()
        let replyToken = reply.token
        let received = requestToken.take()
        replyToken.store(received * 2)

        #expect(reply.consume() == 84)
    }

    @Test
    func `Retained.Incoming roundtrip preserves identity across threadless hand-off`() {
        final class Service {
            let id: Int
            init(_ id: Int) { self.id = id }
        }
        let incoming = Ownership.Transfer.Retained<Service>.Incoming()
        let producerToken = incoming.token
        let expected = Service(1)
        let expectedID = ObjectIdentifier(expected)

        producerToken.store(expected)
        let got = incoming.consume()
        #expect(got.map(ObjectIdentifier.init) == expectedID)
    }
}
