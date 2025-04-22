//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Wilson Munoz on 22/04/25.
//

import XCTest

class RemoteFeedLoader{}
class HTTPClient{
    var requestedURL:URL?
}
final class RemoteFeedLoaderTest: XCTestCase {

    func init_test_doesNotRequestDataFromURL(){
        
        /// This is the collaborator for the RemoteFeedLoader
        let client = HTTPClient()
        
        /// sut = system under task or system process
        let sut = RemoteFeedLoader()
        XCTAssertNil(client.requestedURL)
         
    }

}
