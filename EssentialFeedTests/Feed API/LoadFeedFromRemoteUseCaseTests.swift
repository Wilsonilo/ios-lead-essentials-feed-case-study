//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Wilson Munoz on 22/04/25.
//

import XCTest
import EssentialFeed

final class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    
    /// On Init, check urls are empty.
    func test_init_doesNotRequestDataFromURL(){
        
        /// This is the collaborator for the RemoteFeedLoader
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
        
    }
    
    /// Check load works, we check there is an url an is equal to what we init to
    func test_load_requestsDataFromURL() {
        
        /// The url that we want to fetch
        let url = URL(string: "https://a-m-url.com")!
        
        let (sut, client) = makeSUT(url: url)
        sut.load{ _ in}
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    /// We check what happens if we do more than one load
    func test_loadTwice_requestsDataFromURLTwice() {
        
        /// The url that we want to fetch
        let url = URL(string: "https://another-url.com")!
        
        let (sut, client) = makeSUT(url: url)
        sut.load{ _ in}
        sut.load{ _ in}
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    /// We need to check the case for error
    /// this is part of the "story" on the repo
    /// to handle errors
    /// Invalid data – error course (sad path):
    func test_load_deliversErrorOnClientError(){
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
        
    }
    
    /// This is part of the "story" on the repo
    /// to handle errors
    /// Invalid data – error course (sad path)
    func test_load_deliversErrorOnNon200HTTPResponse(){
        let (sut, client) = makeSUT()
        
        /// Check all of the different codes
        let samples = [199, 201, 300, 400, 401, 500]
        samples.enumerated().forEach {index, code in
            
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let data = makeItemsJSON([])
                client.complete(withStatusCode: code, data: data, at: index)
            }
            
        }
        
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData)) {
            let invalidJSON = Data("Invalid JSON".utf8)
            
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
        
    }
    
    /// Tests the conformance of the model for feed entries
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        
        /// Create the sut
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            /// Tell the client to finish with our need to test
            let emptyListJSON =  makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    /// Getting some items
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        
        let (sut, client) = makeSUT()
        let (item1, item1JSON) = makeItem(
            id: UUID(),
            imageURL: URL(string: "https://a-url.com")!
        )
        let (item2, item2JSON) = makeItem(
            id: UUID(),
            description: "description",
            location: "location",
            imageURL: URL(string: "https://another-url.com")!
        )
        expect(sut, toCompleteWith: .success([item1, item2])) {
            let json = makeItemsJSON([item1JSON, item2JSON])
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    /// We want to ensure that there is no result after the sut / client has been deallocated
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated(){
        let url = URL(string: "https://a-url.com")!
        let client = TestingHTTPClient()
        var sut:RemoteFeedLoader? = RemoteFeedLoader(client: client, url: url)
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        XCTAssert(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers -
    /// SUT = System Under Task
    private func makeSUT(url:URL = URL(string: "https://a-url.com")!,
                         file: StaticString = #filePath,
                         line:UInt = #line) ->
    (
        sut: RemoteFeedLoader,
        client:TestingHTTPClient
    ) {
        
        let client = TestingHTTPClient()
        let sut = RemoteFeedLoader(client: client, url: url)
        
        // We check if the instance created is free in memory
        // With this we check against retain cycles.
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
        
    }
    
    private func makeItem(
        id:UUID,
        description:String? = nil,
        location:String? = nil,
        imageURL:URL
    )->(model: FeedItem, JSON:[String:Any]) {
        (FeedItem(
            id: id,
            description: description,
            location: location,
            imageURL: imageURL
        ), [
            
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].reduce(into:[String:Any](), { accumulated, element in
            if let value = element.value {
                accumulated[element.key] = value
            }
        }))
    }
    
    private func makeItemsJSON(_ items:[[String:Any]])->Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut:RemoteFeedLoader, toCompleteWith expectedResult:RemoteFeedLoader.Result,
                        when action:()->Void, file: StaticString = #filePath, line:UInt = #line) {
        
        let expectation = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            
            switch (receivedResult, expectedResult) {
                
            case let( .success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line:line)
            case let(
                .failure(receivedError as RemoteFeedLoader.Error),
                .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(
                    receivedError,
                    expectedError,
                    file: file,
                    line:line
                )
            default:
                XCTFail("Expected result \(expectedResult) but got \(receivedResult) instead", file: file, line:line)
                
            }
            
            
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1 )
    }
    
    /// This is our baseline implementation of `Client`
    /// This guys change methods and add variables to test
    /// they have different process for each `Client` meaning the code in here is different from the production code on `HTTPClient` this is to test.
    private class TestingHTTPClient:HTTPCLient {
        
        private var messages = [(url:URL, completion:(HTTPClientResponse) -> Void)]()
        var requestedURLs:[URL] {
            messages.map({$0.url})
        }
        
        func get(
            from url: URL,
            completion:@escaping (HTTPClientResponse) -> Void
        ) {
            messages.append((url, completion))
        }
        
        
        func complete(with error:Error, at index:Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code:Int, data:Data, at index:Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
    }
    
    /// Factory method to deliver a failure from ``RemoteFeedLoader``
    private func failure(_ error: RemoteFeedLoader.Error)->RemoteFeedLoader.Result {
        .failure(error)
    }
    
}
