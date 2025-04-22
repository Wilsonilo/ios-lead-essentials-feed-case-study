//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Wilson Munoz on 22/04/25.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL(){
        
        /// This is the collaborator for the RemoteFeedLoader
        let (_, client) = makeSUT()
        XCTAssertNil(client.requestedURL)
         
    }
    
    func test_load_requestDataFromURL() {
        
        /// The url that we want to fetch
        let url = URL(string: "https://a-url.com")!
        
        let (sut, client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(client.requestedURL?.absoluteString, url.absoluteString)
    }
    
    // MARK: - Helpers -
    /// SUT = System Under Task
    private func makeSUT(url:URL = URL(string: "https://a-url.com")!) ->
    (sut: RemoteFeedLoader, client:Client) {
        
        let client = TestingHTTPClient()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
        
    }
    
    private class TestingHTTPClient:Client {
        var requestedURL:URL?
    }

}
