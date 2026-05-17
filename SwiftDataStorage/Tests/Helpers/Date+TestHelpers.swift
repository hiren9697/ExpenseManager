//
//  File.swift
//  SwiftDataStorage
//
//  Created by Hirenkumar Fadadu on 17/05/26.
//

import Foundation

extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
