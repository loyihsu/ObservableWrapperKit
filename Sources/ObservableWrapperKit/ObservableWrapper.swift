//
//  ObservableWrapper.swift
//  ObservableWrapperKit
//
//  Created by Loyi Hsu on 2023/11/5.
//

/// An observable container that wraps around an `Equatable`-conforming value.
/// When the value is changed, it would notify the observations.
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
/// When adding an observation, you can set the `removeDuplicates` signal
/// to prevent unchanging states to trigger specific observations.
///
/// ```swift
/// wrapper.addObservation(removeDuplicates: true) { newValue in
///     print(newValue)
/// }
/// ```
///
/// ```swift
/// wrapper.addObservation(
///     ActionObservation(removeDuplicates: true) { newValue in
///         print(newValue)
///     }
/// )
/// ```
///
/// When you create an observation, an `ObservationIdentifier` would be returned.
/// It can be used to remove observation from the wrapper you start your observation with.
///
/// ```swift
/// let id = wrapper.addObservation {
///     print($0)
/// }
///
/// wrapper.removeObservation(id)
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
/// - warning: It is strongly discouraged to use this class with a reference type.
public final class ObservableWrapper<Value: Equatable> {
    // MARK: - Properties

    // MARK: Public API

    /// The current value inside the container.
    public private(set) var wrappedValue: Value {
        willSet {
            self.valueWillChange(newValue, isDuplicate: self.wrappedValue == newValue)
        }
    }

    // MARK: Private

    /// Storage for all the observations that would get notified when a value changed.
    private var observations: [ObservationIdentifier: any ObservationProtocol<Value>] = [:]

    /// Prevent repeated triggering.
    private var shouldTriggerObservations = true

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
    @discardableResult
    public func addObservation(
        _ observation: any ObservationProtocol<Value>
    ) -> ObservationIdentifier {
        let identifier = ObservationIdentifier()
        self.observations[identifier] = observation

        // Publish the first event.
        observation.onChange(of: self.wrappedValue)

        return identifier
    }

    /// Add an observation action as a callback action.
    /// - parameter removeDuplicates: When set to true, it does not trigger the observations if value doesn't change. (default: `false`)
    /// - parameter callback: The callback value that would be called when value changes.
    /// - attention: When an observation is added, it would send an event to
    /// the observation for the first time immediately.
    @discardableResult
    public func addObservation(
        removeDuplicates: Bool = false,
        callback: @escaping (Value) -> Void
    ) -> ObservationIdentifier {
        self.addObservation(
            ActionObservation(
                removeDuplicates: removeDuplicates,
                onChangeAction: callback
            )
        )
    }

    /// Remove an observation with the identifier.
    public func removeObservation(_ identifier: ObservationIdentifier) {
        self.observations[identifier] = nil
    }

    /// Mutate the contained value.
    /// - parameter action: The closure for the changes to be made to the value.
    public func mutate(action: @escaping (inout Value) -> Void) {
        action(&self.wrappedValue)
    }

    /// Change the type of the wrapped value.
    /// - parameter handler: the handler to conform value to another type
    /// - returns a new, converted `ObservableWrapper` that would get notified when parent value changed
    public func map<T>(_ handler: @escaping (Value) -> T) -> ObservableWrapper<T> {
        let updatedValue = handler(wrappedValue)
        let output = ObservableWrapper<T>(initialValue: updatedValue)
        self.addObservation { changedValue in
            output.mutate {
                $0 = handler(changedValue)
            }
        }
        return output
    }

    /// Derive a wrapper with a keypath from the current wrapper.
    /// - parameter keyPath: the writable keypath to the property to derive a wrapper from
    /// - returns a new, scoped wrapper to a property of the wrapped value
    public func derive<T: Equatable>(
        keyPath: WritableKeyPath<Value, T>
    ) -> ObservableWrapper<T> {
        let output = self.map { value in
            value[keyPath: keyPath]
        }
        output.addObservation { [weak self] value in
            self?.withNoRepeatedObservationTriggers {
                self?.wrappedValue[keyPath: keyPath] = value
            }
        }
        return output
    }

    // MARK: Private

    /// Notify all the observations the value changed.
    /// - parameter newValue: The value to publish to the observations.
    /// - parameter isDuplicate: Whether the value is changed.
    private func valueWillChange(_ newValue: Value, isDuplicate: Bool) {
        guard self.shouldTriggerObservations else { return }
        for value in self.observations.values {
            if value.removeDuplicates == true, isDuplicate {
                continue
            } else {
                value.onChange(of: newValue)
            }
        }
    }

    /// Turn off observation triggering to prevent repeated triggers.
    private func withNoRepeatedObservationTriggers(_ action: @escaping () -> Void) {
        self.shouldTriggerObservations = false
        action()
        self.shouldTriggerObservations = true
    }
}
