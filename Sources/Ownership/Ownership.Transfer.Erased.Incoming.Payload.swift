extension Ownership.Transfer.Erased.Incoming {

    /// Sole owner of a stored erased box: dropping it destroys the payload.
    @safe
    internal struct Payload: ~Copyable {
        private var _raw: UnsafeMutableRawPointer?

        @unsafe
        internal init(_ raw: UnsafeMutableRawPointer) {
            unsafe (_raw = raw)
        }

        deinit {
            if let raw = unsafe _raw {
                unsafe Ownership.Transfer.Erased.Outgoing.destroy(raw)
            }
        }
    }
}

extension Ownership.Transfer.Erased.Incoming.Payload {

    @unsafe
    internal consuming func consume<T>(_ type: T.Type) -> T {
        guard let raw = unsafe _raw else {
            preconditionFailure("Ownership.Transfer.Erased.Incoming.Payload: consumed without a stored box")
        }
        unsafe (_raw = nil)
        return unsafe Ownership.Transfer.Erased.Outgoing.consume(raw)
    }
}
