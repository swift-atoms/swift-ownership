import Ownership
import Testing

@Suite
struct `Ownership boxes preserve value semantics through shared storage` {
    @Suite struct `Ownership box construction mutation and cloning preserve stored values` {}
    @Suite struct `Mutating shared ownership boxes separates their values and storage identities` {}
    @Suite struct `Nested boxes and explicit cloning preserve independent value semantics` {}
    @Suite struct `Ownership boxes share noncopyable payloads and destroy them exactly once` {}
}

extension `Ownership boxes preserve value semantics through shared storage`.`Ownership box construction mutation and cloning preserve stored values` {
    @Test
    func `init(_:) stores the value`() {
        let box = Ownership.Box<Int>(42)
        #expect(box.value == 42)
    }

    @Test
    func `value _modify mutates through exclusive access`() {
        var box = Ownership.Box<Int>(10)
        box.value += 1
        #expect(box.value == 11)
    }

    @Test
    func `clone() produces an independent cell`() {
        let original = Ownership.Box<Int>(7)
        var copy = original.clone()
        copy.value = 99
        #expect(original.value == 7)
        #expect(copy.value == 99)
    }

    @Test
    func `isUnique is true for an unshared cell`() {
        var box = Ownership.Box<Int>(1)
        let unique = box.isUnique
        #expect(unique)
    }

    @Test
    func `sharing makes the cell non-unique until mutation restores it`() {
        var a = Ownership.Box<[Int]>([1, 2, 3])
        var b = a
        let sharedA = a.isUnique
        #expect(!sharedA)
        b.value.append(4)
        let uniqueA = a.isUnique
        let uniqueB = b.isUnique
        #expect(uniqueA)
        #expect(uniqueB)
    }
}

extension `Ownership boxes preserve value semantics through shared storage`.`Mutating shared ownership boxes separates their values and storage identities` {
    @Test
    func `shared cell CoW — mutation on copy leaves original untouched`() {
        let a = Ownership.Box<[Int]>([1, 2, 3])
        var b = a
        b.value.append(4)
        #expect(a.value == [1, 2, 3])
        #expect(b.value == [1, 2, 3, 4])
    }

    @Test
    func `cloning an unshared cell produces a distinct cell`() {
        let a = Ownership.Box<String>("payload")
        var b = a.clone()
        b.value = "mutated"
        #expect(a.value == "payload")
        #expect(b.value == "mutated")
    }

    @Test
    func `Mutating either shared box leaves the other stored value unchanged`() {
        var a = Ownership.Box<Int>(0)
        var b = a
        a.value = 5
        #expect(a.value == 5)
        #expect(b.value == 0)
        b.value = 9
        #expect(a.value == 5)
        #expect(b.value == 9)
    }

    @Test
    func `backing identity diverges on copy-on-write`() {
        let a = Ownership.Box<[Int]>([1])
        let identityA = a.identity
        var b = a
        #expect(b.identity == identityA)
        b.value.append(2)
        #expect(b.identity != identityA)
        #expect(a.identity == identityA)
    }
}

extension `Ownership boxes preserve value semantics through shared storage`.`Nested boxes and explicit cloning preserve independent value semantics` {
    @Test
    func `struct Value round-trips through CoW`() {
        struct Pair: Equatable {
            var a: Int
            var b: Int
        }
        let x = Ownership.Box<Pair>(Pair(a: 1, b: 2))
        var y = x
        y.value.a = 99
        #expect(x.value == Pair(a: 1, b: 2))
        #expect(y.value == Pair(a: 99, b: 2))
    }

    @Test
    func `nested Box preserves value semantics at both levels`() {
        let outer = Ownership.Box<Ownership.Box<Int>>(Ownership.Box<Int>(1))
        var sibling = outer
        sibling.value.value = 42
        #expect(outer.value.value == 1)
        #expect(sibling.value.value == 42)
    }

    @Test
    func `clone() of a shared cell detaches without a prior mutation`() {
        let a = Ownership.Box<Int>(8)
        let _ = a
        let b = a.clone()
        #expect(a.value == 8)
        #expect(b.value == 8)
    }

    @Test
    func `explicit clone witness drives copy-on-write through the gate`() {
        final class Cell {
            var n: Int
            init(_ n: Int) { self.n = n }
        }

        let a = Ownership.Box<Cell>(
            Cell(1),
            drain: { _ in },
            clone: { Cell($0.n) }
        )
        var b = a
        b.ensureUnique()
        b.value.n = 99
        #expect(a.value.n == 1)
        #expect(b.value.n == 99)
    }

    @Test
    func `unguarded mutates in place after the gate`() {
        var a = Ownership.Box<[Int]>([1, 2])
        let copied = a.ensureUnique()
        #expect(!copied)
        unsafe a.unguarded.append(3)
        #expect(a.value == [1, 2, 3])
    }
}

extension `Ownership boxes preserve value semantics through shared storage`.`Ownership boxes share noncopyable payloads and destroy them exactly once` {
    final class Recorder {
        var destroyed = 0
    }

    struct Token: ~Copyable {
        let recorder: Recorder
        init(_ recorder: Recorder) { self.recorder = recorder }
        deinit { recorder.destroyed += 1 }
    }

    @Test
    func `a ~Copyable payload is held and torn down exactly once`() {
        let recorder = Recorder()
        do {

            var box = Ownership.Box<Token>(Token(recorder), drain: { _ in }, clone: nil)
            let unique = box.isUnique
            #expect(unique)
            #expect(recorder.destroyed == 0)
        }
        #expect(recorder.destroyed == 1)
    }

    @Test
    func `a ~Copyable payload survives a consuming move into the cell`() {
        let recorder = Recorder()
        let token = Token(recorder)
        do {
            let box = Ownership.Box<Token>(token, drain: { _ in }, clone: nil)
            _ = box
            #expect(recorder.destroyed == 0)
        }
        #expect(recorder.destroyed == 1)
    }

    @Test
    func `copying the cell shares the ~Copyable payload by reference, torn down once`() {
        let recorder = Recorder()
        do {
            var a = Ownership.Box<Token>(Token(recorder), drain: { _ in }, clone: nil)
            let identityA = a.identity
            let b = a
            let sharedA = a.isUnique
            #expect(!sharedA)
            #expect(b.identity == identityA)
            #expect(recorder.destroyed == 0)
        }
        #expect(recorder.destroyed == 1)
    }
}

@Suite
struct `Sendable box copies detach before concurrent mutation` {
    @Test
    func `sendable copies detach before concurrent mutation`() async {
        let original = Ownership.Box<[Int]>([0])
        let results = await withTaskGroup(of: [Int].self) { group in
            for value in 1...32 {
                group.addTask {
                    var local = original
                    local.value.append(value)
                    return local.value
                }
            }
            var values: [[Int]] = []
            for await value in group { values.append(value) }
            return values
        }
        #expect(original.value == [0])
        #expect(results.count == 32)
        #expect(Set(results) == Set((1...32).map { [0, $0] }))
    }
}
