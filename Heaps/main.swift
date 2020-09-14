//
//  main.swift
//  Heaps
//
//  Created by Greg Titus on 9/9/20.
//

import Foundation

private func randomArray(of size: Int? = nil) -> Array<Int> {
    let size = size ?? 1000
    /*
    var result: [Int] = []
    for _ in 1 ... size {
        result.append(Int.random(in: 0 ... 1000))
    }*/
    let result = (1 ... size).shuffled()
    return result
}

var heap = MinMaxHeap<Int>(randomArray())
if let error = heap.checkInvariants() {
    print("invariants broken at \(error.index)")
}
var previous = heap.popMin()!
while let x = heap.popMin() {
    if x < previous {
        print("\(x) < \(previous)")
    }
    previous = x
}

