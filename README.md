
## Module organization

Import `Ownership` to use the core API, including the protocols and operations formerly supplied by separate modules. It re-exports `Tagged` and `Synchronization`. Dependency exports live in `Sources/Ownership/exports.swift`.

`Ownership Test Support` lives in `Tests/Support`. Foundation integration can be added as `Ownership Foundation Library Integration` when needed.
