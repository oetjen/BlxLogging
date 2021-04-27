//
//  BlxRollingList.swift
//  BlxLogging
//
//  Created by Andreas Oetjen on 22.03.21.
//

import Foundation

class BlxRollingList<T> {
    private var maxIndex:Int
    private var backingStore = [T?]()
    private var nextIndex = 0
    
    init(capacity:Int) {
        self.maxIndex = capacity - 1
        backingStore = [T?].init(repeating: nil, count: capacity)
    }
    
    var capacity:Int { return backingStore.count }
    
    func add(_ element:T) {
        backingStore[nextIndex] = element
        nextIndex += 1
        if (nextIndex > maxIndex) {
            nextIndex = 0
        }
    }
    
    func toArray() -> [T] {
        let currentIndex = nextIndex
        let result = backingStore[currentIndex...maxIndex] + backingStore[0..<currentIndex]
        let resultWithoutNil = result.compactMap { return $0 }
        return Array(resultWithoutNil)
    }
    
    func clean() {
        nextIndex = 0
        backingStore = [T?].init(repeating: nil, count: maxIndex + 1)
    }
    
}
