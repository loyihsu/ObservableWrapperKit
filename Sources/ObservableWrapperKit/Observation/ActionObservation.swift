//
//  ActionObservation.swift
//  ObservableWrapperKit
//
//  Created by Loyi Hsu on 2023/11/5.
//

/// The observation object that executes the action defined by a closure.
public struct ActionObservation<Value: Equatable>: ObservationProtocol {
    private var onChangeAction: (Value) -> Void
    public var removeDuplicates: Bool

    /// - parameter removeDuplicates: When set to true, it does not trigger the observations if value doesn't change. (default: `false`)
    /// - parameter onChangeAction: The callback value that would be called when value changes.
    public init(
        removeDuplicates: Bool = false,
        onChangeAction: @escaping (Value) -> Void
    ) {
        self.removeDuplicates = removeDuplicates
        self.onChangeAction = onChangeAction
    }

    public func onChange(of value: Value) {
        self.onChangeAction(value)
    }
}
