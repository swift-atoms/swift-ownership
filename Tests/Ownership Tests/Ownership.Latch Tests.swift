import Ownership
import Testing
import Synchronization

@Suite
struct `Ownership Latch Tests` {
    @Suite struct `Unit behavior` {}
    @Suite struct `Edge Case` {}
    @Suite struct `Integration behavior` {}
}

extension `Ownership Latch Tests`.`Unit behavior` {
    @Test
    func `init() creates an empty latch`() {
        let latch = Ownership.Latch<Int>()
        #expect(!latch.hasValue)
    }

    @Test
    func `init(_:) creates a full latch`() {
        let latch = Ownership.Latch<Int>(42)
        #expect(latch.hasValue)
    }

    @Test
    func `store(_:) publishes the value`() {
        let latch = Ownership.Latch<Int>()
        latch.store(42)
        #expect(latch.hasValue)
    }

    @Test
    func `take() returns the stored value and empties the latch`() {
        let latch = Ownership.Latch<Int>(17)
        let taken = latch.take()
        #expect(taken == 17)
        #expect(!latch.hasValue)
    }

    @Test
    func `take() returns nil on an empty latch`() {
        let latch = Ownership.Latch<Int>()
        #expect(latch.take() == nil)
    }
}

extension `Ownership Latch Tests`.`Edge Case` {
    @Test
    func `take() after take() returns nil`() {
        let latch = Ownership.Latch<Int>(3)
        #expect(latch.take() == 3)
        #expect(latch.take() == nil)
    }

    @Test
    func `store then take round-trips a struct Value`() {
        struct Payload: Equatable {
            var a: Int
            var b: Int
        }
        let latch = Ownership.Latch<Payload>()
        latch.store(Payload(a: 1, b: 2))
        #expect(latch.take() == Payload(a: 1, b: 2))
    }

    @Test
    func `hasValue is false for a fresh empty latch`() {
        let latch = Ownership.Latch<String>()
        #expect(!latch.hasValue)
    }

    @Test
    func `hasValue is true only until take() consumes the value`() {
        let latch = Ownership.Latch<String>("payload")
        #expect(latch.hasValue)
        _ = latch.take()
        #expect(!latch.hasValue)
    }
}

extension `Ownership Latch Tests`.`Integration behavior` {
    @Test
    func `latch carries a class reference identity across take`() {
        final class Marker: Sendable {
            let tag: Int
            init(_ tag: Int) { self.tag = tag }
        }
        let original = Marker(7)
        let latch = Ownership.Latch<Marker>(original)
        let received = latch.take()
        #expect(received === original)
    }

    @Test
    func `latch works with ~Copyable Value`() {
        struct Handle: ~Copyable { let fd: Int32 }
        let latch = Ownership.Latch<Handle>()
        #expect(!latch.hasValue)
        latch.store(Handle(fd: 11))
        #expect(latch.hasValue)
        guard let handle = latch.take() else {
            Issue.record("expected take() to return .some after store()")
            return
        }
        #expect(handle.fd == 11)
        #expect(!latch.hasValue)
    }

    @Test
    func `shared latch delivers to a single consumer across captures`() {
        let latch = Ownership.Latch<Int>()

        let alias = latch
        latch.store(123)
        #expect(alias.hasValue)
        #expect(alias.take() == 123)
        #expect(!latch.hasValue)
    }
}

private final class LatchDestructions: Sendable {
    let count = Mutex(0)
}

@Suite
struct `Latch transfer and finalization` {
    @Test
    func `initialization transfers a disconnected mutable object to another task`() async {
        final class Payload {
            var value: Int
            init(_ value: Int) { self.value = value }
        }
        let payload = Payload(41)
        let identity = ObjectIdentifier(payload)
        let latch = Ownership.Latch(payload)
        let result = await Task.detached {
            guard let received = latch.take() else { return false }
            received.value += 1
            return ObjectIdentifier(received) == identity && received.value == 42
        }.value
        #expect(result)
        #expect(!latch.hasValue)
    }

    @Test
    func `concurrent takers receive a noncopyable payload exactly once`() async {
        struct Payload: ~Copyable { let value: Int }
        let latch = Ownership.Latch(Payload(value: 42))
        let values = await withTaskGroup(of: Int?.self) { group in
            for _ in 0..<64 {
                group.addTask {
                    guard let received = latch.take() else { return nil }
                    return received.value
                }
            }
            var result: [Int] = []
            for await value in group {
                if let value { result.append(value) }
            }
            return result
        }
        #expect(values == [42])
        #expect(!latch.hasValue)
    }

    @Test
    func `dropping a full latch destroys its noncopyable payload exactly once`() {
        let destructions = LatchDestructions()
        struct Payload: ~Copyable {
            let destructions: LatchDestructions
            deinit { destructions.count.withLock { $0 += 1 } }
        }
        do {
            let latch = Ownership.Latch(Payload(destructions: destructions))
            #expect(latch.hasValue)
            #expect(destructions.count.withLock { $0 } == 0)
        }
        #expect(destructions.count.withLock { $0 } == 1)
    }

    @Test
    func `taking a payload makes its recipient responsible for destruction`() {
        let destructions = LatchDestructions()
        struct Payload: ~Copyable {
            let destructions: LatchDestructions
            deinit { destructions.count.withLock { $0 += 1 } }
        }
        let latch = Ownership.Latch(Payload(destructions: destructions))
        do {
            guard let payload = latch.take() else {
                Issue.record("Expected the initialized payload")
                return
            }
            #expect(!latch.hasValue)
            #expect(destructions.count.withLock { $0 } == 0)
            _ = consume payload
        }
        #expect(destructions.count.withLock { $0 } == 1)
    }

    @Test
    func `storing after consumption fails instead of republishing a value`() async {
        await #expect(processExitsWith: .failure) {
            let latch = Ownership.Latch(1)
            _ = latch.take()
            latch.store(2)
        }
    }
}
