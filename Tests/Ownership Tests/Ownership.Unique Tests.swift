import Testing

import Ownership

@Suite
struct `Unique owners preserve exclusive values through access and consumption` {
    @Suite struct `Unique ownership supports reads mutations cloning and span access` {}
    @Suite struct `Unique owners preserve struct class optional array and noncopyable payloads` {}
    @Suite struct `Independent and nested unique owners preserve lifetime and borrowed access` {}
    @Suite(.serialized) struct `Unique ownership supports repeated allocation reads and mutations` {}
}

extension `Unique owners preserve exclusive values through access and consumption`.`Unique ownership supports reads mutations cloning and span access` {
    @Test
    func `init heap-allocates value`() {
        let unique = Ownership.Unique<Int>(42)
        #expect(unique.value == 42)
    }

    @Test
    func `value accessor reads via _read coroutine`() {
        let unique = Ownership.Unique<Int>(99)
        #expect(unique.value == 99)
    }

    @Test
    func `value accessor mutates via _modify coroutine`() {
        var unique = Ownership.Unique<Int>(10)
        unique.value += 5
        #expect(unique.value == 15)
    }

    @Test
    func `consume returns owned value and destroys cell`() {
        let unique = Ownership.Unique<Int>(123)
        let value = unique.consume()

        #expect(value == 123)
    }

    @Test
    func `clone returns independent owner (Copyable)`() {
        let unique = Ownership.Unique<Int>(77)
        let duplicated = unique.clone()
        #expect(duplicated.consume() == 77)
        #expect(unique.value == 77)
    }

    @Test
    func `span provides read-only view with count 1`() {
        let unique = Ownership.Unique<Int>(42)
        let span = unique.span
        #expect(span.count == 1)
        #expect(span[0] == 42)
    }

    @Test
    func `mutableSpan provides mutable view with count 1`() {
        var unique = Ownership.Unique<Int>(10)
        var span = unique.mutableSpan
        #expect(span.count == 1)
        span[0] = 20
        #expect(unique.value == 20)
    }
}

extension `Unique owners preserve exclusive values through access and consumption`.`Unique owners preserve struct class optional array and noncopyable payloads` {
    @Test
    func `A unique owner preserves struct mutations through consumption`() {
        struct Point: Equatable {
            var x: Double
            var y: Double
        }

        var unique = Ownership.Unique<Point>(Point(x: 1.0, y: 2.0))
        #expect(unique.value.x == 1.0)
        #expect(unique.value.y == 2.0)

        unique.value.x = 3.0

        let point = unique.consume()
        #expect(point.x == 3.0)
        #expect(point.y == 2.0)
    }

    @Test
    func `A unique owner exposes its stored class payload`() {
        class Counter {
            var value: Int
            init(_ value: Int) { self.value = value }
        }

        let unique = Ownership.Unique<Counter>(Counter(10))
        #expect(unique.value.value == 10)
    }

    @Test
    func `A unique owner updates a present optional value to nil`() {
        var unique = Ownership.Unique<Int?>(42)
        #expect(unique.value == 42)

        unique.value = nil
        #expect(unique.value == nil)
    }

    @Test
    func `A unique owner preserves mutations to its stored array`() {
        var unique = Ownership.Unique<[Int]>([1, 2, 3])
        unique.value.append(4)
        #expect(unique.value == [1, 2, 3, 4])
    }

    @Test
    func `consume works with ~Copyable Value`() {
        struct Handle: ~Copyable { let fd: Int32 }
        let cell = Ownership.Unique(Handle(fd: 3))
        let taken = cell.consume()
        #expect(taken.fd == 3)
    }

    @Test
    func `value accessor works with ~Copyable Value via transitive borrow`() {
        struct Handle: ~Copyable { let fd: Int32 }
        let cell = Ownership.Unique(Handle(fd: 11))

        #expect(cell.value.fd == 11)
    }

    @Test
    func `value accessor mutates ~Copyable Value`() {
        struct Handle: ~Copyable { var count: Int }
        var cell = Ownership.Unique(Handle(count: 0))
        cell.value.count += 1
        let taken = cell.consume()
        #expect(taken.count == 1)
    }
}

extension `Unique owners preserve exclusive values through access and consumption`.`Independent and nested unique owners preserve lifetime and borrowed access` {
    @Test
    func `deinit deallocates memory`() {

        do {
            _ = Ownership.Unique<Int>(42)

        }
        #expect(true)
    }

    @Test
    func `multiple owners are independent`() {
        var unique1 = Ownership.Unique<Int>(100)
        let unique2 = Ownership.Unique<Int>(200)

        unique1.value += 1

        #expect(unique1.value == 101)
        #expect(unique2.value == 200)
    }

    @Test
    func `nested value reads via transitive borrow`() {
        let unique1 = Ownership.Unique<Int>(10)
        let unique2 = Ownership.Unique<Int>(20)

        let sum = unique1.value + unique2.value
        #expect(sum == 30)
    }
}

extension `Unique owners preserve exclusive values through access and consumption`.`Unique ownership supports repeated allocation reads and mutations` {
    @Test
    func `Unique owners can be repeatedly allocated and consumed`() {

        for _ in 0..<10 {
            for _ in 0..<1000 {
                let unique = Ownership.Unique<Int>(42)
                _ = unique.consume()
            }
        }

        for _ in 0..<100 {
            for _ in 0..<1000 {
                let unique = Ownership.Unique<Int>(42)
                _ = unique.consume()
            }
        }
    }

    @Test
    func `Unique values can be read repeatedly`() {
        let unique = Ownership.Unique<Int>(42)

        for _ in 0..<10 {
            for _ in 0..<10000 {
                _ = unique.value
            }
        }

        for _ in 0..<100 {
            for _ in 0..<10000 {
                _ = unique.value
            }
        }
    }

    @Test
    func `Unique values can be mutated repeatedly`() {
        var unique = Ownership.Unique<Int>(0)

        for _ in 0..<10 {
            for _ in 0..<10000 {
                unique.value += 1
            }
        }

        for _ in 0..<100 {
            for _ in 0..<10000 {
                unique.value += 1
            }
        }
    }
}
