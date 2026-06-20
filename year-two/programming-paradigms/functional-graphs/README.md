# Programming Paradigms
# Functional Graphs

## Overview

This assignment explores different ways to model, traverse, and transform directed graphs, evolving from a standard set-based representation
to a mathematically constructed Algebraic Graph model. The final type is successfully instantiated for several fundamental Haskell classes,
features efficient common operations and properly uses the resources of functional programming in Haskell.

## Part 1: Standard Graph Representation & Constrained Traversals

The initial stage models a directed graph using standard sets to naturally handle duplicate edges and nodes, while allowing easy comparison.

- `StandardGraph a`: Represented as a tuple of sets: `(Set a, Set (a, a))` — where the first set contains the nodes and the second contains the edges.
- Structural manipulations: `splitNode` (divides a node and redirects its edges), `mergeNodes` (merges nodes based on a predicate), and `removeNode`.
- Neighbourhood lookups: `inNeighbors` and `outNeighbors`.
- BFS & DFS: Implemented with strict performance constraints regarding list concatenations. Recursive helper functions are designed to never pass
  unchanging parameters down the call stack.
- Pathfinding: The `countIntermediate` function tracks the exact number of intermediate nodes expanded by both BFS and DFS when searching for a path
  between two nodes.

## Part 2: Introduction to Algebraic Graphs

This part introduces a significant shift in the main model. Instead of sets, the graph is represented as an algebraic data type (ADT).

- Graphs are constructed using:
  1. `Empty`: The empty graph.
  2. `Node a`: A graph containing a single node.
  3. `Overlay g1 g2`: The union of two graphs (no new edges are created between them).
  4. `Connect g1 g2`: The union of two graphs, plus directed edges from every node in `g1` to every node in `g2`.
- All operations from Part 1 are reimplemented for the Algebraic Graph. A major focus is placed on avoiding the generation of unnecessary
  intermediate edges and strictly localising recursive logic using `where` clauses.

## Part 3: Typeclasses, Higher-Order Functions & Modular Decomposition

This third part improves the Algebraic Graph by instantiating several crucial classes and implementing complex graph theory concepts.

- `Num`: Allows constructing graphs using standard arithmetic syntax. Integers become `Node`s, addition `(+)` becomes `Overlay`, and
  multiplication `(*)` becomes `Connect`. (e.g., `1 * (2 + 3)`).
- `Show` & `Eq`: Custom implementations to display algebraic expressions and accurately compare graphs regardless of their structural derivation.
- `Functor`: Implementing `fmap` to apply functions across all node labels in the graph.
- `extend`: A useful function that replaces individual nodes with entire arbitrary subgraphs. Functions like `splitNode` and `filterGraph` are
  elegantly redefined using `extend`.

The project also implements an algorithm to find the **Maximal Modular Partition** of the graph. A module is a subset of nodes that share the exact same incoming and outgoing neighbours outside the subset. The system identifies these structures to simplify and decompose complex networks.

## Part 4: Equational Reasoning & Hierarchical Folding

The final part addresses the inefficiencies of linear traversals on hierarchical algebraic structures, utilising equational reasoning.

- While the graph is made an instance of `Foldable`, this forces a linear view of the nodes, hiding the hierarchical `Overlay` and `Connect` structures.
- Hierarchical Folding: `AlgebraicGraphFolder`, to traverse the graph while respecting its topology, a custom folding mechanism is introduced
- `AlgebraicGraphFolder a b c`: A record of functions defining how to reduce `Empty`, `Node`, `Overlay`, and `Connect`.
-  Folder Composition:
  - `<+>`: Combines two independent folders into a single pass returning a tuple.
  - `>.>`: Combines two semi-dependent folders, where the second fold relies on the output of the first.
- The final touches of the project involves mathematically deriving efficient algorithms:
  - `nodesEdges`: Derived step-by-step on paper to prove how to compute nodes and edges simultaneously in a single compositional pass.
  -`dfsStack`: The naive DFS from Part 1 is mathematically generalised into a tail-recursive, stack-based DFS
