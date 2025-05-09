//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Wilson Munoz on 09/05/25.
//

import Foundation

public class URLSessionHTTPClient: HTTPCLient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValueRepresentation:Error {}
    
    public func get(from:URL, completion:@escaping (HTTPClientResponse)->Void){
        session.dataTask(with: from) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            }
            else {
                completion(.failure(UnexpectedValueRepresentation()))
            }
        }.resume()
    }
}
