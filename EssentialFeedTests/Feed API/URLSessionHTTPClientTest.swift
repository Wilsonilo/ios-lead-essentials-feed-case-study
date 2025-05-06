//
//  URLSessionHTTPClientTest.swift
//  EssentialFeed
//
//  Created by Wilson Munoz on 06/05/25.
//

import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from:URLRequest){
        session.dataTask(with: from) { data, response, error in
            //
        }
    }
}

class URLSessionHTTPClientTest: XCTestCase {
    func test_getFromURL_createDataTaskWithURL(){
        let url = URL(string:"http://any-url.com")!
        let request = URLRequest(url: url)
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from:request)
        XCTAssertEqual(session.receivedURLs, [url])
    }
    
    // MARK: - Helpers
    private class URLSessionSpy:URLSession {
        var receivedURLs = [URL]()
        override func dataTask(with request: URLRequest) -> URLSessionDataTask {
            self.receivedURLs.append(request.url!)
            return FakeURLSessionDataTask()
        }
        
    }
    
    private class FakeURLSessionDataTask:URLSessionDataTask {}
    
}
