import Ownership
import Testing

@Suite
struct `Mutable owners share direct access to their stored value` {
    @Suite struct `Mutable owner aliases observe the same stored mutations` {}
    @Suite struct `Mutable owners borrow and modify noncopyable payloads` {}
    @Suite struct `Unchecked mutable wrappers permit explicit transfer across tasks` {}
}

extension `Mutable owners share direct access to their stored value`.`Mutable owner aliases observe the same stored mutations` {
    @Test
    func `init(_:) stores the value`() {
        let mutable = Ownership.Mutable(42)
        #expect(mutable.value == 42)
    }

    @Test
    func `value accessor supports direct mutation`() {
        let mutable = Ownership.Mutable(0)
        mutable.value = 100
        #expect(mutable.value == 100)
    }

    @Test
    func `Mutable owner aliases observe each other through shared storage`() {
        let mutable = Ownership.Mutable(0)
        let alias = mutable
        alias.value = 50
        #expect(mutable.value == 50)
    }

    @Test
    func `value accessor supports read + transform`() {
        let mutable = Ownership.Mutable(7)
        let read = mutable.value + 1
        #expect(read == 8)
        #expect(mutable.value == 7)
    }

    @Test
    func `value accessor supports in-place mutation`() {
        let mutable = Ownership.Mutable(0)
        mutable.value = 99
        #expect(mutable.value == 99)
    }
}

extension `Mutable owners share direct access to their stored value`.`Mutable owners borrow and modify noncopyable payloads` {
    @Test
    func `A mutable owner borrows its noncopyable payload for reading`() {
        struct Handle: ~Copyable { let fd: Int32 }
        let mutable = Ownership.Mutable(Handle(fd: 3))

        #expect(mutable.value.fd == 3)
    }

    @Test
    func `A mutable owner updates its noncopyable payload in place`() {
        struct Counter: ~Copyable { var count: Int }
        let mutable = Ownership.Mutable(Counter(count: 0))
        mutable.value.count += 5
        #expect(mutable.value.count == 5)
    }
}

extension `Mutable owners share direct access to their stored value`.`Unchecked mutable wrappers permit explicit transfer across tasks` {
    @Test
    func `Unchecked opt-in wraps a Mutable and passes across Sendable`() async {
        let unchecked = Ownership.Mutable<Int>.Unchecked(0)
        unchecked.mutable.value = 42

        let read = await Task.detached { () -> Int in
            unchecked.mutable.value
        }.value
        #expect(read == 42)
    }
}
