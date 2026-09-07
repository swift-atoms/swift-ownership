import Ownership
import Tagged
import Testing

@Suite
struct `Tagged+Ownership.Borrow.Protocol Tests` {
    @Suite struct `Unit behavior` {}
    @Suite struct `Edge Case` {}
    @Suite struct `Integration behavior` {}
}

private enum Phantom {}

extension `Tagged+Ownership.Borrow.Protocol Tests`.`Unit behavior` {
    @Test
    func `Tagged conforms to Ownership Borrow Protocol when Underlying does`() {

        struct Resource: ~Copyable, Ownership.Borrow.`Protocol` {

            typealias Borrowed = Ownership.Borrow<Self>
        }
        func _requireBorrowProtocol<T: Ownership.Borrow.`Protocol` & ~Copyable>(_: T.Type) {}
        _requireBorrowProtocol(Tagged<Phantom, Resource>.self)
        #expect(Bool(true))
    }
}
