// Copyright © 2020 Brad Howes. All rights reserved.

/**
 Generic container that maintains a binary heap: all parent nodes but the last contain 2 children (last parent can
 contain 1 child). Each parent appears in the container before its children, ordered by a provided function.
 */
public struct PriorityQueue<T> {
    public typealias ElementType = T

    /// Defines a function type that returns true if the two areguments are considered in order.
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
     Intialize new instance..
     - parameter args: zero or more items to add to queue
     - parameter compare: function that determines ordering of items in the queue
     elements in ascending order
     */
    public init(compare: @escaping IsOrderedOp, _ args: ElementType...) {
        self.isOrdered = compare
        args.forEach { push($0) }
    }

    /**
     Intialize new instance.

     - parameter compare: function that determines the ordering of itesm int the queue
     - parameter values: collection of items to add
     */
    public init(_ compare: @escaping IsOrderedOp, values: [ElementType]) {
        self.isOrdered = compare
        values.forEach { push($0) }
    }

    /**
     Add a new item to the queue while maintaining binary heap property.
     - parameter item: the new item to add
     */
    public mutating func push(_ item: ElementType) {
        heap.append(item)
        _ = siftDown(start: 0, index: heap.count - 1)
    }

    /**
     Remove the first item from the queue and return it
     - returns: first item or nil if queue is empty
     */
    public mutating func pop() -> ElementType? {
        switch count {
        case 0: return nil
        case 1: return heap.removeLast()
        default:
            defer { _ = siftUp(index: 0) }
            heap.swapAt(0, heap.endIndex - 1)
            return heap.removeLast()
        }
    }

    /// Remove all entries from the queue
    public mutating func removeAll() { heap.removeAll() }
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

extension PriorityQueue {

    private func isOrdered(_ left: Int, _ right: Int) -> Bool { isOrdered(heap[left], heap[right]) }

    private mutating func siftUp(index: Int) {
        var pos = index
        let startPos = pos
        let newItem = heap[pos]
        var childPos = 2 * pos + 1
        while childPos < heap.count {
            let rightPos = childPos + 1
            if rightPos < heap.count && !isOrdered(childPos, rightPos) {
                childPos = rightPos
            }
            heap[pos] = heap[childPos]
            pos = childPos
            childPos = 2 * pos + 1
        }

        heap[pos] = newItem
        siftDown(start: startPos, index: pos)
    }

    private mutating func siftDown(start: Int, index: Int) {
        let newItem = heap[index]
        var pos = index
        while pos > start {
            let parentPos = (pos - 1) >> 1
            let parent = heap[parentPos]
            if isOrdered(newItem, parent) {
                heap[pos] = parent
                pos = parentPos
                continue
            }
            break
        }
        heap[pos] = newItem
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

extension PriorityQueue {

    mutating func replace(_ value: ElementType) -> ElementType {
        let returnItem = heap[0]
        heap[0] = value
        siftUp(index: 0)
        return returnItem
    }
}
