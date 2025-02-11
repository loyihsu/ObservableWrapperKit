# ObservableWrapperKit

A Swift observable wrapper that offers state observation capabilities. The observable wrapper simplifies the process of wrapping an object within an `ObservableWrapper` container, enabling you to monitor changes in its state.

## Installation

This package is available as a Swift Package.

```swift
// ... your Package.swift
dependencies: [
    .package(url: "https://github.com/loyihsu/ObservableWrapperKit", branch: "main"),
],
```

## Getting Started

### Initialization

Create a new instance of the `ObservableWrapper` by initializing it with an initial value:

```swift
let wrapper = ObservableWrapper(initialValue: 0)
```

### Observing Changes

You can observe changes to the wrapped value using observers:

```swift
wrapper.addObservation { newValue in
    print("New value: \(newValue)")
}
```

### Mutating Observables

Modify the wrapped state by mutating it.

```swift
wrapper.mutate {
    $0 += 1
}
```

## Notes

* This package internally employs parameterized protocol types, which necessitates a minimum deployment target of macOS 13 and iOS 16 for the target application.
