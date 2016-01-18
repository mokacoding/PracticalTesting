//
//  Copyright © 2016 mokacoding. All rights reserved.
//

import Quick
import Nimble
@testable import PracticalTesting

class QuickNimbleAsyncSpec: QuickSpec {
    override func spec() {

        describe("Callback testing") {
            let service = SomeService()

            it("can test callbacks using waitUntil") {
                waitUntil { done in
                    service.doSomethingAsync { success in
                        expect(success).to(beTrue())

                        done()
                    }
                }
            }
        }

        describe("Delegate testing") {
            context("async methods call") {
                let something = SomethingWithDelegate()
                let spyDelegate = QuickSpyDelegate()
                something.delegate = spyDelegate

                it("can be tested with toEventually") {
                    something.doAsyncStuff()

                    expect(spyDelegate.somethingWithDelegateAsyncResult).toEventually(beTrue())
                }
            }

            context("property setting") {
                let something = SomethingWithDelegate()
                let spyDelegate = SpyDelegate()
                something.delegate = spyDelegate

                it("can be tested with toEventually") {
                    something.methodResultingInDelegatePropertySet()

                    expect(spyDelegate.property).toEventually(equal(42))
                }
            }
        }
    }
}

class QuickSpyDelegate: Delegate {

    var property: Int?

    // Setting .None is unnecessary, but helps with clarity imho
    var somethingWithDelegateResult: Bool? = .None

    var somethingWithDelegateAsyncResult: Bool? = .None

    func somethingWithDelegate(something: SomethingWithDelegate, didStuffWithResult result: Bool) {
        self.somethingWithDelegateResult = result
    }

    func somethingWithDelegate(something: SomethingWithDelegate, didAsyncStuffWithResult result: Bool) {
        somethingWithDelegateAsyncResult = result
    }
}