//
//  MinMaxHeap.swift
//  Heaps
//
//  Created by Greg Titus on 9/9/20.
//

import Foundation

extension UnsafeMutableBufferPointer where Element: Comparable {
    func pushDownMin(index: Int) {
        var downFrom = Position(index: index)
        let count = self.count

        while true {
            let value = self[downFrom]
            let lastGrandchild = downFrom.rightChild.rightChild
            var compare = downFrom

            if lastGrandchild.index < count {
                let leftGrandIndex = downFrom.leftChild.leftChild.index
                let leftIncrement = self[leftGrandIndex] > self[leftGrandIndex &+ 1] ? 1 : 0
                let rightGrandIndex = downFrom.rightChild.leftChild.index
                let rightIncrement = self[rightGrandIndex] > self[rightGrandIndex &+ 1] ? 1 : 0

                if self[leftGrandIndex &+ leftIncrement] < self[rightGrandIndex &+ rightIncrement] {
                    compare = Position(index: leftGrandIndex &+ leftIncrement)
                } else {
                    compare = Position(index: rightGrandIndex &+ rightIncrement)
                }
                guard self[compare] < value else { break }

                self.swapAt(downFrom, compare)
                if value > self[compare.parent] {
                    self.swapAt(compare, compare.parent)
                }
                downFrom = compare
            } else {
                if let ll = self.leftChild(downFrom.leftChild) {
                    if let rl = self.leftChild(downFrom.rightChild) {
                        compare = rl
                        if self[ll] < self[compare] {
                            compare = ll
                        }
                        if self[downFrom.leftChild.rightChild] < self[compare] {
                            compare = downFrom.leftChild.rightChild
                        }
                    } else if let lr = self.rightChild(downFrom.leftChild) {
                        compare = lr
                        if self[ll] < self[compare] {
                            compare = ll
                        }
                        if self[downFrom.rightChild] < self[compare] {
                            compare = downFrom.rightChild
                        }
                    } else {
                        compare = ll
                        if self[downFrom.rightChild] < self[compare] {
                            compare = downFrom.rightChild
                        }
                    }
                } else if let l = self.leftChild(downFrom) {
                    if let r = self.rightChild(downFrom), self[r] < self[l] {
                        compare = r
                    } else {
                        compare = l
                    }
                }
                if self[compare] < value {
                    self.swapAt(downFrom, compare)
                    if compare > downFrom.rightChild, value > self[compare.parent] {
                        self.swapAt(compare, compare.parent)
                    }
                }
                break
            }
        }
    }

    func pushDownMax(index: Int) {
        var downFrom = Position(index: index)
        let count = self.count

        while true {
            let value = self[downFrom]
            let lastGrandchild = downFrom.rightChild.rightChild
            var compare = downFrom

            if lastGrandchild.index < count {
                let leftGrandIndex = downFrom.leftChild.leftChild.index
                let leftIncrement = self[leftGrandIndex] < self[leftGrandIndex &+ 1] ? 1 : 0
                let rightGrandIndex = downFrom.rightChild.leftChild.index
                let rightIncrement = self[rightGrandIndex] < self[rightGrandIndex &+ 1] ? 1 : 0

                if self[leftGrandIndex &+ leftIncrement] > self[rightGrandIndex &+ rightIncrement] {
                    compare = Position(index: leftGrandIndex &+ leftIncrement)
                } else {
                    compare = Position(index: rightGrandIndex &+ rightIncrement)
                }
                guard self[compare] > value else { break }

                self.swapAt(downFrom, compare)
                if value < self[compare.parent] {
                    self.swapAt(compare, compare.parent)
                }
                downFrom = compare
            } else {
                if let ll = self.leftChild(downFrom.leftChild) {
                    if let rl = self.leftChild(downFrom.rightChild) {
                        compare = rl
                        if self[ll] > self[compare] {
                            compare = ll
                        }
                        if self[downFrom.leftChild.rightChild] > self[compare] {
                            compare = downFrom.leftChild.rightChild
                        }
                    } else if let lr = self.rightChild(downFrom.leftChild) {
                        compare = lr
                        if self[ll] > self[compare] {
                            compare = ll
                        }
                        if self[downFrom.rightChild] > self[compare] {
                            compare = downFrom.rightChild
                        }
                    } else {
                        compare = ll
                        if self[downFrom.rightChild] > self[compare] {
                            compare = downFrom.rightChild
                        }
                    }
                } else if let l = self.leftChild(downFrom) {
                    if let r = self.rightChild(downFrom), self[r] > self[l] {
                        compare = r
                    } else {
                        compare = l
                    }
                }
                if self[compare] > value {
                    self.swapAt(downFrom, compare)
                    if compare > downFrom.rightChild, value < self[compare.parent] {
                        self.swapAt(compare, compare.parent)
                    }
                }
                break
            }
        }
    }
}

