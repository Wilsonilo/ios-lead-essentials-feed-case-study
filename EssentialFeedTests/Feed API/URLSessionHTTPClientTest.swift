//
//  URLSessionHTTPClientTest.swift
//  EssentialFeed
//
//  Created by Wilson Munoz on 06/05/25.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTest: XCTestCase {

    override func setUp() {
        URLProtocolStub.startInterceptionRequest()

    }
    override func tearDown() {
        URLProtocolStub.stopInterceptionRequest()

    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let exp = expectation(description: "loading url check type get")
        let url = anyURL()
        exp.expectedFulfillmentCount = 2
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        makeSUT().get(from: url) { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1)
    }
    
    func test_getFromURL_failsOnRequestError(){
        let error = anyError()
        guard let receivedError = resultError(
            data: nil,
            response: nil,
            error: error
        ) as? NSError else {
            XCTFail("No right error unwrap")
            return
        }
        XCTAssertEqual(receivedError.domain, error.domain)
        XCTAssertEqual(receivedError.code, error.code)
        
    }
    
    func test_getFromURL_failsOnAllInValidRepresentationCases() {
        
        XCTAssertNotNil(resultError(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultError(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultError(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultError(data: anyData(), response: nil, error: anyError()))
        XCTAssertNotNil(resultError(data: nil, response: nonHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultError(data: nil, response: anyHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultError(data: anyData(), response: nonHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultError(data: anyData(), response: anyHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultError(data: anyData(), response: nonHTTPURLResponse() , error: nil))

    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data        = anyData()
        let response  = anyHTTPURLResponse()
        let receivedValues = resultValues(
            data: data,
            response: response,
            error: nil
        )
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(
            receivedValues?.response.statusCode,
            response?.statusCode
        )
        XCTAssertEqual(
            receivedValues?.response.url,
            response?.url
        )
    }
    
    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseNilData() {
        
        let response  = anyHTTPURLResponse()
        let emptyData = Data()
        let receivedValues = resultValues(
            data: nil,
            response: response,
            error: nil
        )
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(
            receivedValues?.response.statusCode,
            response?.statusCode
        )
        XCTAssertEqual(
            receivedValues?.response.url,
            response?.url
        )

        
    }
    
    // MARK: - Helpers
    private func anyURL()->URL{
        let url = URL(string:"http://any-other.com")!
        return url
    }
    
    private func anyData()->Data{
        Data("any data".utf8)
    }
    
    private func anyError()->NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private func nonHTTPURLResponse()->URLResponse {
        URLResponse(
            url: anyURL(),
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
    }
    
    private func anyHTTPURLResponse()->HTTPURLResponse? {
        HTTPURLResponse(
            url: anyURL(),
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
    }
    
    private func resultError(data:Data?, response:URLResponse?, error:Error?, file: StaticString = #filePath,
                             line:UInt = #line)-> Error? {
        let result = resultFor(
            data: data,
            response: response,
            error: error,
            file: file,
            line: line
        )

        switch result {
        case .failure(let error):
            return error
        default:
            XCTFail("Expected failure but got \(result)", file:file, line:line)
            return nil
        }
    }
    
    private func resultValues(data:Data?, response:URLResponse?, error:Error?, file: StaticString = #filePath,
                             line:UInt = #line)-> (data:Data, response:HTTPURLResponse)? {
        
        let result = resultFor(
            data: data,
            response: response,
            error: error,
            file: file,
            line: line
        )
        switch result {
        case .success(let receivedData, let receivedResponse):
            return  (receivedData, receivedResponse)
        default:
            XCTFail("Expected success but got \(result)", file:file, line:line)
            return nil
        }
    }
    
    
    private func resultFor(data:Data?, response:URLResponse?, error:Error?, file: StaticString = #filePath,
                           line:UInt = #line)-> HTTPClientResponse {
        
        URLProtocolStub.stub(data:data, response:response, error:error)
        
        let sut = makeSUT(file:file, line:line)
        var receivedResult:HTTPClientResponse!
        
        let expectation = expectation(description: "Wait for url completion")
        sut.get(from: anyURL()) { result in
            receivedResult = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        return receivedResult
    }
    
    private func makeSUT(file: StaticString = #filePath,
                         line:UInt = #line)->HTTPCLient {
        let sut = URLSessionHTTPClient()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    
    private class URLProtocolStub:URLProtocol {

        private static var stubs:Stub?
        private static var requestObserver:((URLRequest)->Void)?
        private static var observerWasInvoked = false

    
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
            observerWasInvoked = false

        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            // Only call the observer once per test
//            if let observer = requestObserver, !observerWasInvoked {
//                observer(request)
//                observerWasInvoked = true
//            }
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let requestObserver = URLProtocolStub.requestObserver{
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }
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
