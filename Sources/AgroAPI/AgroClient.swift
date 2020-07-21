//
//  AgroClient.swift
//  AgroAPI
//
//  Created by Ringo Wathelet on 2020/07/19.
//

import Foundation
import Combine

/// http method types
public enum HttpMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

/// represents an error during a connection
public enum AgroAPIError: Swift.Error, LocalizedError {
    
    case unknown, apiError(reason: String), parserError(reason: String), networkError(from: URLError)
    
    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .apiError(let reason), .parserError(let reason):
            return reason
        case .networkError(let from):
            return from.localizedDescription
        }
    }
}

/// a network connection to the Agro API server
///
/// info at: https://agromonitoring.com/api/polygons
/// and  at: https://agromonitoring.com/api/images
public class AgroClient {
    
    public let apiKey: String
    public let sessionManager: URLSession
    
    public let mediaType = "application/json; charset=utf-8"
    public let agroPolyURL = "https://api.agromonitoring.com/agro/1.0/polygons"
    public let agroSatURL  = "https://api.agromonitoring.com/agro/1.0/image"
    
    public init(apiKey: String) {
        self.apiKey = "appid=" + apiKey
        self.sessionManager = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 30  // seconds
            configuration.timeoutIntervalForResource = 30 // seconds
            return URLSession(configuration: configuration)
        }()
    }
    
    private func urlPolyBuilder(_ httpMethod: HttpMethod, param: String) -> URL? {
        switch httpMethod {
        case .post:
            return URL(string: "\(agroPolyURL)?\(apiKey)")
        case .get:
            if param.isEmpty {
                // for list of all polygons
                return URL(string: "\(agroPolyURL)?\(apiKey)")
            } else {
                // for a specific (id) polygon
                return URL(string: "\(agroPolyURL)/\(param)?\(apiKey)")
            }
        case .delete:
            return URL(string: "\(agroPolyURL)/\(param)?\(apiKey)")
        case .put:
            return URL(string: "\(agroPolyURL)/\(param)?\(apiKey)")
        }
    }
    
    private func urlSatBuilder(options: AgroOptions) -> URL? {
        return URL(string: "\(agroSatURL)/search?\(options.toParamString())&\(apiKey)")
    }

    /// post data to the server. A POST request with the given body dat is sent to the server.
    /// The server response is parsed then converted to an object, typically AgroPolyResponse.
    ///
    /// - Parameter jsonData: the body request as data
    /// - Returns: return a AnyPublisher<T?, AgroAPIError>
    public func postThis<T: Decodable>(jsonData: Data) -> AnyPublisher<T?, AgroAPIError> {
        guard let url = urlPolyBuilder(.post, param: "") else {
            return Just<T?>(nil).setFailureType(to: AgroAPIError.self).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(mediaType, forHTTPHeaderField: "Accept")
        request.addValue(mediaType, forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        return self.doDataTaskPublish(request: request)
    }

    /// remove data from the server. A DELETE request with the chosen parameter is sent to the server.
    ///
    /// - Parameter param: the id of the polygon to delete
    /// - Returns: return a AnyPublisher<T?, AgroAPIError>
    public func deleteThis<T: Decodable>(param: String) -> AnyPublisher<T?, AgroAPIError> {
        guard let url = urlPolyBuilder(.delete, param: param) else {
            return Just<T?>(nil).setFailureType(to: AgroAPIError.self).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue(mediaType, forHTTPHeaderField: "Accept")
        request.addValue(mediaType, forHTTPHeaderField: "Content-Type")
        
        return self.doDataTaskPublish(request: request)
    }

    /// fetch data from the server. A GET request with the chosen parameter is sent to the server.
    /// The server response is parsed then converted to an object, typically AgroPolyResponse or [AgroPolyResponse].
    ///
    /// - Parameter param: the id of the polygon to fetch
    /// - Returns: return a AnyPublisher<T?, AgroAPIError>
    public func fetchThis<T: Decodable>(param: String) -> AnyPublisher<T?, AgroAPIError> {
        guard let url = urlPolyBuilder(.get, param: param) else {
            return Just<T?>(nil).setFailureType(to: AgroAPIError.self).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(mediaType, forHTTPHeaderField: "Accept")
        request.addValue(mediaType, forHTTPHeaderField: "Content-Type")
        
        return self.doDataTaskPublish(request: request)
    }
    
    /// fetch data from the server. A GET request with the chosen options is sent to the server.
    /// The server response is parsed then converted to an object, typically AgroSatResponse or [AgroSatResponse].
    ///
    /// - Parameter options: the request options parameters
    /// - Returns: return a AnyPublisher<T?, AgroAPIError>
    public func fetchThis<T: Decodable>(options: AgroOptions) -> AnyPublisher<T?, AgroAPIError> {
        guard let url = urlSatBuilder(options: options) else {
            return Just<T?>(nil).setFailureType(to: AgroAPIError.self).eraseToAnyPublisher()
        }
        print("\n---> AgroClient fetchThis url: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(mediaType, forHTTPHeaderField: "Accept")
        request.addValue(mediaType, forHTTPHeaderField: "Content-Type")
        
        return self.doDataTaskPublish(request: request)
    }
    
    /// fetch data from the server. A GET request with the chosen url is sent to the server.
    /// The server response is parsed then converted to an object
    ///
    /// - Parameter urlString: the url to fetch
    /// - Returns: return a AnyPublisher<T?, AgroAPIError>
    public func fetchThisUrl<T: Decodable>(urlString: String) -> AnyPublisher<T?, AgroAPIError> {
        guard let url = URL(string: urlString) else {
            return Just<T?>(nil).setFailureType(to: AgroAPIError.self).eraseToAnyPublisher()
        }
        print("\n---> AgroClient fetchThisUrl url: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(mediaType, forHTTPHeaderField: "Accept")
        request.addValue(mediaType, forHTTPHeaderField: "Content-Type")
        
        return self.doDataTaskPublish(request: request)
    }
    
    /// fetch data from the server. A GET request with the chosen url is sent to the server.
    ///
    /// - Parameter urlString: the url to fetch
    /// - Returns: return a AnyPublisher<Data?, AgroAPIError>
    public func fetchThisData(urlString: String) -> AnyPublisher<Data?, AgroAPIError> {
        guard let url = URL(string: urlString) else {
            return Just<Data?>(nil).setFailureType(to: AgroAPIError.self).eraseToAnyPublisher()
        }
        print("\n---> AgroClient fetchThisData url: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return self.doRawDataTaskPublish(request: request)
    }

    private func doDataTaskPublish<T: Decodable>(request: URLRequest) -> AnyPublisher<T?, AgroAPIError> {
        return self.sessionManager.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw AgroAPIError.unknown
                }
                if (httpResponse.statusCode == 401) {
                    throw AgroAPIError.apiError(reason: "Unauthorized")
                }
                if (httpResponse.statusCode == 403) {
                    throw AgroAPIError.apiError(reason: "Resource forbidden")
                }
                if (httpResponse.statusCode == 404) {
                    throw AgroAPIError.apiError(reason: "Resource not found")
                }
                if (405..<500 ~= httpResponse.statusCode) {
                    throw AgroAPIError.apiError(reason: "client error")
                }
                if (500..<600 ~= httpResponse.statusCode) {
                    throw AgroAPIError.apiError(reason: "server error")
                }
                
   //             self.showPretty(data)
                
                return try? JSONDecoder().decode(T.self, from: data)
            }
            .mapError { error in
                // return the APIError type error
                if let error = error as? AgroAPIError {
                    return error
                }
                // a URLError, convert it to APIError type error
                if let urlerror = error as? URLError {
                    return AgroAPIError.networkError(from: urlerror)
                }
                // unknown error condition
                return AgroAPIError.unknown
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    
    private func doRawDataTaskPublish(request: URLRequest) -> AnyPublisher<Data?, AgroAPIError> {
        return self.sessionManager.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw AgroAPIError.unknown
                }
                if (httpResponse.statusCode == 401) {
                    throw AgroAPIError.apiError(reason: "Unauthorized")
                }
                if (httpResponse.statusCode == 403) {
                    throw AgroAPIError.apiError(reason: "Resource forbidden")
                }
                if (httpResponse.statusCode == 404) {
                    throw AgroAPIError.apiError(reason: "Resource not found")
                }
                if (405..<500 ~= httpResponse.statusCode) {
                    throw AgroAPIError.apiError(reason: "client error")
                }
                if (500..<600 ~= httpResponse.statusCode) {
                    throw AgroAPIError.apiError(reason: "server error")
                }
                
                return data
            }
            .mapError { error in
                // return the APIError type error
                if let error = error as? AgroAPIError {
                    return error
                }
                // a URLError, convert it to APIError type error
                if let urlerror = error as? URLError {
                    return AgroAPIError.networkError(from: urlerror)
                }
                // unknown error condition
                return AgroAPIError.unknown
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // for testing
    private func showPretty(_ data: Data) {
        
        let testDecode = try? JSONDecoder().decode([AgroPolyResponse].self, from: data)
        print("\n----> response object: \(testDecode as Optional)")
        
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers), let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            print("\n----> response json: " + String(decoding: jsonData, as: UTF8.self))
        } else {
            print("=========> json data malformed")
        }
    }
    
}
