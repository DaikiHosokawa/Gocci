//
//  Algorithms.swift
//  Gocci
//
//  Created by Ma Wa on 27.11.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation

class Algorithms {
    class func findNearestNumber<T: SignedIntegerType>(reference: T, set: [T]) -> T? {
        if set.isEmpty { return nil }
        
        var best = set.first!
        for i in set {
            if abs(reference - i) < abs(reference - best) {
                best = i
            }
        }
        
        return best
    }
}
