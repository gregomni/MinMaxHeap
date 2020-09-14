//
//  HeapsTest.swift
//  HeapsTest
//
//  Created by Greg Titus on 9/9/20.
//

import XCTest

class HeapsTest: XCTestCase {
    let testSize = 1000000

    private func randomArray(of size: Int? = nil) -> Array<Int> {
        let size = size ?? testSize
        return (1 ... size).shuffled()
    }

    private func checkInOrder<T: IteratorProtocol>(_ input: T) where T.Element : Comparable {
        var heap = input
        guard var previous = heap.next() else { return }
        repeat {
            guard let current = heap.next() else { return }
            XCTAssert(previous <= current)
            previous = current
        } while true
    }

    func testHeapInitVsPush() {
        let array = randomArray()
        var heap1 = Heap(array)
        var heap2 = Heap<Int>()

        for i in array {
            heap2.push(i)
        }
        while let i1 = heap1.pop() {
            XCTAssertEqual(i1, heap2.pop())
        }
    }

    func testHeapInitAndIterate() {
        let array = randomArray()
        var heap = Heap<Int>()
        measure {
            heap = Heap(array)

            var copy = heap
            while let _ = copy.pop() {}
        }
        XCTAssertEqual(heap.count, testSize)
        checkInOrder(heap)
    }

    func testMinMaxHeapInitAndPopMin() {
        let array = randomArray()
        var heap = MinMaxHeap<Int>()

        measure {
            heap = MinMaxHeap(array)
            while let _ = heap.popMin() {}
        }
    }

    func testMinMaxHeapInitAndPopMax() {
        let array = randomArray()
        var heap = MinMaxHeap<Int>()

        measure {
            heap = MinMaxHeap(array)
            while let _ = heap.popMax() {}
        }
    }

    func testMinMaxHeapInsertHalfPopOne() {
        let array = randomArray()
        measure {
            var heap = MinMaxHeap<Int>()
            for i in array[0 ..< testSize/2] {
                heap.push(i)
            }
            _ = heap.popMin()
            for i in array[testSize/2 ..< testSize] {
                heap.push(i)
            }
            while let _ = heap.popMin() {}
        }
    }

    func testArraySortAndIterate() {
        let array = randomArray()
        measure {
            var result = array
            result.sort()
            for _ in result {}
        }
        XCTAssertEqual(array.count, testSize)
    }

    func testArrayInsertHalfPopOne() {
        let array = randomArray()
        measure {
            var result: [Int] = []
            for i in array[0 ..< testSize/2] {
                result.append(i)
            }
            result.sort()
            _ = result.removeLast()
            for i in array[testSize/2 ..< testSize] {
                result.append(i)
            }
            result.sort()
            for _ in array {}
        }
    }
}