struct MinMaxHeap<Element: Comparable> {
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
            var highest = Position(index: count - 1).parent.index
            let topBitNumber = flsl(highest)
            var minLayer = (topBitNumber % 2) == 1
            var directionSwitch = Int(1 << (topBitNumber - 1)) - 1

            while highest >= 0 {
                if minLayer {
                    for index in directionSwitch ... highest {
                        buffer.pushDownMin(index: index)
                    }
                } else {
                    for index in directionSwitch ... highest {
                        buffer.pushDownMax(index: index)
                    }
                }
                highest = directionSwitch - 1
                directionSwitch /= 2
                minLayer = !minLayer
            }
        }
    }

    mutating func push(_ value: Element) {
        guard !isEmpty else { contents.append(value); return }

        var upFrom = Position(index: contents.count)
        contents.append(value)
        var minLayer = (flsl(contents.count) % 2) == 1

        contents.withUnsafeMutableBufferPointer { buffer in
            let parent = upFrom.parent
            if minLayer && buffer[parent] < value {
                buffer.swapAt(upFrom, parent)
                minLayer = !minLayer
                upFrom = parent
            } else if !minLayer && buffer[parent] > value {
                buffer.swapAt(upFrom, parent)
                minLayer = !minLayer
                upFrom = parent
            }

            if minLayer {
                while true {
                    let upTo = upFrom.parent.parent
                    guard upTo.isValid else { break }
                    guard buffer[upFrom] < buffer[upTo] else { break }

                    buffer.swapAt(upFrom, upTo)
                    upFrom = upTo
                }
            } else {
                while true {
                    let upTo = upFrom.parent.parent
                    guard upTo.isValid else { break }
                    guard buffer[upFrom] > buffer[upTo] else { break }

                    buffer.swapAt(upFrom, upTo)
                    upFrom = upTo
                }
            }
        }
    }

    mutating func popMin() -> Element? {
        switch contents.count {
        case 0:
            return nil
        case 1:
            return contents.removeLast()
        default:
            let result = contents[0]
            contents[0] = contents.removeLast()

            contents.withUnsafeMutableBufferPointer { buffer in
                buffer.pushDownMin(index: 0)
            }
            return result
        }
    }

    mutating func popMax() -> Element? {
        switch contents.count {
        case 0:
            return nil
        case 1, 2:
            return contents.removeLast()
        case 3:
            if contents[1] > contents[2] {
                let result = contents[1]
                contents[1] = contents.removeLast()
                return result
            } else {
                return contents.removeLast()
            }
        default:
            let index = contents[1] > contents[2] ? 1 : 2
            let last = contents.removeLast()
            let result = contents[index]
            contents[index] = last
            contents.withUnsafeMutableBufferPointer { buffer in
                buffer.pushDownMax(index: index)
            }
            return result
        }
    }

}

extension MinMaxHeap : IteratorProtocol, Sequence {
    mutating func next() -> Element? {
        return self.popMin()
    }
}

extension MinMaxHeap {
    mutating func checkInvariants() -> Position? {
        return contents.withUnsafeMutableBufferPointer { buffer in
            func check(_ position: Position, _ interval: ClosedRange<Element>, minLayer: Bool) -> Position? {
                let value = buffer[position]

                guard interval.contains(value) else {
                    print("position \(position.index): \(value) invariants broken: \(interval)")
                    return position
                }

                let newInterval = minLayer ? value ... interval.upperBound : interval.lowerBound ... value
                if let left = buffer.leftChild(position), let broken = check(left, newInterval, minLayer: !minLayer) {
                    return broken
                }
                if let right = buffer.rightChild(position), let broken = check(right, newInterval, minLayer: !minLayer) {
                    return broken
                }
                return nil
            }

            switch buffer.count {
            case 0, 1:
                return nil
            case 2:
                guard buffer[0] < buffer[1] else { return .root }
                return nil
            default:
                let lower = buffer[0]
                let upper = Swift.max(buffer[1], buffer[2])
                return check(.root, lower ... upper, minLayer: true)
            }
        }
    }
}
