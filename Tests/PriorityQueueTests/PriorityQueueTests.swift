// Copyright © 2020 Brad Howes. All rights reserved.
//

import Testing

@testable import PriorityQueue

@Suite("PriorityQueue")
struct PriorityQueueTests {

  @Test
  func minQueue() {
    var queue = PriorityQueue(1, 3, 5, 5, 9, 2, 4, 6, 8)
    #expect(queue.count == 9)
    #expect(queue.first == 1)
    #expect(!queue.isEmpty)

    #expect(queue.first == 1)
    #expect(queue.pop()! == 1)
    #expect(queue.pop()! == 2)
    #expect(queue.pop()! == 3)
    #expect(queue.pop()! == 4)
    #expect(queue.pop()! == 5)
    #expect(queue.pop()! == 5)
    #expect(queue.pop()! == 6)
    #expect(queue.pop()! == 8)
    #expect(queue.pop()! == 9)

    #expect(queue.count == 0)
    #expect(queue.pop() == nil)
    #expect(queue.first == nil)
    #expect(queue.isEmpty)
  }

  @Test
  func maxQueue() {
    var queue = PriorityQueue(compare: >, 1, 3, 5, 7, 9, 2, 4, 6, 8)
    #expect(queue.count == 9)
    #expect(queue.pop()! == 9)
    #expect(queue.pop()! == 8)
    #expect(queue.pop()! == 7)
    #expect(queue.pop()! == 6)
    #expect(queue.pop()! == 5)
    #expect(queue.pop()! == 4)
    #expect(queue.pop()! == 3)
    #expect(queue.pop()! == 2)
    #expect(queue.pop()! == 1)
    #expect(queue.count == 0)
    #expect(queue.pop() == nil)
  }

  @Test
  func push() {
    var queue = PriorityQueue.minOrdering(1, 3, 5, 7, 9)
    print(queue)
    queue.push(2)
    #expect(queue.count == 6)
    #expect(queue.pop()! == 1)
    #expect(queue.pop()! == 2)
    #expect(queue.pop()! == 3)

    queue.push(1)
    #expect(queue.pop()! == 1)
    #expect(queue.pop()! == 5)
  }

  @Test
  func removeAll() {
    var queue = PriorityQueue(1, 3, 5, 7, 9)
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
  func iteration() {
    var queue = PriorityQueue(9, 8, 7, 1, 2, 3, 6, 4, 5)
    #expect(queue.count == 9)
    var counter = 1
    queue.forEach {
      #expect($0 == counter)
      counter += 1
    }

    #expect(queue.count == 0)
  }

  @Test
  func replaceMinOrder() {
    var queue = PriorityQueue.minOrdering(3, 1, 9, 7, 5)
    #expect(queue.count == 5)
    #expect(queue.pop() == 1)
    #expect(queue.pop() == 3)
    #expect(queue.replace(8) == 5)
    #expect(queue.pop() == 7)
    #expect(queue.pop() == 8)
    #expect(queue.pop() == 9)
    #expect(queue.count == 0)
  }

  @Test
  func replaceMaxOrder() {
    var queue = PriorityQueue.maxOrdering(3, 1, 5, 9, 7)
    #expect(queue.count == 5)
    #expect(queue.pop() == 9)
    #expect(queue.pop() == 7)
    #expect(queue.replace(4) == 5)
    #expect(queue.pop() == 4)
    #expect(queue.pop() == 3)
    #expect(queue.pop() == 1)
    #expect(queue.count == 0)
  }

  @Test
  func remove() {
    var queue = PriorityQueue.maxOrdering(1, 2, 2, 3, 3, 8, 7, 5, 2, 9)
    #expect(queue.count == 10)
    #expect(queue.remove(at: 20) == nil)
    #expect(queue.remove(at: 0) == 9)
    #expect(queue.remove(at: queue.count - 1) == 2)
    #expect(queue.remove(at: queue.count - 1) == 1)
  }

  @Test
  func replace() {
    var queue = PriorityQueue.minOrdering(1, 2, 2, 3, 3, 8, 7, 5, 2, 9)
    #expect(queue.count == 10)
    #expect(queue.replace(at: 20, with: 99) == nil)
    #expect(queue.replace(at: 0, with: 3) == 1)
    #expect(queue.replace(at: 2, with: 6) == 2)

    var remaining: [Int] = []
    queue.forEach { remaining.append($0) }
    #expect(remaining == [2,2,3,3,3,5,6,7,8,9])
  }

  @Test
  func popAll() {
    var queue = PriorityQueue.maxOrdering(1, 2, 2, 3, 3, 8, 7, 5, 2, 9)
    #expect(queue.count == 10)
    let ordered = queue.popAll()
    #expect(queue.isEmpty)
    #expect(ordered == [9, 8, 7, 5, 3, 3, 2, 2, 2, 1])
    queue.push(items: ordered.dropLast())
    #expect(queue.count == 9)
    #expect(ordered.dropLast() == queue.popAll())
  }
}
