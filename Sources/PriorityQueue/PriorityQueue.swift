// Copyright © 2020-2026 Brad Howes. All rights reserved.

/**
 Generic container that maintains a binary heap for fast access to a min or max element in the container.

 In a heap, elements are ordered sequentially, with parents appearing before their children. All parents but the last
 have 2 children (the last parent may contain 1 child). Ordering is determined by a function given during
 initialization.

> Note: Apple's swift-collections package contains a min-max heap implementation that may be better to use. I have not
> measured and compared performance of either.

 Creating a new heap is straightforward:

 ```
 var heap: PriorityQueue<Int> = .init(ordering: \<)
 ```

 Since `Int` conforms to the `Orderable` protocol, one can omit the `ordering:` argument if a min-heap is desired:

 ```
 var heap: PriorityQueue<Int> = .init()
 ```

 To add values to a heap, call the ``PriorityQueue/push(_:)`` method. This method supports a variable number of values
 (there is the ``PriorityQueue/push(items:)`` variant for a sequence):

 ```
 heap.push(5)
 heap.push(5, 6, 7)
 heap.push(items: [5,6,7])
 ```

 The usual way to fetch items from queue is by using the ``PriorityQueue/pop()`` method:

 ```
 let value = heap.pop()
 ```

 It is acceptable to call this even if the queue is empty -- the return value will be `nil` when that is the case.

 ### Not a Sequence

 Note that the queue does not conform to `Sequence`, nor to `IteratorProtocol`. There is however a
 ``PriorityQueue/forEach(block:)`` method that one can use to repeatedly obtain the "top" element in the queue until it
 is empty:

 ```
 var heap: PriorityQueue<Int> = .init(1, 9, 3, 5)
 var tops: [Int] = []
 heap.forEach {
   tops.append($0)
 }
 ```

 Similarly, there is a ``PriorityQueue/popAll()`` method that returns an array of the ordered elements from the queue:

 ```
 var heap: PriorityQueue<Int> = .init(1, 9, 3, 5)
 let tops = heap.popAll() # -> [1, 3, 5, 9]
 ```
 */
public struct PriorityQueue<T> {

  /// The type of the element held in the queue.
  public typealias ElementType = T
  /// The index type for the container.
  public typealias Index = ContiguousArray<ElementType>.Index
  /// Defines a function type that returns true if the two arguments are considered in order.
  public typealias OrderingOp = (ElementType, ElementType) -> Bool

  /// The number of elements in the queue.
  @inlinable
  public var count: Int { heap.count }

  /// A Boolean value indicating whether the queue is empty.
  @inlinable
  public var isEmpty: Bool { heap.isEmpty }

  /// The first item in the queue, ordered by priority.
  @inlinable
  public var first: ElementType? { heap.first }

  @usableFromInline
  internal let isOrdered: OrderingOp

  @usableFromInline
  internal var heap: ContiguousArray<ElementType> = .init()

  /**
   Initialize new instance with zero or more items.
   - parameter compare: function that determines ordering of items in the queue elements in ascending order.
   - parameter args: zero or more items to add to queue.
   */
  public init(compare: @escaping OrderingOp, _ args: ElementType...) {
    self.isOrdered = compare
    args.forEach { push($0) }
  }

  /**
   Initialize new instance with a collection of items.

   - parameter compare: function that determines the ordering of itesm int the queue.
   - parameter values: collection of items to add.
   */
  public init(compare: @escaping OrderingOp, values: [ElementType]) {
    self.isOrdered = compare
    values.forEach { push($0) }
  }
}

extension PriorityQueue: CustomStringConvertible {

  /// A textual representation of the queue and its elements.
  @inlinable
  public var description: String { heap.description }
}

extension PriorityQueue {

  /**
   Add one or more items to the queue while maintaining the binary heap property.

   - parameter items: the variable number of items to add.
   */
  @inlinable
  public mutating func push(_ items: ElementType...) {
    push(items: items)
  }

  /**
   Add a collection of items to the queue while maintaining the binary heap property.

   - parameter items: the collection to add.
   */
  @inlinable
  public mutating func push(items: [ElementType]) {
    items.forEach {
      heap.append($0)
      siftUp(at: heap.count - 1)
    }
  }

