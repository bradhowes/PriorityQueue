# ``PriorityQueue``

A priority queue is specialized container of typed elements that provides fast (O(1)) access to the minimum or maximum value held
in the container. Further, it guarantees that this will be the case even after elements are added and/or removed.

## Overview

A heap data structure is a tree that satisfies the _heap property_:

> Heap Property: For any node C, if P is the parent node of C, then P will be ordered before C according to some
> ordering operation. All parents have at most 2 children, and the root node has no parent.

A _min heap_ is a heap where a parent P is ordered before any child C (less-than operation), and the root holds the
minimum value for the whole heap. Similarly, a _max_heap_ is a heap where a parent P is ordered after any child C
(greater-than operation), and the root holds the maximum value for the whole heap.

> Tip: Apple's swift-collections package contains a [min-max
> heap](https://swiftpackageindex.com/apple/swift-collections/main/documentation/heapmodule) implementation that may be
> more performant to use.
