//
//  ObservationProtocol.swift
//  ObservableWrapperKit
//
//  Created by Loyi Hsu on 2023/11/5.
//

/// The observation that can be appended to an ``ObservableWrapper``.
public protocol ObservationProtocol<Value> {
    // The value is required to be Equatable for the diffing to work.
    associatedtype Value: Equatable

    /// Action triggered when the observed action changed.
    func onChange(of value: Value)
}
