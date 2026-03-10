// Copyright © 2020-2026 Brad Howes. All rights reserved.

/**
 Generic container that maintains a binary heap: all parent nodes but the last contain 2 children (last parent can
 contain 1 child). Each parent appears in the container before its children, ordered by a provided function.

 Note: Apple's swift-collections package contains a min-max heap implementation that may be better to use. I have not
 measured performance of this implementation with theirs.
 */
public struct PriorityQueue<T> {
  public typealias ElementType = T

  /// Defines a function type that returns true if the two arguments are considered in order.
  public typealias OrderingOp = (ElementType, ElementType) -> Bool
  /// Obtain the number of items currently in the queue
  public var count: Int { heap.count }
  /// Determine if the container is empty
  public var isEmpty: Bool { heap.isEmpty }
  /// Return the first item in the queue if there is one. Does not remove it from the queue.
  public var first: ElementType? { heap.first }

  private let isOrdered: OrderingOp
  private var heap: ContiguousArray<ElementType> = .init()

  /**
   Initialize new instance with zero or more items
   - parameter compare: function that determines ordering of items in the queue elements in ascending order
   - parameter args: zero or more items to add to queue
   */
  public init(compare: @escaping OrderingOp, _ args: ElementType...) {
    self.isOrdered = compare
    args.forEach { push($0) }
  }

  /**
   Initialize new instance with a collection of items

   - parameter compare: function that determines the ordering of itesm int the queue
   - parameter values: collection of items to add
   */
  public init(_ compare: @escaping OrderingOp, values: [ElementType]) {
    self.isOrdered = compare
    values.forEach { push($0) }
  }
}

extension PriorityQueue : CustomStringConvertible {
  public var description: String { heap.description }
}

public extension PriorityQueue {

  /**
   Add one or more items to the queue while maintaining binary heap property.
   - parameter items: the variable number of items to add
   */
  mutating func push(_ items: ElementType...) {
    for item in items {
      heap.append(item)
      siftUp(at: heap.count - 1)
    }
  }

  /**
   Add a collection of items to the queue while maintaining binary heap property.
   - parameter items: the collection to add
   */
  mutating func push(items: [ElementType]) {
    for item in items {
      heap.append(item)
      siftUp(at: heap.count - 1)
    }
  }

  /**
   Remove the first item from the queue and return it.
   - returns: first item or nil if queue is empty
   */
  mutating func pop() -> ElementType? {
    switch count {
    case 0: return nil
    case 1: return heap.removeLast()
    default:
      let value = heap[0]
      heap[0] = heap.removeLast()
      siftDown(at: 0, until: heap.count)
      return value
    }
  }

  /**
   Remove the item at the given index.

   - parameter index: the position to remove
   - returns: the item that was at the given position
   */
  mutating func remove(at index: Int) -> ElementType? {
    guard index < heap.count else { return nil }

    let last = heap.count - 1
    if index != last {
      heap.swapAt(index, last)
      siftDown(at: index, until: last)
      siftUp(at: index)
    }

    return heap.removeLast()
  }

  /// Remove all entries from the queue
  mutating func removeAll() { heap.removeAll() }

  /**
   Replace a value at a given position with a new one.

   - parameter index: the index of the item to replace
   - parameter value: the new value to store
   - returns: the previous item at the given index
   */
  mutating func replace(at index: Int, with value: T) -> ElementType? {
    guard index < heap.count else { return nil }
    defer { push(value) }
    return remove(at: index)
  }

  /**
   Replace the root with a new value.

   - parameter value: new value to use
   - returns: old root value
   */
  mutating func replace(_ value: ElementType) -> ElementType? {
    return replace(at: 0, with: value)
  }
}

extension PriorityQueue {

  public typealias ForEachBlockType = (ElementType) -> Void

  /**
   Allow destructive iteration over the queue, handing the next ordered element the queue to the given closure.
   - parameter block: the closure to call to process the element
   */
  public mutating func forEach(block: ForEachBlockType) {
    while let element = pop() {
      block(element)
    }
  }

  /**
   Obtain all of the elements from the container in ordered fashion.

   - returns: array of elements
   */
  public mutating func popAll() -> [ElementType] {
    var items: [ElementType] = []
    while let element = pop() {
      items.append(element)
    }
    return items
  }
}

private extension Int {

  /// The index of the parent for this index
  var parentPos: Int { (self - 1) >> 1 }
  /// The index of the first (left) child of this index
  var leftChildPos: Int { (self * 2) + 1 }
  /// The index of the second (right) child of this index
  var rightChildPos: Int { leftChildPos + 1 }
}

private extension PriorityQueue {

  mutating func siftUp(at index: Int) {
    var pos = index
    let child = heap[pos]
    var parentPos = pos.parentPos

    while pos > 0 && isOrdered(child, heap[parentPos]) {
      heap[pos] = heap[parentPos]
      pos = parentPos
      parentPos = pos.parentPos
    }

    heap[pos] = child
  }

  mutating func siftDown(at index: Int, until: Int) {
    let leftPos = index.leftChildPos
    let rightPos = index.rightChildPos

    var first = index
    if leftPos < until && isOrdered(heap[leftPos], heap[first]) { first = leftPos }
    if rightPos < until && isOrdered(heap[rightPos], heap[first]) { first = rightPos }
    if first == index { return }

    heap.swapAt(index, first)
    siftDown(at: first, until: until)
  }
}

extension PriorityQueue where ElementType: Equatable {

  /**
   Determine if container holds the given value.

   - parameter value: the value to look for
   - returns: true if found
   */
  public func contains(_ value: ElementType) -> Bool { heap.contains(value) }
}

extension PriorityQueue where ElementType: Comparable {

  /**
   Factory method for creating a PriorityQueue with max-value ordering

   - parameter args: values to add to the queue
   - returns: the new PriorityQueue instance
   */
  static public func maxOrdering(_ args: ElementType...) -> PriorityQueue { PriorityQueue(>, values: args) }

  /**
   Factory method for creating a PriorityQueue with min-value ordering

   - parameter args: values to add to the queue
   - returns: the new PriorityQueue instance
   */
  static public func minOrdering(_ args: ElementType...) -> PriorityQueue { PriorityQueue(<, values: args) }

  /**
   Convenience constructor for a PriorityQueue with min-value ordering.

   - parameter args: initial values to add to the queue
   */
  public init(_ args: ElementType...) {
    self.init(<, values: args)
  }
}
