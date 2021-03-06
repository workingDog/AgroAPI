//
//  AgroProvider.swift
//  AgroAPI
//
//  Created by Ringo Wathelet on 2020/07/19.
//

import Foundation
import Combine
import SwiftUI

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

/// provides access to the Agro API, for both Polygons and Satellite imagery API
///
/// info at: https://agromonitoring.com/api/polygons
/// and  at: https://agromonitoring.com/api/images
///
open class AgroProvider {
    
    public let client: AgroClient
    public var cancellables = Set<AnyCancellable>()
    
    public init(apiKey: String) {
        self.client = AgroClient(apiKey: apiKey)
    }
    
    /// send an Agro polygon to the server and return the server response
    ///
    /// - Parameter poly: the polygon to send
    /// - Binding reponse AgroPolyResponse
    open func createPoly(poly: AgroPolygon, reponse: Binding<AgroPolyResponse>) {
        createPoly(poly: poly) { resp in
            if let theResponse = resp {
                reponse.wrappedValue = theResponse
            }
        }
    }
    
    /// send an Agro polygon to the server and return the server response
    ///
    /// - Parameter poly: the polygon to send
    /// - closure completion: AgroPolyResponse
    open func createPoly(poly: AgroPolygon, completion: @escaping (AgroPolyResponse?) -> Void) {
        let jsonData = (try? JSONEncoder().encode(poly)) ?? Data()
        client.postThis(bodyData: jsonData)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            }).store(in: &cancellables)
    }

    /// get the specific Agro polygon info from the server
    ///
    /// - Parameter id: the id of the polygon to get
    /// - Binding reponse: AgroPolyResponse
    open func getPoly(id: String, reponse: Binding<AgroPolyResponse>) {
        getPoly(id: id) { resp in
            if let theResponse = resp {
                reponse.wrappedValue = theResponse
            }
        }
    }
    
    /// get the specific Agro polygon info from the server
    ///
    /// - Parameter id: the id of the polygon to get
    /// - closure completion: AgroPolyResponse
    open func getPoly(id: String, completion: @escaping (AgroPolyResponse?) -> Void) {
        client.fetchThis(param: id)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            }).store(in: &cancellables)
    }
    
    /// get the Agro polygon list from the server
    ///
    /// - Binding reponse: AgroPolyResponse
    open func getPolyList(reponse: Binding<[AgroPolyResponse]>) {
        getPolyList() { resp in
            if let theResponse = resp {
                reponse.wrappedValue = theResponse
            }
        }
    }
    
    /// get the Agro polygon list from the server
    ///
    /// - closure completion: [AgroPolyResponse]
    open func getPolyList(completion: @escaping ([AgroPolyResponse]?) -> Void) {
       client.fetchThis(param: "")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            }).store(in: &cancellables)
    }
    
    /// delete the specific Agro polygon from the server
    ///
    /// - Parameter id: the id of the polygon to delete
    open func deletePoly(id: String) {
        deletePoly(id: id) { _ in }
    }
    
    /// delete the specific Agro polygon from the server
    ///
    /// - Parameter id: the id of the polygon to delete
    /// - closure completion: expect a nil AgroPolyResponse when successful
    open func deletePoly(id: String, completion: @escaping (AgroPolyResponse?) -> Void) {
        client.deleteThis(param: id)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            }).store(in: &cancellables)
    }
    
    // update info for polygon   ---> todo
    private func updateThis(id: String, name: String) -> AnyPublisher<AgroPolyResponse?, AgroAPIError> {
        let json = """
        {
           "geo_json": {
              "something": "something"
           },
           "name": "\(name)"
        }
        """
        let bodyData = json.data(using: .utf8)
        return client.putThis(bodyData: bodyData!, param: id)
    }
    
    /// update the specific Agro polygon name on the server
    ///
    /// - Parameter id: the id of the polygon to change
    /// - Parameter name: the new name of the polygon
    /// - closure completion: AgroPolyResponse
    open func updatePoly(id: String, name: String, reponse: Binding<AgroPolyResponse>) {
        updatePoly(id: id, name: name) { resp in
            if let theResponse = resp {
                reponse.wrappedValue = theResponse
            }
        }
    }
    
    /// update the specific Agro polygon name on the server
    ///
    /// - Parameter id: the id of the polygon to change
    /// - Parameter name: the new name of the polygon
    /// - closure completion: AgroPolyResponse
    open func updatePoly(id: String, name: String, completion: @escaping (AgroPolyResponse?) -> Void) {
        updateThis(id: id, name: name)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            }).store(in: &cancellables)
    }

    /// get all available satellite imageries for the polygon and return the info
    ///
    /// - Parameter options: the options
    /// - Binding reponse: [AgroImagery]
    open func getImagery(options: AgroOptions, reponse: Binding<[AgroImagery]>) {
        getImagery(options: options) { resp in
            if let theResponse = resp {
                reponse.wrappedValue = theResponse
            }
        }
    }
    
    /// get all available satellite imageries for the polygon and return the info
    ///
    /// - Parameter options: the options
    /// - closure completion: [AgroImagery]
    open func getImagery(options: AgroOptions, completion: @escaping ([AgroImagery]?) -> Void) {
        client.fetchThis(options: options)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            }).store(in: &cancellables)
    }

    /// get the satellite imageries stats for the polygon
    ///
    /// - Parameter urlString: the url to fetch
    /// - Binding reponse: AgroStatsInfo
    open func getStatsInfo(urlString: String, reponse: Binding<AgroStatsInfo>) {
        getStatsInfo(urlString: urlString) { resp in
            if let theResponse = resp {
                reponse.wrappedValue = theResponse
            }
        }
    }
    
    /// get the satellite imageries stats for the polygon
    ///
    /// - Parameter urlString: the url to fetch
    /// - closure completion: AgroStatsInfo
    open func getStatsInfo(urlString: String, completion: @escaping (AgroStatsInfo?) -> Void) {
        client.fetchThisUrl(urlString: urlString)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            }).store(in: &cancellables)
    }

    /// get the satellite imageries tile data for the polygon
    ///
    /// - Parameter urlString: the url to fetch
    /// - Binding reponse: Data
    open func getTile(urlString: String, reponse: Binding<Data>) {
        getTile(urlString: urlString) { resp in
            if let theResponse = resp {
                reponse.wrappedValue = theResponse
            }
        }
    }
    
    /// get the satellite imageries tile data for the polygon
    ///
    /// - Parameter urlString: the url to fetch
    /// - closure completion: Data
    open func getTile(urlString: String, completion: @escaping (Data?) -> Void) {
        client.fetchThisData(urlString: urlString)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            }).store(in: &cancellables)
    }
    
    /// get the satellite imageries PNG image data for the polygon
    ///
    /// - Parameter urlString: the url to fetch
    /// - Binding reponse: Data
    open func getPngImageData(urlString: String, paletteid: Int, reponse: Binding<Data>) {
        getPngImageData(urlString: urlString, paletteid: paletteid) { resp in
            if let theResponse = resp {
                reponse.wrappedValue = theResponse
            }
        }
    }
 
    /// get the satellite imageries PNG image data for the polygon
    ///
    /// - Parameter urlString: the url to fetch
    /// - closure completion: Data
    open func getPngImageData(urlString: String, paletteid: Int, completion: @escaping (Data?) -> Void) {
        let theUrl = urlString + "&paletteid=\(paletteid)"
        client.fetchThisData(urlString: theUrl)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            }).store(in: &cancellables)
    }
    
    /// get the satellite imageries as a UIImage/NSImage image for the polygon
    ///
    /// - Parameter urlString: the url to fetch
    /// - Binding reponse: UIImage/NSImage
    #if os(iOS)
    open func getPngUIImage(urlString: String, paletteid: Int, reponse: Binding<UIImage>) {
        getPngUIImage(urlString: urlString, paletteid: paletteid) { img in
            if let uimg = img {
                reponse.wrappedValue = uimg
            }
        }
    }
    #elseif os(OSX)
    open func getPngUIImage(urlString: String, paletteid: Int, reponse: Binding<NSImage>) {
        getPngNSImage(urlString: urlString, paletteid: paletteid) { img in
            if let uimg = img {
                reponse.wrappedValue = uimg
            }
        }
    }
    #endif

    /// get the satellite imageries as a UIImage/NSImage image for the polygon
    ///
    /// - Parameter urlString: the url to fetch
    /// - closure completion: UIImage
    #if os(iOS)
    open func getPngUIImage(urlString: String, paletteid: Int, completion: @escaping (UIImage?) -> Void) {
        getPngImageData(urlString: urlString, paletteid: paletteid) { data in
            if let imgData = data, let uimg = UIImage(data: imgData) {
                return completion(uimg)
            }
        }
    }
    #elseif os(OSX)
    open func getPngNSImage(urlString: String, paletteid: Int, completion: @escaping (NSImage?) -> Void) {
        getPngImageData(urlString: urlString, paletteid: paletteid) { data in
            if let imgData = data, let uimg = NSImage(data: imgData) {
                return completion(uimg)
            }
        }
    }
    #endif

    /// get the satellite imageries of a GeoTiff image data for the polygon
    ///
    /// - Parameter urlString: the url to fetch
    /// - closure completion: Data
    open func getGeoTiffData(urlString: String, paletteid: Int, completion: @escaping (Data?) -> Void) {
        getPngImageData(urlString: urlString, paletteid: paletteid) { data in
            return completion(data)
        }
    }
    
    /// get the satellite imageries of a GeoTiff image data for the polygon
    ///
    /// - Parameter urlString: the url to fetch
    /// - Binding reponse: data
    open func getGeoTiffData(urlString: String, paletteid: Int, reponse: Binding<Data>) {
        getGeoTiffData(urlString: urlString, paletteid: paletteid) { data in
            if let theData = data {
                reponse.wrappedValue = theData
            }
        }
    }
    
    /// get the satellite imageries of a GeoTiff image as UIImage/NSImage for the polygon
    ///
    /// - Parameter urlString: the url to fetch
    /// - closure completion: UIImage/NSImage
    #if os(iOS)
    open func getGeoTiffUIImage(urlString: String, paletteid: Int, completion: @escaping (UIImage?) -> Void) {
        getGeoTiffData(urlString: urlString, paletteid: paletteid) { data in
            if let imgData = data, let uimg = UIImage(data: imgData) {
                return completion(uimg)
            }
            return completion(nil)
        }
    }
    #elseif os(OSX)
    open func getGeoTiffNSImage(urlString: String, paletteid: Int, completion: @escaping (NSImage?) -> Void) {
        getGeoTiffData(urlString: urlString, paletteid: paletteid) { data in
            if let imgData = data, let uimg = NSImage(data: imgData) {
                return completion(uimg)
            }
            return completion(nil)
        }
    }
    #endif

    /// get the satellite imageries of a GeoTiff image as UIImage/NSImage for the polygon
    ///
    /// - Parameter urlString: the url to fetch
    /// - Binding reponse: UIImage
    #if os(iOS)
    open func getGeoTiffUIImage(urlString: String, paletteid: Int, reponse: Binding<UIImage>) {
        getGeoTiffUIImage(urlString: urlString, paletteid: paletteid) { img in
            if let theImg = img {
                reponse.wrappedValue = theImg
            }
        }
    }
    #elseif os(OSX)
    open func getGeoTiffNSImage(urlString: String, paletteid: Int, reponse: Binding<NSImage>) {
        getGeoTiffNSImage(urlString: urlString, paletteid: paletteid) { img in
            if let theImg = img {
                reponse.wrappedValue = theImg
            }
        }
    }
    #endif

    /// get the current weather for the polygon
    ///
    /// - Parameter param: the polygon id
    /// - closure completion: Current weather
    open func getCurrentWeather(id: String, completion: @escaping (Current?) -> Void) {
        client.fetchThisWeather(param: id, isForecast: false)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            }).store(in: &cancellables)
    }
    
    /// get the current weather for the polygon
    ///
    /// - Parameter param: the polygon id
    /// - Binding reponse: UIImage
    open func getCurrentWeather(id: String, reponse: Binding<Current>) {
        getCurrentWeather(id: id) { weather in
            if let theWeather = weather {
                reponse.wrappedValue = theWeather
            }
        }
    }

    /// get the forecast weather for the polygon
    ///
    /// - Parameter param: the polygon id
    /// - closure completion: Current weather
    open func getForecastWeather(id: String, completion: @escaping ([Current]?) -> Void) {
        client.fetchThisWeather(param: id, isForecast: true)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            }).store(in: &cancellables)
    }
    
    open func getForecastWeather(id: String, reponse: Binding<[Current]>) {
        getForecastWeather(id: id) { forecast in
            if let theForecast = forecast {
                reponse.wrappedValue = theForecast
            }
        }
    }
    
    /// get the historical weather for the polygon
    ///
    /// - Parameter param: the polygon id
    /// - closure completion: Current weather
    open func getHistoricalWeather(options: WeatherOptions, completion: @escaping ([Current]?) -> Void) {
        client.fetchThisWeather(param: options.polygon_id, isForecast: true, options: options)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            }).store(in: &cancellables)
    }
    
    open func getHistoricalWeather(options: WeatherOptions, reponse: Binding<[Current]>) {
        getHistoricalWeather(options: options) { forecast in
            if let theForecast = forecast {
                reponse.wrappedValue = theForecast
            }
        }
    }

    /// get the historical NDVI for the polygon
    ///
    /// - Parameter options: options for the request
    /// - closure completion: historical NDVI
    open func getHistoricalNDVI(options: AgroOptions, completion: @escaping ([AgroHistoryNDVI]?) -> Void) {
        client.fetchThisHistory(options: options)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            }).store(in: &cancellables)
    }
    
    open func getHistoricalNDVI(options: AgroOptions, reponse: Binding<[AgroHistoryNDVI]>) {
        getHistoricalNDVI(options: options) { hndvi in
            if let theHist = hndvi {
                reponse.wrappedValue = theHist
            }
        }
    }
    
    open func clearCancellables() {
        self.cancellables.forEach{ $0.cancel() }
        self.cancellables = Set<AnyCancellable>()
    }
    
}
