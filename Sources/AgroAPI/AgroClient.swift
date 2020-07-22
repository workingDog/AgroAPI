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
    
    public let agroPolyURL    = "https://api.agromonitoring.com/agro/1.0/polygons"
    public let agroSatURL     = "https://api.agromonitoring.com/agro/1.0/image"
    public let agroWeatherURL = "https://api.agromonitoring.com/agro/1.0/weather"
    public let agroHistoryURL = "https://api.agromonitoring.com/agro/1.0/ndvi/history"
 
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
    
    private func urlHistoryBuilder(options: AgroOptions) -> URL? {
        return URL(string: "\(agroHistoryURL)?\(options.toHistoryNDVIParamString())&\(apiKey)")
    }
    
    private func urlWeatherBuilder(param: String, isForecast: Bool, options: WeatherOptions? = nil) -> URL? {
        if options != nil {
            return URL(string: "\(agroWeatherURL)/history?polyid=\(param)&\(apiKey)")
        }
        if isForecast {
            return URL(string: "\(agroWeatherURL)/forecast?polyid=\(param)&\(apiKey)")
        } else {
            return URL(string: "\(agroWeatherURL)?polyid=\(param)&\(apiKey)")
        }
    }
 
    /// change data on the server. A PUT request with the given body data is sent to the server.
    /// The server response is parsed then converted to an object, typically AgroPolyResponse.
    ///
    /// - Parameter bodyData: the body request as data
    /// - Parameter param: the id of the polygon to change
    /// - Returns: return a AnyPublisher<T?, AgroAPIError>
    public func putThis<T: Decodable>(bodyData: Data, param: String) -> AnyPublisher<T?, AgroAPIError> {
        guard let url = urlPolyBuilder(.put, param: param) else {
            return Just<T?>(nil).setFailureType(to: AgroAPIError.self).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue(mediaType, forHTTPHeaderField: "Accept")
        request.addValue(mediaType, forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        
        return self.doDataTaskPublish(request: request)
    }

    /// post data to the server. A POST request with the given body data is sent to the server.
    /// The server response is parsed then converted to an object, typically AgroPolyResponse.
    ///
    /// - Parameter bodyData: the body request as data
    /// - Returns: return a AnyPublisher<T?, AgroAPIError>
    public func postThis<T: Decodable>(bodyData: Data) -> AnyPublisher<T?, AgroAPIError> {
        guard let url = urlPolyBuilder(.post, param: "") else {
            return Just<T?>(nil).setFailureType(to: AgroAPIError.self).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(mediaType, forHTTPHeaderField: "Accept")
        request.addValue(mediaType, forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        
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
   
    /// fetch the historical NDVI data from the server.
    /// The server response is parsed then converted to an object, typically [AgroHistoryNDVI]
    ///
    /// - Parameter options: the polygon id and other options specifying the request
    /// - Returns: return a AnyPublisher<T?, AgroAPIError>
    public func fetchThisHistory<T: Decodable>(options: AgroOptions) -> AnyPublisher<T?, AgroAPIError> {
        guard let url = urlHistoryBuilder(options: options) else {
            return Just<T?>(nil).setFailureType(to: AgroAPIError.self).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(mediaType, forHTTPHeaderField: "Accept")
        request.addValue(mediaType, forHTTPHeaderField: "Content-Type")
        
        return self.doDataTaskPublish(request: request)
    }

    /// fetch data from the server. A GET request with the chosen options is sent to the server.
    /// The server response is parsed then converted to an object, typically [AgroImagery].
    ///
    /// - Parameter options: the request options parameters
    /// - Returns: return a AnyPublisher<T?, AgroAPIError>
    public func fetchThis<T: Decodable>(options: AgroOptions) -> AnyPublisher<T?, AgroAPIError> {
        guard let url = urlSatBuilder(options: options) else {
            return Just<T?>(nil).setFailureType(to: AgroAPIError.self).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(mediaType, forHTTPHeaderField: "Accept")
        request.addValue(mediaType, forHTTPHeaderField: "Content-Type")
        
        return self.doDataTaskPublish(request: request)
    }
    
    /// fetch the current or forecast weather from the server.
    /// The server response is parsed then converted to an object, typically Current or [Current].
    ///
    /// - Parameter param: the id of the polygon to fetch, if empty retreive the list of all polygons
    /// - Parameter isForecast: is this for the current or forecast weather
    /// - Returns: return a AnyPublisher<T?, AgroAPIError>
    public func fetchThisWeather<T: Decodable>(param: String, isForecast: Bool, options: WeatherOptions? = nil) -> AnyPublisher<T?, AgroAPIError> {
        guard let url = urlWeatherBuilder(param: param, isForecast: isForecast, options: options) else {
            return Just<T?>(nil).setFailureType(to: AgroAPIError.self).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(mediaType, forHTTPHeaderField: "Accept")
        request.addValue(mediaType, forHTTPHeaderField: "Content-Type")
        
        return self.doDataTaskPublish(request: request)
    }

    /// fetch data from the server. A GET request with the chosen parameter is sent to the server.
    /// The server response is parsed then converted to an object, typically AgroPolyResponse or [AgroPolyResponse].
    ///
    /// - Parameter param: the id of the polygon to fetch, if empty retreive the list of all polygons
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
 
    /// fetch data from the server. A GET request with the chosen url is sent to the server.
    /// The server response is parsed then converted to an object.
    ///
    /// - Parameter urlString: the url to fetch
    /// - Returns: return a AnyPublisher<T?, AgroAPIError>
    public func fetchThisUrl<T: Decodable>(urlString: String) -> AnyPublisher<T?, AgroAPIError> {
        guard let url = URL(string: urlString) else {
            return Just<T?>(nil).setFailureType(to: AgroAPIError.self).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(mediaType, forHTTPHeaderField: "Accept")
        request.addValue(mediaType, forHTTPHeaderField: "Content-Type")
        
        return self.doDataTaskPublish(request: request)
    }
    
    /// fetch data from the server. A GET request with the chosen url is sent to the server.
    /// The server response is not parsed.
    ///
    /// - Parameter urlString: the url to fetch
    /// - Returns: return a AnyPublisher<Data?, AgroAPIError>
    public func fetchThisData(urlString: String) -> AnyPublisher<Data?, AgroAPIError> {
        guard let url = URL(string: urlString) else {
            return Just<Data?>(nil).setFailureType(to: AgroAPIError.self).eraseToAnyPublisher()
        }
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

  //              self.showPretty(data)
                
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
         print("\n----> testDecode: \(testDecode as Optional)")
         
         if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers), let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
             print("\n--->response json: " + String(decoding: jsonData, as: UTF8.self))
         } else {
             print("=========> json data malformed")
         }
     }
     
}
