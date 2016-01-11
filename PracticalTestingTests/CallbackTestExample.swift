//
//  Copyright © 2016 mokacoding. All rights reserved.
//

import XCTest
@testable import PracticalTesting

class CallbackTest: XCTestCase {

    func testAsyncCalback() {
        let service = SomeService()

        // This is not an async test, and it will never run.
        //
        // Note that this highlight how important it is to verify that our tests actually fail
        // Otherwise we would have been happy with asserting success == true, which would never
        // run, but we wouldn't notice that
        service.doSomethingAsync { success in
            XCTFail("This assertion will never run")
        }

        // This is a proper async test
        //
        // 1. Setup the expectation
        let expectation = expectationWithDescription("SomeService does stuff and succeeds")

        // 2. Exercise and verify the behaviour as usual
        service.doSomethingAsync { success in
            XCTAssertTrue(success)

            // Important! Don't forget to fulfill the expectation.
            expectation.fulfill()
        }

        // 3. Make the test runner wait for the expectation(s) to fulfill
        waitForExpectationsWithTimeout(1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

}

class SomeService {

    func doSomethingAsync(completion: (success: Bool) -> ()) {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue) {
            completion(success: true)
        }
    }
}
