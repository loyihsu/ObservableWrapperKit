//
//  ObservationIdentifier.swift
//  ObservableWrapperKit
//
//  Created by Loyi Hsu on 2023/11/6.
//

import Foundation

public struct ObservationIdentifier: Identifiable, Hashable {
    public let id = UUID()
}
