//
//  ObservableWrapper.swift
//  ObservableWrapperKit
//
//  Created by Loyi Hsu on 2023/11/5.
//

/// An observable container that wraps around an `Equatable`-conforming value.
/// When the value is changed, it would notify all the observations.
///
/// To create a wrapper, you need to provide an initial value:
/// ```swift
/// let wrapper = ObservableWrapper(initialValue: 0)
/// ```
///
/// To get the current value, access the wrapped value getter:
/// ```swift
/// wrapper.wrappedValue    // 0
/// ```
///
/// To change the value inside the wrapper, use the `mutate(action:)` method:
/// ```swift
/// wrapper.mutate {
///     $0 += 1
/// }
/// ```
///
/// When a change is made to the wrapped value, add an observation.
///
/// You can either add an observation as a closure or create your own observation object
/// conforming to ``ObservationProtocol``.
///
/// To add an observation as a closure:
/// ```swift
/// wrapper.addObservation { newValue in
///     print(newValue)
/// }
/// ```
///
/// To add an observation as an object:
/// ```swift
/// wrapper.addObservation(
///     ActionObservation { newValue in
///         print(newValue)
///     }
/// )
/// ```
///
/// `ObservableWrapper` also supports to derive a wrapper using a wriable keypath.
/// This allows you to derive a value inside wrapper's value structure
/// as a new wrapper and writes back changes when changes are made to the new wrapper.
///
/// To derive a new wrapper:
/// ```swift
/// let derivedWrapper = wrapper.derive(keyPath: \.path.to.your.property)
/// ```
///
/// - attention: When an observation is added, it would send an event to the observation
/// for the first time immediately.
/// - attention: Changing nothing inside the value would not trigger the observation.
/// - warning: It is strongly discouraged to use this class with a reference type.
public final class ObservableWrapper<Value: Equatable> {
    // MARK: - Properties

    // MARK: Public API

    /// The current value inside the container.
    public private(set) var wrappedValue: Value {
        willSet {
            // Do not trigger the observations if value doesn't change.
            if wrappedValue != newValue {
                valueWillChange(newValue)
            }
        }
    }

    // MARK: Private

    /// Storage for all the observations that would get notified when a value changed.
    private var observations: [any ObservationProtocol<Value>] = []

    // MARK: - Initialisers

    /// Initialise a wrapper with an initial value.
    /// - parameter initialValue: The value inside the wrapper to start with.
    public init(initialValue wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    // MARK: - Helpers

    // MARK: Public API

    /// Add an observation object.
    /// - attention: When an observation is added, it would send an event
    /// to the observation for the first time immediately.
    public func addObservation(_ observation: any ObservationProtocol<Value>) {
        observations.append(observation)

        // Publish the first event.
        observation.onChange(of: wrappedValue)
    }

    /// Add an observation action as a callback action.
    /// - parameter callback: The callback value that would be called when value changes.
    /// - attention: When an observation is added, it would send an event to
    /// the observation for the first time immediately.
    public func addObservation(callback: @escaping (Value) -> Void) {
        addObservation(ActionObservation(onChangeAction: callback))
    }

    /// Mutate the contained value.
    /// - parameter action: The closure for the changes to be made to the value.
    public func mutate(action: @escaping (inout Value) -> Void) {
        action(&wrappedValue)
    }

    /// Derive a wrapper with a keypath from the current wrapper.
    /// - parameter keyPath: the writable keypath to the property to derive a wrapper from
    /// - returns a new, scoped wrapper to a property of the wrapped value
    public func derive<T: Equatable>(
        keyPath: WritableKeyPath<Value, T>
    ) -> ObservableWrapper<T> {
        let currentValue = wrappedValue[keyPath: keyPath]
        let output = ObservableWrapper<T>(initialValue: currentValue)
        output.addObservation { [weak self] in
            self?.wrappedValue[keyPath: keyPath] = $0
        }
        return output
    }

    // MARK: Private

    /// Notify all the observations the value changed.
    private func valueWillChange(_ newValue: Value) {
        observations.forEach {
            $0.onChange(of: newValue)
        }
    }
}
