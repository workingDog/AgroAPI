//
//  AgroProvider.swift
//  AgroAPI
//
//  Created by Ringo Wathelet on 2020/07/19.
//

import Foundation
import Combine
import SwiftUI


/// provides access to the Agro API
///
/// info at: https://agromonitoring.com/api/polygons
/// and  at: https://agromonitoring.com/api/images
///
open class AgroProvider {
    
    public let client: AgroClient
    public var cancellable: AnyCancellable?
    
    public init(apiKey: String) {
        self.client = AgroClient(apiKey: apiKey)
    }
    
    open func postThis(data: Data) -> AnyPublisher<AgroPolyResponse?, AgroAPIError> {
        return client.postThis(jsonData: data)
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
        cancellable = postThis(data: jsonData)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            })
    }
    
    open func fetchThis(param: String) -> AnyPublisher<AgroPolyResponse?, AgroAPIError> {
        return client.fetchThis(param: param)
    }
    
    /// get the specific Agro polygon info from the server
    ///
    /// - Parameter id: the id of the polygon to get
    /// - Binding reponse AgroPolyResponse
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
        cancellable = fetchThis(param: id)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            })
    }
    
    open func fetchThisList(param: String) -> AnyPublisher<[AgroPolyResponse]?, AgroAPIError> {
        return client.fetchThis(param: param)
    }
    
    /// get the Agro polygon list from the server
    ///
    /// - Binding reponse AgroPolyResponse
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
        cancellable = fetchThisList(param: "")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            })
    }
    
    open func deleteThis(param: String) -> AnyPublisher<AgroPolyResponse?, AgroAPIError> {
        return client.deleteThis(param: param)
    }
    
    /// delete the specific Agro polygon from the server
    ///
    /// - Parameter id: the id of the polygon to delete
    /// - Binding reponse AgroPolyResponse
    open func deletePoly(id: String, reponse: Binding<AgroPolyResponse>) {
        deletePoly(id: id) { resp in
            if let theResponse = resp {
                reponse.wrappedValue = theResponse
            }
        }
    }
    
    /// delete the specific Agro polygon from the server
    ///
    /// - Parameter id: the id of the polygon to delete
    /// - closure completion: AgroPolyResponse
    open func deletePoly(id: String, completion: @escaping (AgroPolyResponse?) -> Void) {
        cancellable = deleteThis(param: id)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            })
    }
    
    // update info for polygon   ---> todo
    //    private func updateThis(param: String) -> AnyPublisher<AgroPolyResponse?, AgroAPIError> {
    //        return client.updateThis(param: param)
    //    }
    //
    //    // update the Agro polygon from the server
    //    open func updatePoly(id: String, reponse: Binding<AgroPolyResponse>) {
    //        cancellable = updateThis(param: id)
    //            .sink(receiveCompletion: { completion in
    //                switch completion {
    //                case .finished:
    //                    break
    //                case .failure(let error):
    //                    print(error.localizedDescription)
    //                }
    //            }, receiveValue: { resp in
    //                if let theResponse = resp {
    //                    reponse.wrappedValue = theResponse
    //                }
    //            })
    //    }
    
    
    open func fetchThis(options: AgroOptions) -> AnyPublisher<[AgroImagery]?, AgroAPIError> {
        return client.fetchThis(options: options)
    }
    
    /// get all available satellite imageries for the polygon and return the info
    ///
    /// - Parameter options: the options
    /// - Binding reponse [AgroSatResponse]
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
    /// - closure completion: [AgroSatResponse]
    open func getImagery(options: AgroOptions, completion: @escaping ([AgroImagery]?) -> Void) {
        cancellable = fetchThis(options: options)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            })
    }

    open func fetchStatsInfo(urlString: String) -> AnyPublisher<AgroStatsInfo?, AgroAPIError> {
        return client.fetchThisUrl(urlString: urlString)
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
        cancellable = fetchStatsInfo(urlString: urlString)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            })
    }
    
    open func fetchThisData(urlString: String) -> AnyPublisher<Data?, AgroAPIError> {
        return client.fetchThisData(urlString: urlString)
    }
    
    /// get the satellite imageries tile data for the polygon
    ///
    /// - Parameter urlString: the url to fetch
    /// - Binding reponse: Data
    open func getTile(urlString: String, z: Int, x: Int, y: Int, reponse: Binding<Data>) {
        getTile(urlString: urlString, z: z, x: x, y: y) { resp in
            if let theResponse = resp {
                reponse.wrappedValue = theResponse
            }
        }
    }
    
    /// get the satellite imageries tile data for the polygon
    ///
    /// - Parameter urlString: the url to fetch
    /// - closure completion: Data
    open func getTile(urlString: String, z: Int, x: Int, y: Int, completion: @escaping (Data?) -> Void) {
        let theUrl = urlString.replacingOccurrences(of: "{z}/{x}/{y}", with: "\(z)/\(x)/\(y)")
        cancellable = fetchThisData(urlString: theUrl)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            })
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
        cancellable = fetchThisData(urlString: theUrl)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { resp in
                return completion(resp)
            })
    }
    
    /// get the satellite imageries as a UIImage image for the polygon
    ///
    /// - Parameter urlString: the url to fetch
    /// - Binding reponse: UIImage
    open func getPngUIImage(urlString: String, paletteid: Int, reponse: Binding<UIImage>) {
        getPngUIImage(urlString: urlString, paletteid: paletteid) { img in
            if let uimg = img {
                reponse.wrappedValue = uimg
            }
        }
    }
    
    /// get the satellite imageries as a UIImage image for the polygon
    ///
    /// - Parameter urlString: the url to fetch
    /// - closure completion: UIImage
    open func getPngUIImage(urlString: String, paletteid: Int, completion: @escaping (UIImage?) -> Void) {
        getPngImageData(urlString: urlString, paletteid: paletteid) { data in
            if let imgData = data, let uimg = UIImage(data: imgData) {
                return completion(uimg)
            }
        }
    }

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
    
    /// get the satellite imageries of a GeoTiff image as UIImage for the polygon
    ///
    /// - Parameter urlString: the url to fetch
    /// - closure completion: Data
    open func getGeoTiffUIImage(urlString: String, paletteid: Int, completion: @escaping (UIImage?) -> Void) {
        getGeoTiffData(urlString: urlString, paletteid: paletteid) { data in
            if let imgData = data, let uimg = UIImage(data: imgData) {
                return completion(uimg)
            }
            return completion(nil)
        }
    }
    
    /// get the satellite imageries of a GeoTiff image as UIImage for the polygon
    ///
    /// - Parameter urlString: the url to fetch
    /// - Binding reponse: data
    open func getGeoTiffUIImage(urlString: String, paletteid: Int, reponse: Binding<UIImage>) {
        getGeoTiffUIImage(urlString: urlString, paletteid: paletteid) { img in
            if let theImg = img {
                reponse.wrappedValue = theImg
            }
        }
    }

}
