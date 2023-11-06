//
//  ObservableWrapperKitTests.swift
//  ObservableWrapperKitTests
//
//  Created by Loyi Hsu on 2023/11/5.
//

@testable import ObservableWrapperKit
import XCTest

final class ObservableWrapperKitTests: XCTestCase {
    func testObservationWithObservationAction() {
        let wrapper = ObservableWrapper(initialValue: 0)
        let testcase = [1, 2, 3, 4, 5]

        var output = [Int]()
        wrapper.addObservation {
            output.append($0)
        }

        testcase.forEach { testcase in
            wrapper.mutate { mutatingValue in
                mutatingValue = testcase
            }
        }

        XCTAssertEqual(output, [0, 1, 2, 3, 4, 5])

        addTeardownBlock { [weak wrapper] in
            XCTAssertNil(wrapper)
        }
    }

    func testObservationWithObservationObject() {
        let wrapper = ObservableWrapper(initialValue: "K")
        let testcase = ["A", "B", "C", "D", "E"]

        var output = [String]()
        wrapper.addObservation(
            ActionObservation {
                output.append($0)
            }
        )

        testcase.forEach { testcase in
            wrapper.mutate { mutatingValue in
                mutatingValue = testcase
            }
        }

        XCTAssertEqual(output, ["K", "A", "B", "C", "D", "E"])

        addTeardownBlock { [weak wrapper] in
            XCTAssertNil(wrapper)
        }
    }

    func testDeriveValue() {
        struct DerivableValue: Equatable {
            var value: SubValue
            struct SubValue: Equatable {
                var text: String
            }
        }

        let wrapper = ObservableWrapper(
            initialValue: DerivableValue(
                value: .init(text: "initial")
            )
        )

        XCTAssertEqual(
            wrapper.wrappedValue,
            DerivableValue(value: .init(text: "initial"))
        )

        let derivedWrapper = wrapper.derive(keyPath: \.value.text)

        derivedWrapper.mutate {
            $0 = "changed"
        }

        XCTAssertEqual(
            wrapper.wrappedValue,
            DerivableValue(value: .init(text: "changed"))
        )

        addTeardownBlock { [weak wrapper] in
            XCTAssertNil(wrapper)
        }
    }

    func testRemoveObservation() {
        let wrapper = ObservableWrapper(initialValue: 0)
        var output = [Int]()
        let id = wrapper.addObservation {
            output.append($0)
        }

        wrapper.mutate {
            $0 = 1
        }

        wrapper.mutate {
            $0 = 2
        }

        wrapper.removeObservation(id)

        wrapper.mutate {
            $0 = 3
        }

        XCTAssertEqual(output, [0, 1, 2])

        addTeardownBlock { [weak wrapper] in
            XCTAssertNil(wrapper)
        }
    }
    
    func testRemoveDuplicate() {
        let wrapper = ObservableWrapper(initialValue: 0)
        var output = [Int]()
        
        wrapper.addObservation(removeDuplicates: true) {
            output.append($0)
        }
        
        wrapper.mutate {
            $0 = 0
        }
        
        wrapper.mutate {
            $0 = 1
        }
        
        wrapper.mutate {
            $0 = 1
        }
        
        wrapper.mutate {
            $0 = 2
        }
        
        wrapper.mutate {
            $0 = 2
        }
        
        XCTAssertEqual(output, [0, 1, 2])
        
        addTeardownBlock { [weak wrapper] in
            XCTAssertNil(wrapper)
        }
    }
    
    func testWithoutRemoveDuplicate() {
        let wrapper = ObservableWrapper(initialValue: 0)
        var output = [Int]()
        
        wrapper.addObservation {
            output.append($0)
        }
        
        wrapper.mutate {
            $0 = 0
        }
        
        wrapper.mutate {
            $0 = 1
        }
        
        wrapper.mutate {
            $0 = 1
        }
        
        wrapper.mutate {
            $0 = 2
        }
        
        wrapper.mutate {
            $0 = 2
        }
        
        XCTAssertEqual(output, [0, 0, 1, 1, 2, 2])
        
        addTeardownBlock { [weak wrapper] in
            XCTAssertNil(wrapper)
        }
    }
    
    func testMultipleObservationWithOrWithoutRemoveDuplicate() {
        let wrapper = ObservableWrapper(initialValue: 0)
        var outputWithDuplicate = [Int]()
        var outputWithoutDuplicate = [Int]()
        
        wrapper.addObservation {
            outputWithDuplicate.append($0)
        }
        
        wrapper.addObservation(removeDuplicates: true) {
            outputWithoutDuplicate.append($0)
        }
        
        wrapper.mutate {
            $0 = 0
        }
        
        wrapper.mutate {
            $0 = 1
        }
        
        wrapper.mutate {
            $0 = 1
        }
        
        wrapper.mutate {
            $0 = 2
        }
        
        wrapper.mutate {
            $0 = 2
        }
        
        XCTAssertEqual(outputWithDuplicate, [0, 0, 1, 1, 2, 2])
        XCTAssertEqual(outputWithoutDuplicate, [0, 1, 2])
        
        addTeardownBlock { [weak wrapper] in
            XCTAssertNil(wrapper)
        }
    }
}
