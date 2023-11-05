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
}
