//
//  AgroWeather.swift
//  TestAgro
//
//  Created by Ringo Wathelet on 2020/07/21.
//

import Foundation


public struct Clouds: Codable {
    public let all: Int
}

public struct Wind: Codable {
    public let speed: Double
    public let deg: Int
}

public struct MainData: Codable {
    public let temp_min: Double
    public let temp_max: Double
    public let humidity: Int
    public let feels_like: Double?
    public let temp: Double?
    public let pressure: Int
    
    public let sea_level: Double?
    public let grnd_level: Double?
    public let temp_kf: Double?
}

// MARK: - Current
public struct Current: Codable {
    public let dt: Int
    public let main: MainData?
    public let wind: Wind?
    public let clouds: Clouds?
    public let weather: [Weather]
    public let rain: Rain?
    public let snow: Snow?

    enum CodingKeys: String, CodingKey {
        case dt, wind, clouds, main, weather, rain, snow
    }

    // convenience function
    public func getDate() -> Date {
        return self.dt.dateFromUTC()
    }
    
    // convenience function
    public func weatherIconName() -> String {
        return self.weather.first != nil ? self.weather.first!.iconNameFromId : "smiley"
    }
}

// MARK: - Rain
public struct Rain: Codable {
    public let the1H: Double?
    public let the3H: Double?
    
    enum CodingKeys: String, CodingKey {
        case the1H = "1h"
        case the3H = "3h"
    }

    // for the case where we have:  "rain": { }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let theRain = try? values.decode(Rain.self, forKey: .the1H) {
            self.the1H = theRain.the1H
        } else {
            self.the1H = nil
        }
        if let theRain = try? values.decode(Rain.self, forKey: .the3H) {
            self.the3H = theRain.the3H
        } else {
            self.the3H = nil
        }
    }
    
}

// MARK: - Snow
public struct Snow: Codable {
    public let the1H: Double?
    public let the3H: Double?
    
    enum CodingKeys: String, CodingKey {
        case the1H = "1h"
        case the3H = "3h"
    }

    // for the case where we have:  "snow": { }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let theSnow = try? values.decode(Snow.self, forKey: .the1H) {
            self.the1H = theSnow.the1H
        } else {
            self.the1H = nil
        }
        if let theSnow = try? values.decode(Snow.self, forKey: .the3H) {
            self.the3H = theSnow.the3H
        } else {
            self.the3H = nil
        }
    }
}

// MARK: - Weather
public struct Weather: Codable {
    public let id: Int
    public let main, weatherDescription, icon: String
    
    enum CodingKeys: String, CodingKey {
        case id, main, icon
        case weatherDescription = "description"
    }

    public var iconNameFromId: String {
        switch id {
        case 200...232:  // thunderstorm
            return "cloud.bolt.rain"
        case 300...301: // drizzle
            return "cloud.drizzle"
        case 500...531: // rain
            return "cloud.rain"
        case 600...622: // snow
            return "cloud.snow"
        case 701...781: // fog, haze, dust
            return "cloud.fog"
        case 800:       //  clear sky
            return "sun.max"
        case 801...804:
            return "cloud.sun"
        default:
            return "cloud.sun"
        }
    }
}
