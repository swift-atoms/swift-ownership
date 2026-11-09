extension Ownership.Transfer.Erased.Incoming {

    /// Sole owner of a stored erased box: dropping it destroys the payload.
    @safe
    internal struct Payload: ~Copyable, @unchecked Sendable {
        private let _raw: UnsafeMutableRawPointer

        @unsafe
        internal init(_ raw: UnsafeMutableRawPointer) {
            unsafe (_raw = raw)
        }

        deinit {
            unsafe Ownership.Transfer.Erased.Outgoing.destroy(_raw)
        }
    }
}

extension Ownership.Transfer.Erased.Incoming.Payload {

    @unsafe
    internal consuming func consume<T>(_ type: T.Type) -> T {
        let raw = unsafe _raw
        discard self
        return unsafe Ownership.Transfer.Erased.Outgoing.consume(raw)
    }
}
