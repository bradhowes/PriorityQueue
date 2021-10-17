// Copyright © 2020 Brad Howes. All rights reserved.
//

import XCTest

@testable import PriorityQueue

final class PriorityQueueTests: XCTestCase {

  func testMinQueue() {
    var pq = PriorityQueue(1, 3, 5, 7, 9, 2, 4, 6, 8)
    XCTAssertEqual(pq.count, 9)
    XCTAssertEqual(pq.first, 1)
    XCTAssertFalse(pq.isEmpty)

    XCTAssertEqual(pq.first, 1)
    XCTAssertEqual(pq.pop()!, 1)
    XCTAssertEqual(pq.pop()!, 2)
    XCTAssertEqual(pq.pop()!, 3)
    XCTAssertEqual(pq.pop()!, 4)
    XCTAssertEqual(pq.pop()!, 5)
    XCTAssertEqual(pq.pop()!, 6)
    XCTAssertEqual(pq.pop()!, 7)
    XCTAssertEqual(pq.pop()!, 8)
    XCTAssertEqual(pq.pop()!, 9)

    XCTAssertEqual(pq.count, 0)
    XCTAssertNil(pq.pop())
    XCTAssertNil(pq.first)
    XCTAssertTrue(pq.isEmpty)
  }

  func testMaxQueue() {
    var pq = PriorityQueue(compare: PriorityQueue.maxComp, 1, 3, 5, 7, 9, 2, 4, 6, 8)
    XCTAssertEqual(pq.count, 9)
    XCTAssertEqual(pq.pop()!, 9)
    XCTAssertEqual(pq.pop()!, 8)
    XCTAssertEqual(pq.pop()!, 7)
    XCTAssertEqual(pq.pop()!, 6)
    XCTAssertEqual(pq.pop()!, 5)
    XCTAssertEqual(pq.pop()!, 4)
    XCTAssertEqual(pq.pop()!, 3)
    XCTAssertEqual(pq.pop()!, 2)
    XCTAssertEqual(pq.pop()!, 1)
    XCTAssertEqual(pq.count, 0)
    XCTAssertEqual(pq.pop(), nil)
  }

  func testPush() {
    var pq = PriorityQueue.minOrdering(1, 3, 5, 7, 9)
    print(pq)
    pq.push(2)
    print("init: \(pq)")
    XCTAssertEqual(pq.count, 6)
    XCTAssertEqual(pq.pop()!, 1)
    print("after pop1: \(pq)")
    XCTAssertEqual(pq.pop()!, 2)
    print("after pop2: \(pq)")
    XCTAssertEqual(pq.pop()!, 3)
    print("after pop3: \(pq)")

    pq.push(1)
    print("after push: \(pq)")
    XCTAssertEqual(pq.pop()!, 1)
    print("after pop4: \(pq)")
    XCTAssertEqual(pq.pop()!, 5)
    print("after pop5: \(pq)")
  }

  func testRemoveAll() {
    var pq = PriorityQueue(1, 3, 5, 7, 9)
    XCTAssertEqual(pq.count, 5)
    pq.removeAll()
    XCTAssertEqual(pq.count, 0)
  }

  func testContains() {
    let pq = PriorityQueue(1, 3, 5, 7, 9)
    XCTAssertTrue(pq.contains(5))
    XCTAssertFalse(pq.contains(6))
  }

  func testIteration() {
    var pq = PriorityQueue(9, 8, 7, 1, 2, 3, 6, 4, 5)
    XCTAssertEqual(pq.count, 9)
    print(pq)
    var counter = 1
    pq.forEach {
      XCTAssertEqual($0, counter)
      counter += 1
    }

    print(pq)
    XCTAssertEqual(pq.count, 0)
  }

  func testReplaceMinOrder() {
    var pq = PriorityQueue.minOrdering(1, 3, 5, 7, 9)
    XCTAssertEqual(pq.count, 5)
    XCTAssertEqual(pq.pop()!, 1)
    XCTAssertEqual(pq.pop()!, 3)
    XCTAssertEqual(5, pq.replace(8))
    XCTAssertEqual(pq.pop()!, 7)
    XCTAssertEqual(pq.pop()!, 8)
    XCTAssertEqual(pq.pop()!, 9)
    XCTAssertEqual(pq.count, 0)
  }

  func testReplaceMaxOrder() {
    var pq = PriorityQueue.maxOrdering(1, 3, 5, 7, 9)
    XCTAssertEqual(pq.count, 5)
    XCTAssertEqual(pq.pop()!, 9)
    XCTAssertEqual(pq.pop()!, 7)
    XCTAssertEqual(5, pq.replace(4))
    XCTAssertEqual(pq.pop()!, 4)
    XCTAssertEqual(pq.pop()!, 3)
    XCTAssertEqual(pq.pop()!, 1)
    XCTAssertEqual(pq.count, 0)
  }

  class Entry: Comparable {
    static func < (lhs: PriorityQueueTests.Entry, rhs: PriorityQueueTests.Entry) -> Bool { lhs.weight < rhs.weight }
    static func == (lhs: PriorityQueueTests.Entry, rhs: PriorityQueueTests.Entry) -> Bool { lhs === rhs }

    var weight: Int
    init(_ weight: Int) { self.weight = weight }
  }

  static var allTests = [
    ("testMinQueue", testMinQueue),
    ("testMaxQueue", testMaxQueue),
    ("testPush", testPush),
    ("testRemoveAll", testRemoveAll),
    ("testContains", testContains),
    ("testIteration", testIteration),
    ("testReplaceMinOrder", testReplaceMinOrder),
    ("testReplaceMaxOrder", testReplaceMaxOrder),
  ]
}
