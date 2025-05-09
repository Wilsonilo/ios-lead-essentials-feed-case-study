//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeed
//
//  Created by Wilson Munoz on 08/05/25.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance:AnyObject,
                                     file: StaticString = #filePath,
                                     line:UInt = #line) {
        // We check if the instance created is free in memory
        // With this we check against retain cycles.
        addTeardownBlock {[weak instance] in
            XCTAssertNil(
                instance,
                "Instance should be deallocated. Potential memory leak",
                file:file,
                line: line
            )
        }
    }
}
