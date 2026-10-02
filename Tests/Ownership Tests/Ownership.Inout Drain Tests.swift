import Ownership
import Testing

@Suite
struct `Draining inout backed views reaches an empty state` {
    @Suite struct `Repeated draining through an inout view terminates` {}
    @Suite struct `Draining across a function boundary reaches exhaustion` {}
    @Suite struct `Builder draining terminates for copyable and noncopyable elements` {}
}

extension `Draining inout backed views reaches an empty state` {
    struct Header {
        var head: Int = 0
        var count: Int = 0
    }

    @safe struct Ring<E: ~Copyable>: ~Copyable {
        var header: Header = .init()

        var trips: Int = 0
        let capacity: Int
        let storage: UnsafeMutablePointer<E>

        init(capacity: Int) {
            self.capacity = capacity
            unsafe self.storage = .allocate(capacity: capacity)
        }

        deinit {
            var index = header.head
            for _ in 0..<header.count {
                unsafe (storage + index).deinitialize(count: 1)
                index = (index + 1) % capacity
            }
            unsafe storage.deallocate()
        }
    }

    struct Pop<E: ~Copyable>: ~Copyable, ~Escapable {
        let base: Ownership.Inout<Ring<E>>

        @_transparent
        @_lifetime(&ring)
        init(_ ring: inout Ring<E>) {
            base = Ownership.Inout(mutating: &ring)
        }
    }

    struct Push<E: ~Copyable>: ~Copyable, ~Escapable {
        let base: Ownership.Inout<Ring<E>>

        @_transparent
        @_lifetime(&ring)
        init(_ ring: inout Ring<E>) {
            base = Ownership.Inout(mutating: &ring)
        }
    }

    @resultBuilder
    enum Builder<E: ~Copyable> {}
}

extension `Draining inout backed views reaches an empty state`.Ring where E: ~Copyable {
    typealias Fixture = `Draining inout backed views reaches an empty state`

    var count: Int { header.count }
    var isEmpty: Bool { count == 0 }

    mutating func pushBack(_ element: consuming E) {
        precondition(header.count < capacity)
        let slot = (header.head + header.count) % capacity
        unsafe (storage + slot).initialize(to: element)
        header.count += 1
    }

    mutating func popFront() -> E? {
        guard header.count > 0 else { return nil }
        let element = unsafe (storage + header.head).move()
        header.head = (header.head + 1) % capacity
        header.count -= 1
        return element
    }

    var pop: Fixture.Pop<E> {
        mutating _read { yield Fixture.Pop(&self) }
        mutating _modify {
            var view = Fixture.Pop(&self)
            yield &view
        }
    }

    var push: Fixture.Push<E> {
        mutating _read { yield Fixture.Push(&self) }
        mutating _modify {
            var view = Fixture.Push(&self)
            yield &view
        }
    }

    static func build(@Fixture.Builder<E> _ build: () -> Fixture.Ring<E>) -> Fixture.Ring<E> {
        build()
    }
}

extension `Draining inout backed views reaches an empty state`.Pop where E: ~Copyable {
    mutating func front() -> E? {
        base.value.popFront()
    }
}

extension `Draining inout backed views reaches an empty state`.Push where E: ~Copyable {
    mutating func back(_ element: consuming E) {
        base.value.pushBack(element)
    }
}

extension `Draining inout backed views reaches an empty state`.Builder where E: ~Copyable {
    typealias Ring = `Draining inout backed views reaches an empty state`.Ring<E>

    static func buildExpression(_ expression: consuming E) -> Ring {
        var result = Ring(capacity: 64)
        result.push.back(expression)
        return result
    }

    static func buildPartialBlock(first: consuming Ring) -> Ring {
        first
    }

    static func buildPartialBlock(accumulated: consuming Ring, next: consuming Ring) -> Ring {
        var result = consume accumulated
        var rest = consume next
        var guardCount = 0
        while !rest.isEmpty, guardCount < 16 {
            guardCount += 1
            if let element = rest.pop.front() { result.push.back(element) }
        }
        result.trips = guardCount
        return result
    }
}

extension `Draining inout backed views reaches an empty state`.`Repeated draining through an inout view terminates` {
    typealias Ring = `Draining inout backed views reaches an empty state`.Ring

    @Test
    func `while-not-empty drain through an Inout-backed view terminates`() {
        var ring = Ring<Int>(capacity: 8)
        ring.push.back(1)
        ring.push.back(2)
        ring.push.back(3)
        var popped: [Int] = []
        var guardCount = 0
        while !ring.isEmpty, guardCount < 16 {
            guardCount += 1
            if let element = ring.pop.front() { popped.append(element) }
        }
        #expect(popped == [1, 2, 3])
        #expect(guardCount == 3)
        let empty = ring.isEmpty
        #expect(empty)
    }
}

extension `Draining inout backed views reaches an empty state`.`Draining across a function boundary reaches exhaustion` {
    typealias Ring = `Draining inout backed views reaches an empty state`.Ring

    @Test
    func `drain across a non-inlined boundary terminates`() {
        var ring = Ring<Int>(capacity: 4)
        ring.push.back(10)
        ring.push.back(20)
        let popped = Self.drain(&ring)
        #expect(popped == [10, 20])
        let empty = ring.isEmpty
        #expect(empty)
    }

    @inline(never)
    static func drain(_ ring: inout Ring<Int>) -> [Int] {
        var popped: [Int] = []
        var guardCount = 0
        while !ring.isEmpty, guardCount < 16 {
            guardCount += 1
            if let element = ring.pop.front() { popped.append(element) }
        }
        return popped
    }
}

extension `Draining inout backed views reaches an empty state`.`Builder draining terminates for copyable and noncopyable elements` {
    typealias Ring = `Draining inout backed views reaches an empty state`.Ring

    @Test
    func `builder drain terminates (Copyable element)`() {
        let ring = Ring<Int>.build {
            1
            2
        }
        let count = ring.count
        let trips = ring.trips
        #expect(count == 2)
        #expect(trips == 1)
    }

    @Test
    func `builder drain terminates (~Copyable element)`() {
        struct Token: ~Copyable {
            let id: Int
        }
        let ring = Ring<Token>.build {
            Token(id: 1)
            Token(id: 2)
            Token(id: 3)
        }
        let count = ring.count
        let trips = ring.trips
        #expect(count == 3)
        #expect(trips == 1)
    }
}
