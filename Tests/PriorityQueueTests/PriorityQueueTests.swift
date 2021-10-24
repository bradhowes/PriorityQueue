// Copyright © 2020 Brad Howes. All rights reserved.
//

import XCTest

@testable import PriorityQueue

final class PriorityQueueTests: XCTestCase {

  func testMinQueue() {
    var queue = PriorityQueue(1, 3, 5, 7, 9, 2, 4, 6, 8)
    XCTAssertEqual(queue.count, 9)
    XCTAssertEqual(queue.first, 1)
    XCTAssertFalse(queue.isEmpty)

    XCTAssertEqual(queue.first, 1)
    XCTAssertEqual(queue.pop()!, 1)
    XCTAssertEqual(queue.pop()!, 2)
    XCTAssertEqual(queue.pop()!, 3)
    XCTAssertEqual(queue.pop()!, 4)
    XCTAssertEqual(queue.pop()!, 5)
    XCTAssertEqual(queue.pop()!, 6)
    XCTAssertEqual(queue.pop()!, 7)
    XCTAssertEqual(queue.pop()!, 8)
    XCTAssertEqual(queue.pop()!, 9)

    XCTAssertEqual(queue.count, 0)
    XCTAssertNil(queue.pop())
    XCTAssertNil(queue.first)
    XCTAssertTrue(queue.isEmpty)
  }

  func testMaxQueue() {
    var queue = PriorityQueue(compare: PriorityQueue.maxComp, 1, 3, 5, 7, 9, 2, 4, 6, 8)
    XCTAssertEqual(queue.count, 9)
    XCTAssertEqual(queue.pop()!, 9)
    XCTAssertEqual(queue.pop()!, 8)
    XCTAssertEqual(queue.pop()!, 7)
    XCTAssertEqual(queue.pop()!, 6)
    XCTAssertEqual(queue.pop()!, 5)
    XCTAssertEqual(queue.pop()!, 4)
    XCTAssertEqual(queue.pop()!, 3)
    XCTAssertEqual(queue.pop()!, 2)
    XCTAssertEqual(queue.pop()!, 1)
    XCTAssertEqual(queue.count, 0)
    XCTAssertEqual(queue.pop(), nil)
  }

  func testPush() {
    var queue = PriorityQueue.minOrdering(1, 3, 5, 7, 9)
    print(queue)
    queue.push(2)
    print("init: \(queue)")
    XCTAssertEqual(queue.count, 6)
    XCTAssertEqual(queue.pop()!, 1)
    print("after pop1: \(queue)")
    XCTAssertEqual(queue.pop()!, 2)
    print("after pop2: \(queue)")
    XCTAssertEqual(queue.pop()!, 3)
    print("after pop3: \(queue)")

    queue.push(1)
    print("after push: \(queue)")
    XCTAssertEqual(queue.pop()!, 1)
    print("after pop4: \(queue)")
    XCTAssertEqual(queue.pop()!, 5)
    print("after pop5: \(queue)")
  }

  func testRemoveAll() {
    var queue = PriorityQueue(1, 3, 5, 7, 9)
    XCTAssertEqual(queue.count, 5)
    queue.removeAll()
    XCTAssertEqual(queue.count, 0)
  }

  func testContains() {
    let queue = PriorityQueue(1, 3, 5, 7, 9)
    XCTAssertTrue(queue.contains(5))
    XCTAssertFalse(queue.contains(6))
  }

  func testIteration() {
    var queue = PriorityQueue(9, 8, 7, 1, 2, 3, 6, 4, 5)
    XCTAssertEqual(queue.count, 9)
    print(queue)
    var counter = 1
    queue.forEach {
      XCTAssertEqual($0, counter)
      counter += 1
    }

    print(queue)
    XCTAssertEqual(queue.count, 0)
  }

  func testReplaceMinOrder() {
    var queue = PriorityQueue.minOrdering(1, 3, 5, 7, 9)
    XCTAssertEqual(queue.count, 5)
    XCTAssertEqual(queue.pop()!, 1)
    XCTAssertEqual(queue.pop()!, 3)
    XCTAssertEqual(5, queue.replace(8))
    XCTAssertEqual(queue.pop()!, 7)
    XCTAssertEqual(queue.pop()!, 8)
    XCTAssertEqual(queue.pop()!, 9)
    XCTAssertEqual(queue.count, 0)
  }

  func testReplaceMaxOrder() {
    var queue = PriorityQueue.maxOrdering(1, 3, 5, 7, 9)
    XCTAssertEqual(queue.count, 5)
    XCTAssertEqual(queue.pop()!, 9)
    XCTAssertEqual(queue.pop()!, 7)
    XCTAssertEqual(5, queue.replace(4))
    XCTAssertEqual(queue.pop()!, 4)
    XCTAssertEqual(queue.pop()!, 3)
    XCTAssertEqual(queue.pop()!, 1)
    XCTAssertEqual(queue.count, 0)
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
