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

    
    func test_getFromURL_performsGETRequestWithURL() {
        URLProtocolStub.startInterceptionRequest()
        let exp = expectation(description: "loading url check type get")
        let url = URL(string:"http://any-other.com")!
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        URLSessionHTTPClient().get(from: url) { _ in }
        wait(for: [exp], timeout: 1)
        URLProtocolStub.stopInterceptionRequest()
    }
    
    func test_getFromURL_failsOnRequestError(){
        URLProtocolStub.startInterceptionRequest()
        let url = URL(string:"http://any-other.com")!
        let error = NSError(domain: "any error", code: 1)
 
        URLProtocolStub.stub(data:nil, response:nil, error:error)
        
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

        private static var stubs:Stub?
        private static var requestObserver:((URLRequest)->Void)?
        private struct Stub {
            let data:Data?
            let response:URLResponse?
            let error:Error?
        }
        
        static func stub(
            data:Data? = nil,
            response:URLResponse? = nil,
            error:Error? = nil
        ){
            stubs = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest)->Void){
            requestObserver = observer
        }
        
        static func startInterceptionRequest() {
            URLProtocolStub.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptionRequest() {
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
            stubs = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stubs?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = URLProtocolStub.stubs?.response {
                client?
                    .urlProtocol(
                        self,
                        didReceive: response,
                        cacheStoragePolicy: .notAllowed
                    )
            }
            if let error = URLProtocolStub.stubs?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
        
    }
    
    
}
