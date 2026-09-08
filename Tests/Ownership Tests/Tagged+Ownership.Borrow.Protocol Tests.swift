import Ownership
import Tagged
import Testing

@Suite
struct `Tagged values forward borrowed ownership access` {
    @Suite struct `Tagged borrowed ownership preserves the underlying borrowed value` {}
    @Suite struct `No tagged borrowed ownership boundary cases are defined` {}
    @Suite struct `No tagged borrowed ownership integration cases are defined` {}
}

private enum Phantom {}

extension `Tagged values forward borrowed ownership access`.`Tagged borrowed ownership preserves the underlying borrowed value` {
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
