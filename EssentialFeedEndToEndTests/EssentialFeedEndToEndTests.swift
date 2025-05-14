//
//  EssentialFeedEndToEndTests.swift
//  EssentialFeedEndToEndTests
//
//  Created by Wilson Munoz on 14/05/25.
//

import XCTest
import EssentialFeed

class EssentialFeedEndToEndTests:XCTestCase {
    
    private let remoteItems:Array<[String:String]> = [
        [
            "id": "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "description": "Description 1",
            "location": "Location 1",
            "image": "https://url-1.com",
        ],
        [
            "id": "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "location": "Location 2",
            "image": "https://url-2.com",
        ],
        [
            "id": "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "description": "Description 3",
            "image": "https://url-3.com",
        ],
        [
            "id": "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "image": "https://url-4.com",
        ],
        [
            "id": "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "description": "Description 5",
            "location": "Location 5",
            "image": "https://url-5.com",
        ],
        [
            "id": "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "description": "Description 6",
            "location": "Location 6",
            "image": "https://url-6.com",
        ],
        [
            "id": "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "description": "Description 7",
            "location": "Location 7",
            "image": "https://url-7.com",
        ],
        [
            "id": "F79BD7F8-063F-46E2-8147-A67635C3BB01",
            "description": "Description 8",
            "location": "Location 8",
            "image": "https://url-8.com",
        ]
    ]
    
    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData(){
    

        switch getFeedResult() {
        case .success(let items)?:
            XCTAssertEqual(items.count, 8, "Expected 8 items but got \(items.count)")
            items.enumerated().forEach { (index, item) in
                XCTAssertEqual(item, expectedItem(at: index))
            }
        case .failure(let error):
            XCTFail(
                "Expected success but got error: \(error)"
            )
        default:
            XCTFail("Expected success but got no result ")

        }
    }
    
    // MARK: - Helpers
    
    private func getFeedResult(file: StaticString = #filePath,
                               line:UInt = #line)->LoadFeedResult? {
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(client: client, url: testServerURL)
        trackForMemoryLeaks(client, file:file, line:line)
        trackForMemoryLeaks(loader, file:file, line:line)
        let expectation = expectation(description: "wait for server to deliver data")
        var receivedResult:LoadFeedResult?
        loader.load { result in
            receivedResult = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        return receivedResult
    }
    
    private func expectedItem(at index:Int)->FeedItem {
        FeedItem(id: id(at: index),
                 description: description(at: index),
                 location: location(at: index),
                 imageURL: imageURL(at: index))
    }
    
    private func id(at index:Int)->UUID {
        UUID(uuidString: remoteItems[index]["id"]!)!
    }
    
    private func description(at index:Int)->String? {
        remoteItems[index]["description"]
    }
    
    private func location(at index:Int)->String? {
        remoteItems[index]["location"]
    }
    
    private func imageURL(at index:Int)->URL {
        URL(string:remoteItems[index]["image"]!)!
    }
}
