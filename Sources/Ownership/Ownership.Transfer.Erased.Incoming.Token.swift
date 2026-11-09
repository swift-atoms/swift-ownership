extension Ownership.Transfer.Erased.Incoming {

    @safe
    public struct Token: Sendable {
        internal let _latch: Ownership.Latch<Ownership.Transfer.Erased.Incoming.Payload>

        internal init(_ latch: Ownership.Latch<Ownership.Transfer.Erased.Incoming.Payload>) {
            self._latch = latch
        }
    }
}

extension Ownership.Transfer.Erased.Incoming.Token {

    @unsafe
    public func store(_ raw: sending UnsafeMutableRawPointer) {
        unsafe _latch.store(Ownership.Transfer.Erased.Incoming.Payload(raw))
    }
}