  /**
   Removes and returns the first element in the queue.

   - returns: the first element in the queue which is either the smallest or largest according to the ordering operation being used.
   If the queue is empty, returns `nil`.
   */
  public mutating func pop() -> ElementType? {
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
   Remove the item at the given index. This involves both a sift down of the new value at `index` as well as a sift up in order to
   guarantee heap constraints -- not an optimal operation.

   - parameter index: the position to remove.
   - returns: the item that was at the given position.
   */
  public mutating func remove(at index: Int) -> ElementType? {
    guard index >= 0 && index < heap.count else { return nil }
    let last = heap.count - 1
    if index != last {
      heap.swapAt(index, last)
      siftDown(at: index, until: last)
      siftUp(at: index)
    }

    return heap.removeLast()
  }

  /// Remove all entries from the queue.
  @inlinable
  public mutating func removeAll() { heap.removeAll() }

  /**
   Replace a value at a given position with a new one. This involves removing the value at the given index and then pushing the new
   value onto heap -- not an optimal operation.

   - parameter index: the index of the item to replace.
   - parameter value: the new value to store.
   - returns: the previous item at the given index.
   */
  @inlinable
  public mutating func replace(at index: Int, with value: T) -> ElementType? {
    guard index >= 0 && index < heap.count else { return nil }
    defer { push(value) }
    return remove(at: index)
  }

  /**
   Replace the root with a new value.

   - parameter value: new value to use.
   - returns: old root value.
   */
  @inlinable
  public mutating func replace(_ value: ElementType) -> ElementType? {
    replace(at: 0, with: value)
  }
}

extension PriorityQueue {

  /**
   Allow destructive iteration over the queue, handing the next ordered element the queue to the given closure.
   - parameter block: the closure to call to process the element.
   */
  @inlinable
  public mutating func forEach(block: (ElementType) -> Void) {
    while let element = pop() {
      block(element)
    }
  }

  /**
   Obtain all of the elements from the container in ordered fashion, resulting in an empty queue.

   - returns: array of elements from the queue.
   */
  @inlinable
  public mutating func popAll() -> [ElementType] {
    var items: [ElementType] = []
    while let element = pop() {
      items.append(element)
    }
    return items
  }
}

/// Attributes for moving to parent and children. Uses Swift `FixedWidthInteger` operations for speed.
extension PriorityQueue<Any>.Index {

  /// The index of the parent.
  @inlinable
  var parentPos: Self { (self &- 1) >> 1 }

  /// The index of the first (left) child.
  @inlinable
  var leftChildPos: Self { (self &* 2) &+ 1 }

  /// The index of the second (right) child.
  @inlinable
  var rightChildPos: Self { leftChildPos &+ 1 }
}

extension PriorityQueue {

  /**
   Move an item "higher" (closer to the start) in the queue while it is unordered compared to its parent.

   - parameter index: the index of the item to compare.
   */
  @inlinable
  mutating func siftUp(at index: Index) {
    heap.withUnsafeMutableBufferPointer { ptr in
      var pos = index
      let child = ptr[pos]
      var parentPos = pos.parentPos

      while pos > 0 && isOrdered(child, ptr[parentPos]) {
        ptr[pos] = ptr[parentPos]
        pos = parentPos
        parentPos = pos.parentPos
      }
      ptr[pos] = child
    }
  }

  /**
   Move an item down (closer to the end) in the queue while it is unordered compared to its children.

   - parameter index: the index of the item to compare.
   - parameter until: the index at which to stop the comparisons.
   */
  @inlinable
  mutating func siftDown(at index: Index, until: Index) {
    heap.withUnsafeMutableBufferPointer { ptr in
      var index = index
      while true {
        var newPos = index
        for childPos in [index.leftChildPos, index.rightChildPos] {
          if childPos < until && isOrdered(ptr[childPos], ptr[newPos]) {
            newPos = childPos
          }
        }
        if newPos == index { break }
        ptr.swapAt(index, newPos)
        index = newPos
      }
    }
  }
}

extension PriorityQueue where ElementType: Equatable {

  /**
   Determine if container holds the given value. Note that this is not optimized -- it runs in O(n).

   - parameter value: the value to look for.
   - returns: true if found.
   */
  @inlinable
  public func contains(_ value: ElementType) -> Bool { heap.contains(value) }
}

extension PriorityQueue where ElementType: Comparable {

  /**
   Factory method for creating a PriorityQueue with max-value ordering.

   - parameter args: values to add to the queue.
   - returns: the new PriorityQueue instance.
   */
  @inlinable
  static public func maxOrdering(_ args: ElementType...) -> PriorityQueue { PriorityQueue(compare: >, values: args) }

  /**
   Factory method for creating a PriorityQueue with min-value ordering.

   - parameter args: values to add to the queue.
   - returns: the new PriorityQueue instance.
   */
  @inlinable
  static public func minOrdering(_ args: ElementType...) -> PriorityQueue { PriorityQueue(compare: <, values: args) }

  /**
   Convenience constructor for a PriorityQueue with min-value ordering.

   - parameter args: initial values to add to the queue.
   */
  @inlinable
  public init(_ args: ElementType...) {
    self.init(compare: <, values: args)
  }
}
