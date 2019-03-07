//
//  ConcurrentOperationTests.swift
//  ConcurrentOperationTests
//
//  Created by Arthur Dexter on 3/7/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import XCTest
@testable import ConcurrentOperation

class ConcurrentOperationTests: XCTestCase {

    let queue = OperationQueue()

    func testRunConcurrentOperation() {
        let operation = TestConcurrentOperation()

        let expectation = self.expectation(description: "operation")
        operation.completionBlock = expectation.fulfill

        queue.addOperation(operation)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testCancelConcurrentOperationBeforeStart() {
        let operation = TestConcurrentOperation()
        operation.cancel()

        let expectation = self.expectation(description: "operation")
        operation.completionBlock = expectation.fulfill

        queue.addOperation(operation)

        waitForExpectations(timeout: 0.25, handler: nil)
        XCTAssert(operation.isCancelled)
    }
}

private class TestConcurrentOperation: ConcurrentOperation {
    override func executeOperation() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            self.completeOperation()
        }
    }
}
