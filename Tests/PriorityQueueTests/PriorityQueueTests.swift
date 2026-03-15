// Copyright © 2020 Brad Howes. All rights reserved.
//

import PriorityQueue
import Testing

@Suite("PriorityQueue")
struct PriorityQueueTests {

  @Test
  func minQueue() throws {
    var queue = PriorityQueue(1, 3, 5, 5, 9, 2, 4, 6, 8)
    #expect(queue.count == 9)
    #expect(queue.first == 1)
    #expect(!queue.isEmpty)

    #expect(queue.first == 1)
    #expect(queue.pop()! == 1)
    try queue.validateHeapProperty()
    #expect(queue.pop()! == 2)
    try queue.validateHeapProperty()
    #expect(queue.pop()! == 3)
    try queue.validateHeapProperty()
    #expect(queue.pop()! == 4)
    try queue.validateHeapProperty()
    #expect(queue.pop()! == 5)
    try queue.validateHeapProperty()
    #expect(queue.pop()! == 5)
    try queue.validateHeapProperty()
    #expect(queue.pop()! == 6)
    try queue.validateHeapProperty()
    #expect(queue.pop()! == 8)
    try queue.validateHeapProperty()
    #expect(queue.pop()! == 9)
    try queue.validateHeapProperty()

    #expect(queue.count == 0)
    #expect(queue.pop() == nil)
    #expect(queue.first == nil)
    #expect(queue.isEmpty)
  }

  @Test
  func maxQueue() throws {
    var queue = PriorityQueue(compare: >, 1, 3, 5, 7, 9, 2, 4, 6, 8)
    #expect(queue.count == 9)
    #expect(queue.pop()! == 9)
    try queue.validateHeapProperty()
    #expect(queue.pop()! == 8)
    try queue.validateHeapProperty()
    #expect(queue.pop()! == 7)
    try queue.validateHeapProperty()
    #expect(queue.pop()! == 6)
    try queue.validateHeapProperty()
    #expect(queue.pop()! == 5)
    try queue.validateHeapProperty()
    #expect(queue.pop()! == 4)
    try queue.validateHeapProperty()
    #expect(queue.pop()! == 3)
    try queue.validateHeapProperty()
    #expect(queue.pop()! == 2)
    try queue.validateHeapProperty()
    #expect(queue.pop()! == 1)
    try queue.validateHeapProperty()
    #expect(queue.count == 0)
    #expect(queue.pop() == nil)
  }

  @Test
  func push() throws {
    var queue = PriorityQueue.minOrdering(1, 3, 5, 7, 9)
    try queue.validateHeapProperty()
    queue.push(2)
    try queue.validateHeapProperty()
    #expect(queue.count == 6)
    #expect(queue.pop()! == 1)
    try queue.validateHeapProperty()
    #expect(queue.pop()! == 2)
    try queue.validateHeapProperty()
    #expect(queue.pop()! == 3)
    try queue.validateHeapProperty()

    queue.push(1)
    try queue.validateHeapProperty()
    #expect(queue.pop()! == 1)
    try queue.validateHeapProperty()
    #expect(queue.pop()! == 5)
    try queue.validateHeapProperty()
  }

  @Test
  func removeAll() throws {
    var queue = PriorityQueue(1, 3, 5, 7, 9)
    try queue.validateHeapProperty()
    #expect(queue.count == 5)
    queue.removeAll()
    #expect(queue.count == 0)
  }

  @Test
  func contains() {
    let queue = PriorityQueue(1, 3, 5, 7, 9)
    #expect(queue.contains(5))
    #expect(!queue.contains(6))
  }

  @Test
  func iteration() throws {
    var queue = PriorityQueue(9, 8, 7, 1, 2, 3, 6, 4, 5)
    try queue.validateHeapProperty()
    #expect(queue.count == 9)
    var counter = 1
    queue.forEach {
      #expect($0 == counter)
      counter += 1
    }

    #expect(queue.count == 0)
  }

