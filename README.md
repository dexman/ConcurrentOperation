# ConcurrentOperation

`ConcurrentOperation` is a library that provides a simple concurrent
Cocoa `Operation` subclass and `ConcurrentBlockOperation` subclass for
iOS.

Concurrent operations are useful when you have asynchronous work, such
as a network request with `URLSession`, that you want to perform in an
`Operation`.

## Install

The `ConcurrentOperation` Xcode project has a targets to build an iOS
dynamic frameworks. You can build it and add it to your project
manually, or add a subproject in Xcode.

Alternatively you may use one of the following dependency managers:

#### Carthage

Add `ConcurrentOperation` to your `Cartfile`

```ruby
github "dexman/ConcurrentOperation"
```

## Usage

**`ConcurrentOperation`**

You must subclass `ConcurrentOperation` to use it. Override
`executeOperation()` to perform your asynchronous work. When the work
is complete, call `completeOperation()`, even if the operation was
cancelled.

*Example:*

```swift
import ConcurrentOperation

class ExampleOperation: ConcurrentOperation {
    override func executeOperation() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
		    if self.isCancelled {
			    print("We were cancelled")
			}
            self.completeOperation()
        }
	}
}

func useExampleOperation() {
    OperationQueue.main.addOperation(ExampleOperation())
}
```


**`ConcurrentBlockOperation`**

You may use `ConcurrentBlockOperation` without creating a
subclass. Simply provide a block that performs the work to be
done. When the work is complete, call `completeOperation()`, even if
the operation was cancelled.

*Example:*

```swift
import ConcurrentOperation

func useExampleBlockOperation() {
    let operation = ConcurrentBlockOperation { (operation: ConcurrentBlockOperation) in
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
		    if operation.isCancelled {
			    print("We were cancelled")
			}
            operation.completeOperation()
        }
	}
    OperationQueue.main.addOperation(operation)
}
```

## TODO

- Support for other platforms, e.g. macos, tvos, and watchos.

## License

`ConcurrentOperation` is protected under the MIT license.
