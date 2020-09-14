//
//  Heap.swift
//  Heaps
//
//  Created by Greg Titus on 9/9/20.
//

import Foundation

struct Position : Comparable {
    let index: Int
    var parent: Position { Position(index: (index &- 1) &>> 1) }
    var leftChild: Position { Position(index: (index &<< 1) &+ 1) }
    var rightChild: Position { Position(index: (index &<< 1) &+ 2) }
    var isRoot: Bool { index == 0 }
    var isValid: Bool { index >= 0 }

    static let root = Position(index: 0)
    static func == (lhs: Position, rhs: Position) -> Bool { lhs.index == rhs.index }
    static func < (lhs: Position, rhs: Position) -> Bool { lhs.index < rhs.index }
}

extension UnsafeMutableBufferPointer {
    func swapAt(_ i: Position, _ j: Position) {
        swapAt(i.index, j.index)
    }
    subscript(_ i: Position) -> Element {
        get { self[i.index] }
        set { self[i.index] = newValue }
    }
    func leftChild(_ i: Position) -> Position? {
        let left = i.leftChild
        return left.index < count ? left : nil
    }
    func rightChild(_ i: Position) -> Position? {
        let right = i.rightChild
        return right.index < count ? right : nil
    }
}

extension UnsafeMutableBufferPointer {
    mutating func printDot() {
        print("digraph heap {")

        var line = ""
        for index in 0 ..< self.count {
            let position = Position(index: index)
            line.append(" \(index) [label=\"\(self[position])\"];")
            if let left = self.leftChild(position) {
                line.append(" \(index) -> \(left.index);")
            }
            if let right = self.rightChild(position) {
                line.append(" \(index) -> \(right.index);")
            }
            if line.count > 70 {
                print(line)
                line = ""
            }
        }
        if line.count > 0 {
            print(line)
        }
        print("}")
    }
}

struct Heap<Element: Comparable> {
    var contents: ContiguousArray<Element>
    var isEmpty: Bool { contents.isEmpty }
    var count: Int { contents.count }

    init() {
        contents = []
    }

    init<C: Collection>(_ collection: C) where C.Element == Element {
        let count = collection.count
        contents = ContiguousArray(unsafeUninitializedCapacity: count) { buffer, used in
            let copied = collection.withContiguousStorageIfAvailable { from -> Bool in
                buffer.baseAddress!.initialize(from: from.baseAddress!, count: count)
                return true
            }
            if copied == nil {
                _ = buffer.initialize(from: collection)
            }
            used = count
        }

        contents.withUnsafeMutableBufferPointer { buffer in
            var index = Position(index: count - 1).parent.index
            while index >= 0 {
                var downFrom = Position(index: index)
                while true {
                    guard let left = buffer.leftChild(downFrom) else { break }
                    var compare = left

                    if let right = buffer.rightChild(downFrom), buffer[right] < buffer[left] {
                        compare = right
                    }
                    guard buffer[compare] < buffer[downFrom] else { break }

                    buffer.swapAt(downFrom, compare)
                    downFrom = compare
                }
                index -= 1
            }
        }
    }

    mutating func push(_ value: Element) {
        var upFrom = Position(index: contents.count)
        contents.append(value)

        contents.withUnsafeMutableBufferPointer { buffer in
            while !upFrom.isRoot {
                let upTo = upFrom.parent
                guard buffer[upFrom] < buffer[upTo] else { break }

                buffer.swapAt(upFrom, upTo)
                upFrom = upTo
            }
        }
    }

    mutating func pop() -> Element? {
        guard !isEmpty else { return nil }
        let last = contents.removeLast()
        guard !isEmpty else { return last }

        return contents.withUnsafeMutableBufferPointer { buffer in
            let result = buffer[0]
            var downFrom = Position.root
            buffer[downFrom] = last

            while true {
                guard let left = buffer.leftChild(downFrom) else { break }
                var compare = left

                if let right = buffer.rightChild(downFrom), buffer[right] < buffer[left] {
                    compare = right
                }
                guard buffer[compare] < buffer[downFrom] else { break }

                buffer.swapAt(downFrom, compare)
                downFrom = compare
            }
            return result
        }
    }
}

extension Heap : IteratorProtocol, Sequence {
    mutating func next() -> Element? {
        return self.pop()
    }
}
