# Programming Paradigms
# Shopping Simulator

## Overview

This simulation models the flow of customers through a set of store checkout counters. During the four parts, it evolved from a
basic queueing system into a highly optimised model featuring real-time time progression, counter state management, and a custom
queue data structure utilising lazy evaluation for O(1) operations.

## Part 1: Basic Counters and Total Time (tt)

The initial implementation works on a fixed set of four checkout counters (C1, C2, C3, C4) and introduces the basic metric for managing customer flow.

- Fast Counters (C1): Only accepts customers who have bought a maximum of 5 items (`ITEMS = 5`).
- Slow Counters (C2 - C4): Have no restrictions on the number of items.
- Processing Time: It takes exactly 1 minute to process a single item at any counter.
- The Total Time (`tt`) of a counter represents the total processing time of everyone currently waiting in its queue.
- `tt` = (Total number of items bought by all customers in line) + (Any delays experienced by the counter).

Customers are always assigned to the valid counter (respecting the item limit) with the minimum `tt`. If multiple counters share the same `tt`, the one with the smaller index is preferred.

## Part 2: Exit Time (et), Dynamic Counters, and Advanced Requests

This part starts tracking when specific customers leave and allowing the store to scale its operations dynamically.

- The Exit Time (`et`) is the time remaining until the **first** customer in line leaves the counter.
- `et` = (Items to process for the first customer) + (Counter delays).
- Dynamic Counter Lists: Instead of fixed variables, counters are now grouped into `fast-counters` and `slow-counters`.
- New Requests:
    - `(remove-first)`: The most advanced customer in the store (the one at the counter with the minimum `et`) leaves.
    - `(ensure <average>)`: If the average `tt` of all counters exceeds the provided `<average>`, the system automatically opens
                            new slow counters until the average drops to an acceptable level.

## Part 3: Amortised O(1) Queue ADT and Chronological Simulation

The third part significantly improves the underlying data structures and introduces a realistic chronological progression of time.

- Standard Racket lists act as stacks, making `append` operations (enqueue) O(n) and `cdr` operations (dequeue) O(1). To achieve an amortised O(1) cost for both, the queue is rebuilt using a **two-stack model**:
    - Left Stack: Used exclusively for `dequeue` operations.
    - Right Stack: Used exclusively for `enqueue` operations.
    - Mechanism: Elements are added to the right stack. We remove elements from the left stack. If the left stack is empty during a dequeue, the entire
                 right stack is reversed and moved to the left stack. Because each element moves from right to left at most once, the amortised cost
                 per operation is O(1).
- Instead of manually calling `remove-first`, the simulation now receives requests in the form of minutes (`<x>`). 
- The system advances by `<x>` minutes, updating the `tt` and `et` of all counters.
- Customers who finish checking out within that timeframe are extracted from the queues and recorded chronologically.

## Part 4: Complete O(1) Queue (Streams) and Counter Management

The final stage optimises the Queue ADT to remove the worst-case O(n) penalty during dequeue operations and introduces the ability to open and close counters dynamically.

- The main goal is achieved by representing the left stack as a **Stream** (lazy evaluation) and maintaining a strict invariant:
- Invariant: `size(left) >= size(right)`
- Whenever an operation violates this invariant (i.e., `right` becomes larger than `left`), a `rotate` operation is triggered: `<left, right>` becomes
  `<left ++ (reverse right), []>`.
- Because streams evaluate lazily, the `append` (++) is incremental. By fusing a single step of `append` with a single step of `reverse`, the operations
  evaluate in strictly O(1) time.
- Counters now have an `open?` boolean state.
- Opening: An `(open <index>)` request makes a closed counter available to customers again.
- Closing: A `(close <index>)` request shuts down a counter.
    - The counter stops accepting new customers.
    - The first customer currently at the counter is allowed to finish.
    - All remaining customers in that counter's queue are sequentially redistributed to the best available open counters
