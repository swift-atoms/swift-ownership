extension Ownership.Transfer.Erased {

    @safe
    public struct Incoming: ~Copyable, Sendable {
        internal let _latch: Ownership.Latch<Payload>

        public init() {
            _latch = Ownership.Latch()
        }
    }
}

extension Ownership.Transfer.Erased.Incoming {

    public var token: Token {
        Token(_latch)
    }

    @unsafe
    public consuming func consume<T>(_ type: T.Type) -> T? {
        guard let payload = _latch.take() else { return nil }
        return unsafe payload.consume(type)
    }
}
