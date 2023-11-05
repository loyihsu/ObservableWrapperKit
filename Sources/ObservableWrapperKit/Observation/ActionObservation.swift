//
//  ActionObservation.swift
//  ObservableContainerKit
//
//  Created by Loyi Hsu on 2023/11/5.
//

/// The observation object that executes the action defined by a closure.
public struct ActionObservation<Value: Equatable>: ObservationProtocol {
    private var onChangeAction: (Value) -> Void

    public init(onChangeAction: @escaping (Value) -> Void) {
        self.onChangeAction = onChangeAction
    }

    public func onChange(of value: Value) {
        onChangeAction(value)
    }
}
