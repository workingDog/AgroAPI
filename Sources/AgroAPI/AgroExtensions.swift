//
//  AgroExtensions.swift
//  AgroAPI
//
//  Created by Ringo Wathelet on 2020/07/20.
//

import Foundation


public extension Int {
    func dateFromUTC() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(self))
    }
}

public extension Date {
    
    var utc: Int {
        return Int(self.timeIntervalSince1970)
    }
    
    init(milliseconds: Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds))
    }
    
}
