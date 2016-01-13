//
//  Copyright © 2016 mokacoding. All rights reserved.
//

import XCTest

class DelegateTestExample: XCTestCase {

    func testDelegateMethodIsCalledSync() {
        let something = SomethingWithDelegate()
        let spyDelegate = SpyDelegate()
        something.delegate = spyDelegate

        something.doStuff()

        guard let result = spyDelegate.somethingWithDelegateResult else {
            XCTFail("Expected delegate to be called")
            return
        }

        XCTAssertTrue(result)
    }

    func testDelegateMethodIsCalledAsync() {
        let something = SomethingWithDelegate()
        let spyDelegate = SpyDelegate()
        something.delegate = spyDelegate

        let expectation = expectationWithDescription("SomethingWithDelegate calls the delegate as the result of an async method completion")
        spyDelegate.asyncExpectation = expectation

        something.doAsyncStuff()

        waitForExpectationsWithTimeout(1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }

            guard let result = spyDelegate.somethingWithDelegateAsyncResult else {
                XCTFail("Expected delegate to be called")
                return
            }

            XCTAssertTrue(result)
        }
    }

    func testDelegatePropertySet() {
        let something = SomethingWithDelegate()
        let spyDelegate = SpyDelegate()
        something.delegate = spyDelegate

        something.methodResultingInDelegatePropertySet()

        guard let propertyValue = spyDelegate.property else {
            XCTFail("Expected delegate to be called")
            return
        }

        XCTAssertEqual(propertyValue, 42)
    }
}

class SomethingWithDelegate {
    weak var delegate: Delegate?

    func doStuff() {
        self.delegate?.somethingWithDelegate(self, didStuffWithResult: true)
    }

    func doAsyncStuff() {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue) {
            self.delegate?.somethingWithDelegate(self, didAsyncStuffWithResult: true)
        }
    }

    func methodResultingInDelegatePropertySet() {
        self.delegate?.property = 42
    }
}

protocol Delegate: class {

    var property: Int? { get set }

    func somethingWithDelegate(something: SomethingWithDelegate, didStuffWithResult result: Bool)

    func somethingWithDelegate(something: SomethingWithDelegate, didAsyncStuffWithResult result: Bool)
}

// A test spy is defined as:
//
// > Use a Test Double to capture the indirect output calls made to another component by the system 
// > under test (SUT) for later verification by the test.
//
// See http://xunitpatterns.com/Test%20Spy.html
//
// The usage we do is not 100% in line with the definition as we are not really making a Double of
// an existing class, but I still feel that the Spy name is appropriate because of the capturing
// behaviour
class SpyDelegate: Delegate {

    var property: Int?

    // Setting .None is unnecessary, but helps with clarity imho
    var somethingWithDelegateResult: Bool? = .None

    var somethingWithDelegateAsyncResult: Bool? = .None
    var asyncExpectation: XCTestExpectation?


    func somethingWithDelegate(something: SomethingWithDelegate, didStuffWithResult result: Bool) {
        self.somethingWithDelegateResult = result
    }

    func somethingWithDelegate(something: SomethingWithDelegate, didAsyncStuffWithResult result: Bool) {
        guard let expectation = asyncExpectation else {
            XCTFail("SpyDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }

        somethingWithDelegateAsyncResult = result
        expectation.fulfill()
    }
}