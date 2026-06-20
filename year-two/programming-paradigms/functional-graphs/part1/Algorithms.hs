module Algorithms where

import Data.Set (Set)
import qualified Data.Set as Set
import StandardGraph
import Debug.Trace

{-
In stage 1, by graph we mean a graph with standard representation. In the following 
stages, we will also experiment with another representation.

`type` introduces a type synonym, similar to `typedef` in C.
-}
type Graph a = StandardGraph a

{-
Returns a list of nodes resulting from the breadth-first traversal of a graph, starting from a node.

In this stage, we assume for simplicity that the graph does not contain multiple 
paths between two nodes nor cycles, so as not to require managing a 
set of already visited nodes.
-}
bfs :: (Ord a, Show a) => a -> Graph a -> [a]
bfs node graph = explore [node] [] $ Set.singleton node
  where
    explore [] [] _ = []
    explore [] right visited = explore (reverse right) [] visited
    explore (current:rest) right visited = current : explore rest newRight marked
      where
        allNeighs = Set.toList $ outNeighbors current graph
        unexploredNeighs = filter (`Set.notMember` visited) allNeighs
        marked = foldr Set.insert visited unexploredNeighs
        newRight = reverse unexploredNeighs ++ right

-- Use bfsQueue for experiments
bfsQueue :: (Ord a, Show a) => a -> Graph a -> [a]
bfsQueue node graph = go [node]
  where
    go [] = []
    go (node : nodes) =
      node
      : go (if null neighbors then nodes else nodes ++ neighbors)
      where
        neighbors = Set.toList $ outNeighbors node graph

{-
Returns a list of nodes resulting from the depth-first traversal of a graph, starting from a node.

In this stage, we assume for simplicity that the graph does not contain multiple 
paths between two nodes nor cycles, so as not to require managing a 
set of already visited nodes.
-}
dfs :: (Ord a, Show a) => a -> Graph a -> [a]
dfs node graph = explore node
  where
    explore current = current : concatMap explore allNeighs
      where
        allNeighs = Set.toList $ outNeighbors current graph

{-
Counts how many intermediate nodes 
the BFS and DFS strategies visit, respectively, in the attempt to find a path 
between a source node and a destination node, taking into account the possibility of its 
absence from the graph. The number EXCLUDES the source and destination nodes.
-}
countIntermediate :: (Ord a, Show a)
                  => a                 -- the source node
                  -> a                 -- the destination node
                  -> Graph a           -- the graph
                  -> Maybe (Int, Int)  -- the number of nodes expanded by BFS/DFS
countIntermediate from to graph = if null bfsRest then Nothing else Just (length bfsPrefix - 1, length dfsPrefix - 1)
  where
    bfsList = bfs from graph
    dfsList = dfs from graph
    (bfsPrefix, bfsRest) = span (/= to) bfsList
    (dfsPrefix, dfsRest) = span (/= to) dfsList

{-
DEBUG

Functions for debugging, which print a DEBUG message every time
an element is involved in a concatenation operation.
-}
infixr 5 `appendDebug`
appendDebug :: Show a => [a] -> [a] -> [a]
appendDebug xs ys = foldr (\x -> (trace ("\nDEBUG: " ++ show x) x :)) ys xs

concatMapDebug :: Show b => (a -> [b]) -> [a] -> [b]
concatMapDebug f = foldr (appendDebug . f) []
