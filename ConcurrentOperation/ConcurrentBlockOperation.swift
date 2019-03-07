//
//  ConcurrentBlockOperation.swift
//  ConcurrentOperation
//
//  Created by Arthur Dexter on 3/7/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

/// Concurrent block operation subclass.
///
/// Executes a given block asynchronously in an `OperationQueue`.
public class ConcurrentBlockOperation: ConcurrentOperation {

    /// Create a new operation.
    ///
    /// - parameters:
    ///     - block: The block to execute. The operation is provided as an argument so
    ///              you may call `completeOperation()` or `isCancelled`.
    public init(block: @escaping (ConcurrentBlockOperation) -> Void) {
        self.block = block
        super.init()
    }

    public final override func executeOperation() {
        self.block(self)
    }

    private var block: (ConcurrentBlockOperation) -> Void
}
