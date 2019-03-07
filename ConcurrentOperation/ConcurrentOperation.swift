//
//  ConcurrentOperation.swift
//  ConcurrentOperation
//
//  Created by Arthur Dexter on 3/7/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

/// Concurrent Operation subclass.
///
/// In a subclass, override `executeOperation()` to perform your
/// asynchronous operation. The subclass must call `completeOperation()`
/// when the tasks started by `executeOperation()` is complete, even if
/// the operation has been cancelled.
///
/// Do not call `executeOperation()` directly, it will be called for
/// you. Do not call `completeOperation()` more than once.
open class ConcurrentOperation: Operation {

    public final override var isAsynchronous: Bool {
        return true
    }

    @objc
    class func keyPathsForValuesAffectingIsExecuting() -> Set<String> {
        return ["state"]
    }

    public final override var isExecuting: Bool {
        return self.state == .executing
    }

    @objc
    class func keyPathsForValuesAffectingIsFinished() -> Set<String> {
        return ["state"]
    }

    public final override var isFinished: Bool {
        return self.state == .finished
    }

    public final override func start() {
        if isCancelled {
            // Finish early if `cancel()` was called before `start()`.
            self.state = .finished
        } else {
            // Start executing the operation. We don't stop executing until
            // `completeOperation()` is called by the subclass.
            self.state = .executing
            self.executeOperation()
        }
    }

    /// This method must be overridden by subclasses. Make exactly one
    /// call to `completeOperation()` when the work started by this
    /// method is complete. Don't call this method directly.
    open func executeOperation() {
        abort()
    }

    /// Call this method when the tasks started by `executeOperation()`
    /// are complete. Do not call more than once.
    public final func completeOperation() {
        self.state = .finished
    }

    // Provides thread synchronization for `unsafeState`.
    private let stateQueue = DispatchQueue(
        label: "ConcurrentOperation.stateQueue",
        attributes: .concurrent)

    // Do not access directly. Instead use `state`.
    private var unsafeState: ConcurrentOperationState = .initialized

    private var state: ConcurrentOperationState {
        get {
            // `self.stateQueue` is concurrent, but it uses a barrier to write
            // to avoid race conditions.
            return self.stateQueue.sync {
                return self.unsafeState
            }
        }
        set {
            // Fail if we have an attempt to make an invalid state transition.
            assert(self.canTransition(to: newValue))

            // Avoid KVO notifications while the lock is held.
            willChangeValue(forKey: "state")

            // Use barrier to ensure only a single writer.
            self.stateQueue.sync(flags: .barrier) {
                self.unsafeState = newValue
            }

            // Avoid KVO notifications while the lock is held.
            didChangeValue(forKey: "state")
        }
    }

    private func canTransition(to newState: ConcurrentOperationState) -> Bool {
        switch (self.state, newState) {
        case (.initialized, _):
            return true

        case (.executing, .finished):
            return true
        case (.executing, _):
            return false

        case (.finished, _):
            return false
        }
    }
}

private enum ConcurrentOperationState {
    // This is the initial state, before the operation has been executed or finished.
    case initialized

    // This is the state while the operation is executing. We might
    // never reach this state if the operation was cancelled before it
    // was started.
    case executing

    // This is the state when the operation is complete, even if the
    // operation was cancelled.
    case finished
}
