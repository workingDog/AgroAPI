//
//  AgroPolyProtocol.swift
//  AgroAPI
//
//  Created by Ringo Wathelet on 2020/07/19.
//

import Foundation


/// geojson Feature
public struct Feature: Codable {
    public let type: String
    public let properties: Properties
    public let geometry: Geometry
}

/// geojson Geometry
public struct Geometry: Codable {
    public let type: String
    public let coordinates: [[[Double]]]
}

/// geojson Properties
public struct Properties: Codable {
    public let name: String?
}

/// a server response to a AgroPolygon request
public struct AgroPolyResponse: Codable {
    public let id: String          // The internal ID of the polygon you get during creation (string)
    public let name: String        // The name of the polygon
    public let user_id: String     // the user id
    public let area: Double        // hectares
    public let center: [Double]    // The central point of the polygon, the average of [lat, lon] over all points (array)
    public let geo_json: Feature   // Coordinates the polygon in GeoJSON format
    public let created_at: Int?    // the UTC timestamp
}

/// Agro Polygon
/// When creating a polygon, the first and last positions are equivalent, and MUST contain identical values.
public struct AgroPolygon: Codable {
    public let name: String
    public let geo_json: Feature
    
    init(name: String, coords: [[[Double]]]) {
        self.name = name
        let prop = Properties(name: nil)
        let geom = Geometry(type: "Polygon", coordinates: coords)
        self.geo_json = Feature(type: "Feature", properties: prop, geometry: geom)
    }

    /// check that the coords are polygons, and that the first and last positions of all polygons contain the same value.
    func isValidPoly() -> Bool {
        for coords in geo_json.geometry.coordinates {
            if coords.count < 3 { return false }
            if coords.first != coords.last { return false }
        }
        return true
    }
    
}

/// a server response to a Agro satellite request for imagery
public struct AgroImagery: Codable {
    public let dt: Int?
    public let type: String?
    public let dc: Int?
    public let cl: Double?
    public let sun: AgroSun?
    public let stats: AgroStats?
    public let image: AgroSatUrl?
    public let tile: AgroSatUrl?
    public let data: AgroSatUrl?
}

/// AgroSatUrl
public struct AgroSatUrl: Codable {
    public let truecolor: String?
    public let falsecolor: String?
    public let ndvi: String?
    public let evi: String?
    public let dswi: String?
    public let ndwi: String?
    public let nri: String?
    public let evi2: String?
}

/// AgroStats
public struct AgroStats: Codable {
    public let ndvi: String?
    public let evi: String?
}

/// AgroSun
public struct AgroSun: Codable {
    public let azimuth: Double?
    public let elevation: Double?
}

/// AgroStatsInfo
public struct AgroStatsInfo: Codable {
    public let std: Double?
    public let p25: Double?
    public let num: Int?
    public let min: Double?
    public let max: Double?
    public let median: Double?
    public let p75: Double?
    public let mean: Double?  
}

/// Options to use for searching for satellite images of a polygon
public class AgroOptions {
    
    public var polygon_id: String
    public var start: Int
    public var end: Int
    
    public var resolution_min: Int?
    public var resolution_max: Int?
    public var type: String?
    public var coverage_max: Double?
    public var coverage_min: Double?
    public var clouds_max: Double?
    public var clouds_min: Double?
    
    public init(polygon_id: String, start: Int, end: Int,
                resolution_min: Int? = nil,
                resolution_max: Int? = nil,
                type: String? = nil,
                coverage_max: Double? = nil,
                coverage_min: Double? = nil,
                clouds_max: Double? = nil,
                clouds_min: Double? = nil) {
        self.polygon_id = polygon_id
        self.start = start
        self.end = end
        self.resolution_min = resolution_min
        self.resolution_max = resolution_max
        self.type = type
        self.coverage_max = coverage_max
        self.coverage_min = coverage_min
        self.clouds_max = clouds_max
        self.clouds_min = clouds_min
    }
    
    public func toParamString() -> String {
        var stringer = ""
        // required
        stringer += "polygon_id=" + polygon_id
        stringer += "&start=" + String(start)
        stringer += "&end=" + String(end)
        // optionals
        if let resolution_min = resolution_min {
            stringer += "&resolution_min=" + String(resolution_min)
        }
        if let resolution_max = resolution_min {
            stringer += "&resolution_max=" + String(resolution_max)
        }
        if let type = type {
            stringer += "&type=" + type
        }
        if let coverage_max = coverage_max {
            stringer += "&coverage_max=" + String(coverage_max)
        }
        if let coverage_min = coverage_min {
            stringer += "&coverage_min=" + String(coverage_min)
        }
        if let clouds_max = clouds_max {
            stringer += "&clouds_max=" + String(clouds_max)
        }
        if let clouds_min = clouds_min {
            stringer += "&clouds_min=" + String(clouds_min)
        }
        return stringer
    }
}