  @Test
  func replaceMinOrder() throws {
    var queue = PriorityQueue.minOrdering(3, 1, 9, 7, 5)
    try queue.validateHeapProperty()
    #expect(queue.count == 5)
    #expect(queue.pop() == 1)
    try queue.validateHeapProperty()
    #expect(queue.pop() == 3)
    try queue.validateHeapProperty()
    #expect(queue.replace(8) == 5)
    try queue.validateHeapProperty()
    #expect(queue.pop() == 7)
    try queue.validateHeapProperty()
    #expect(queue.pop() == 8)
    try queue.validateHeapProperty()
    #expect(queue.pop() == 9)
    try queue.validateHeapProperty()
    #expect(queue.count == 0)
  }

  @Test
  func replaceMaxOrder() throws {
    var queue = PriorityQueue.maxOrdering(3, 1, 5, 9, 7)
    try queue.validateHeapProperty()
    #expect(queue.count == 5)
    #expect(queue.pop() == 9)
    try queue.validateHeapProperty()
    #expect(queue.pop() == 7)
    try queue.validateHeapProperty()
    #expect(queue.replace(4) == 5)
    try queue.validateHeapProperty()
    #expect(queue.pop() == 4)
    try queue.validateHeapProperty()
    #expect(queue.pop() == 3)
    try queue.validateHeapProperty()
    #expect(queue.pop() == 1)
    try queue.validateHeapProperty()
    #expect(queue.count == 0)
  }

  @Test
  func remove() throws  {
    var queue = PriorityQueue.maxOrdering(1, 2, 2, 3, 3, 8, 7, 5, 2, 9)
    #expect(queue.count == 10)
    try queue.validateHeapProperty()
    #expect(queue.remove(at: 20) == nil)
    try queue.validateHeapProperty()
    #expect(queue.remove(at: 0) == 9)
    try queue.validateHeapProperty()
    #expect(queue.remove(at: queue.count - 1) == 2)
    try queue.validateHeapProperty()
    #expect(queue.remove(at: queue.count - 1) == 1)
    try queue.validateHeapProperty()
  }

  @Test
  func replace() throws {
    var queue = PriorityQueue.minOrdering(1, 2, 2, 3, 3, 8, 7, 5, 2, 9)
    #expect(queue.count == 10)
    try queue.validateHeapProperty()
    #expect(queue.replace(at: 20, with: 99) == nil)
    try queue.validateHeapProperty()
    #expect(queue.replace(at: 0, with: 3) == 1)
    try queue.validateHeapProperty()
    #expect(queue.replace(at: 2, with: 6) == 2)
    try queue.validateHeapProperty()

    var remaining: [Int] = []
    queue.forEach { remaining.append($0) }
    #expect(remaining == [2,2,3,3,3,5,6,7,8,9])
  }

  @Test
  func popAll() throws {
    var queue = PriorityQueue.maxOrdering(1, 2, 2, 3, 3, 8, 7, 5, 2, 9)
    #expect(queue.count == 10)
    try queue.validateHeapProperty()
    let ordered = queue.popAll()
    #expect(queue.isEmpty)
    #expect(ordered == [9, 8, 7, 5, 3, 3, 2, 2, 2, 1])
    queue.push(items: ordered.dropLast())
    try queue.validateHeapProperty()
    #expect(queue.count == 9)
    #expect(ordered.dropLast() == queue.popAll())
  }

  @Test
  func replaceMin() async throws {
    var queue = PriorityQueue<Int>.minOrdering(2, 3, 1, 4)
    #expect([1, 3, 2, 4] == queue.unordered)
    try queue.validateHeapProperty()
    #expect(1 == queue.replace(5))
    try queue.validateHeapProperty()
    #expect(2 == queue.first)
    #expect(4 == queue.count)
    #expect([2, 3, 5, 4] == queue.unordered)
    #expect([2, 3, 4, 5] == queue.popAll())
  }

  @Test
  func replaceMax() async throws {
    var queue = PriorityQueue<Int>.maxOrdering(1, 2, 3, 4)
    try queue.validateHeapProperty()
    #expect(4 == queue.replace(5))
    try queue.validateHeapProperty()
    #expect(5 == queue.first)
    #expect(4 == queue.count)
    #expect([5, 3, 2, 1] == queue.unordered)
    #expect([5, 3, 2, 1] == queue.popAll())
  }
}
