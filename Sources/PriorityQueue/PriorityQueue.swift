// Copyright © 2020-2026 Brad Howes. All rights reserved.

/**
 Generic container that maintains a binary heap for fast access to a min or max element in the container.

 Creating a new heap is straightforward:

 ```
 var heap: PriorityQueue<Int> = .init(ordering: \<)
 ```

 Since `Int` conforms to the `Orderable` protocol, one can omit the `ordering:` argument if a min-heap of integers is desired:

 ```
 var heap: PriorityQueue<Int> = .init()
 ```

 For a max heap, one must provide `\>` operator or use the ``PriorityQueue/maxOrdering(_:)`` factory function.

 To add values to a heap, call the ``PriorityQueue/push(_:)`` method. This method supports a variable number of values
 (there is the ``PriorityQueue/push(items:)`` variant for a sequence):

 ```
 heap.push(6, 5, 7)
 heap.push(items: [8, 3, 4])
 heap.popAll() # -> [3, 4, 5, 6, 7, 8]
 ```

 To fetch the min/max item from the queue, use the ``PriorityQueue/pop()`` method:

 ```
 let value = heap.pop()
 ```

 It is acceptable to call this even if the queue is empty -- the return value will be `nil` when that is the case.

 There is also a non-destructive ``PriorityQueue/first`` attribute which returns the min/max item in the queue (or `nil` if queue
 is empty).
 
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
 var heap: PriorityQueue<Int> = .init(1, 7, 3, 5)
 let tops = heap.popAll() # -> [1, 3, 5, 7]
 ```

 Both of these are destructive operations, leaving the queue empty.

 Finally, there is a way to see the queue as an array of values by accessing the ``PriorityQueue/unordered`` property:

 ```
 heap.push(2, 3, 1, 4)
 heap.unordered # -> [1, 3, 2, 4]
 ```

 Just remember that the positions of the elements are only valid until the collection is changed.
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

  /// Obtain a representation of the queue as an array. Operations on this array will not affect the queue. Also, the representation
  /// is only valid until the next change to the priority queue.
  @inlinable
  public var unordered: [ElementType] { Array(heap) }

  @usableFromInline
  internal let isOrdered: OrderingOp

  @usableFromInline
  internal var heap: ContiguousArray<ElementType> = .init()

  /**
   Initialize new instance with zero or more items.

   - Parameter compare: function that determines the ordering of items in the queue.
   - Parameter args: zero or more items to add to queue.
   */
  public init(compare: @escaping OrderingOp, _ args: ElementType...) {
    self.isOrdered = compare
    args.forEach { push($0) }
  }

  /**
   Initialize new instance with a collection of items.

   - Parameter compare: function that determines the ordering of items in the queue.
   - Parameter values: collection of items to add.
   */
  public init(compare: @escaping OrderingOp, values: [ElementType]) {
    self.isOrdered = compare
    values.forEach { push($0) }
  }
}

extension PriorityQueue {

  /**
   Add one or more items to the queue while maintaining the binary heap property.

   - Parameter items: the variable number of items to add.
   */
  @inlinable
  public mutating func push(_ items: ElementType...) {
    push(items: items)
  }

  /**
   Add a collection of items to the queue while maintaining the binary heap property.

   - Parameter items: the collection to add.
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

   - Returns: the first element in the queue which is either the smallest or largest according to the ordering operation being used.
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

   - Parameter index: the position to remove.
   - Returns: the item that was at the given position.
   */
  public mutating func remove(at index: Int) -> ElementType? {
    guard index >= 0 && index < heap.count else { return nil }
    let last = heap.count - 1
    if index == 0 {
      return pop()
    } else if index != last {
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

   - Parameter index: the index of the item to replace.
   - Parameter value: the new value to store.
   - Returns: the previous item at the given index.
   */
  @inlinable
  public mutating func replace(at index: Int, with value: T) -> ElementType? {
    guard index >= 0 && index < heap.count else { return nil }
    defer { push(value) }
    return remove(at: index)
  }

  /**
   Replace the first (root) value with a new value while maintaining the heap property. Useful if the first element has changed a
   property that affects is ordering. More efficient than popping off the top element and pushing a new one.

   - Parameter value: new value to use.
   - Returns: old root value.
   */
  @inlinable
  public mutating func replace(_ value: ElementType) -> ElementType? {
    heap.append(value)
    let last = heap.count - 1
    heap.swapAt(0, last)
    siftDown(at: 0, until: heap.count - 1)
    return heap.removeLast()
  }
}

extension PriorityQueue {

  /**
   Allow destructive iteration over the queue, handing the next ordered element the queue to the given closure.
   - Parameter block: the closure to call to process the element.
   */
  @inlinable
  public mutating func forEach(block: (ElementType) -> Void) {
    while let element = pop() {
      block(element)
    }
  }

  /**
   Obtain all of the elements from the container in ordered fashion, resulting in an empty queue.

   - Returns: array of elements from the queue.
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

  /// Error raised if the heap property does not hold.
  public struct ValidationFailure: Error {}

  /**
   Validate that heap (ordering) property of the internal container still holds.

   - throws ``ValidationFailure``
   */
  public func validateHeapProperty() throws {
    guard !heap.isEmpty else { return }

    func validateParent(_ index: Int) throws {

      let left = index.leftChildPos
      if left < heap.count {
        guard !isOrdered(heap[left], heap[index]) else { throw ValidationFailure() }
        try validateParent(left)
      }

      let right = index.rightChildPos
      if right < heap.count {
        guard !isOrdered(heap[right], heap[index]) else { throw ValidationFailure() }
        try validateParent(right)
      }
    }

    try validateParent(0)
  }
}

extension PriorityQueue {

  /**
   Move an item "higher" (closer to the start) in the queue while it is unordered compared to its parent.

   - Parameter index: the index of the item to compare.
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

   - Parameter index: the index of the item to compare.
   - Parameter until: the index at which to stop the comparisons.
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

   - Parameter value: the value to look for.
   - Returns: true if found.
   */
  @inlinable
  public func contains(_ value: ElementType) -> Bool { heap.contains(value) }
}

extension PriorityQueue where ElementType: Comparable {

  /**
   Factory method for creating a PriorityQueue with max-value ordering. This is equivalent to calling
   ``PriorityQueue/init(compare:values:)`` with the `>` operator.

   - Parameter args: values to add to the queue.
   - Returns: the new PriorityQueue instance.
   */
  @inlinable
  static public func maxOrdering(_ args: ElementType...) -> PriorityQueue { PriorityQueue(compare: >, values: args) }

  /**
   Factory method for creating a PriorityQueue with min-value ordering. This is equivalent to calling
   ``PriorityQueue/init(compare:values:)`` with the `<` operator.

   - Parameter args: values to add to the queue.
   - Returns: the new PriorityQueue instance.
   */
  @inlinable
  static public func minOrdering(_ args: ElementType...) -> PriorityQueue { PriorityQueue(compare: <, values: args) }

  /**
   Convenience constructor for a PriorityQueue with min-value ordering.

   - Parameter args: initial values to add to the queue.
   */
  @inlinable
  public init(_ args: ElementType...) {
    self.init(compare: <, values: args)
  }
}
