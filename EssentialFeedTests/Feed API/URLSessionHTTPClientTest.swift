//
//  URLSessionHTTPClientTest.swift
//  EssentialFeed
//
//  Created by Wilson Munoz on 06/05/25.
//

import XCTest
import EssentialFeed



class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from:URL, completion:@escaping (HTTPClientResponse)->Void){
        session.dataTask(with: from) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTest: XCTestCase {

    
    func test_getFromURL_failsOnRequestError(){
        URLProtocolStub.startInterceptionRequest()
        let url = URL(string:"http://any-other.com")!
        let error = NSError(domain: "any error", code: 1)
 
        URLProtocolStub.stub(url:url, data:nil, response:nil, error:error)
        
        let sut = URLSessionHTTPClient()
        let expectation = expectation(description: "Wait for url completion")
        sut.get(from: url) { result in
            switch result {
            case .failure(let receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            default:
                XCTFail("Expected \(error) but got \(result)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        URLProtocolStub.stopInterceptionRequest()
    }
    
    // MARK: - Helpers
    private class URLProtocolStub:URLProtocol {

        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let data:Data?
            let response:URLResponse?
            let error:Error?
        }
        
        static func stub(
            url:URL,
            data:Data? = nil,
            response:URLResponse? = nil,
            error:Error? = nil
        ){
            URLProtocolStub.stubs[url] = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptionRequest() {
            URLProtocolStub.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptionRequest() {
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else {
                return false
            }
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else {
                return }
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = stub.response {
                client?
                    .urlProtocol(
                        self,
                        didReceive: response,
                        cacheStoragePolicy: .notAllowed
                    )
            }
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
        
    }
    
    
}
