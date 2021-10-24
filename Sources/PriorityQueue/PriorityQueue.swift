// Copyright © 2020 Brad Howes. All rights reserved.

/**
 Generic container that maintains a binary heap: all parent nodes but the last contain 2 children (last parent can
 contain 1 child). Each parent appears in the container before its children, ordered by a provided function.
 */
public struct PriorityQueue<T> {
  public typealias ElementType = T

  /// Defines a function type that returns true if the two arguments are considered in order.
  public typealias IsOrderedOp = (ElementType, ElementType) -> Bool
  /// Obtain the number of items currently in the queue
  public var count: Int { heap.count }
  /// Determine if the container is empty
  public var isEmpty: Bool { heap.isEmpty }
  /// Return the first item in the queue if there is one. Does not remove it from the queue.
  public var first: ElementType? { heap.first }

  private let isOrdered: IsOrderedOp
  private var heap: [ElementType] = []

  /**
   Initialize new instance with zero or more items
   - parameter compare: function that determines ordering of items in the queue elements in ascending order
   - parameter args: zero or more items to add to queue
   */
  public init(compare: @escaping IsOrderedOp, _ args: ElementType...) {
    self.isOrdered = compare
    args.forEach { push($0) }
  }

  /**
   Initialize new instance with a collection of items

   - parameter compare: function that determines the ordering of itesm int the queue
   - parameter values: collection of items to add
   */
  public init(_ compare: @escaping IsOrderedOp, values: [ElementType]) {
    self.isOrdered = compare
    values.forEach { push($0) }
  }
}

extension PriorityQueue : CustomStringConvertible {
  public var description: String { heap.description }
}

public extension PriorityQueue {

  /**
   Add a new item to the queue while maintaining binary heap property.
   - parameter item: the new item to add
   */
  mutating func push(_ item: ElementType) {
    heap.append(item)
    shiftUp(at: heap.count - 1)
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
      shiftDown(at: 0, until: heap.count)
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
      shiftDown(at: index, until: last)
      shiftUp(at: index)
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
}

private extension Int {
  var parentPos: Int { (self - 1) >> 1 }
  var leftChildPos: Int { (self * 2) + 1 }
  var rightChildPos: Int { leftChildPos + 1 }
}

private extension PriorityQueue {

  func isOrdered(_ left: Int, _ right: Int) -> Bool { isOrdered(heap[left], heap[right]) }

  mutating func shiftUp(at index: Int) {
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

  mutating func shiftDown(at index: Int, until: Int) {
    let leftPos = index.leftChildPos
    let rightPos = index.rightChildPos

    var first = index
    if leftPos < until && isOrdered(leftPos, first) { first = leftPos }
    if rightPos < until && isOrdered(rightPos, first) { first = rightPos }
    if first == index { return }

    heap.swapAt(index, first)
    shiftDown(at: first, until: until)
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
   Generic comparison function for Comparable types that provides for max value ordering

   - parameter lhs: first value to compare
   - parameter rhs: second value to compare
   - returns: true if first value >= second value
   */
  public static func maxComp(_ lhs: ElementType, _ rhs: ElementType) -> Bool { lhs >= rhs }

  /**
   Generic comparison function for Comparable types that provides for min value ordering

   - parameter lhs: first value to compare
   - parameter rhs: second value to compare
   - returns: true if first value <= second value
   */
  public static func minComp(_ lhs: ElementType, _ rhs: ElementType) -> Bool { lhs <= rhs }

  /**
   Factory method for creating a PriorityQueue with max-value ordering

   - parameter args: values to add to the queue
   - returns: the new PriorityQueue instance
   */
  static public func maxOrdering(_ args: ElementType...) -> PriorityQueue { PriorityQueue(maxComp, values: args) }

  /**
   Factory method for creating a PriorityQueue with min-value ordering

   - parameter args: values to add to the queue
   - returns: the new PriorityQueue instance
   */
  static public func minOrdering(_ args: ElementType...) -> PriorityQueue { PriorityQueue(minComp, values: args) }

  /**
   Convenience constructor for a PriorityQueue with min-value ordering.

   - parameter args: initial values to add to the queue
   */
  public init(_ args: ElementType...) {
    isOrdered = Self.minComp
    args.forEach { push($0) }
  }
}
