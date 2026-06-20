{-# LANGUAGE TupleSections #-}
module StandardGraph where

import Data.Set (Set)
import qualified Data.Set as Set

{-
DIRECTED graph with nodes of type a, represented by the sets of nodes 
and edges.

Sets are useful because they ignore duplicates and allow testing the equality 
of two graphs independently of the order of nodes and edges.

`type` introduces a type synonym, similar to `typedef` in C.
-}
type StandardGraph a = (Set a, Set (a, a))

{-
Examples of graphs, built based on the fromComponents function below.
Notice the duplicate nodes and edges.
-}
graph1 :: StandardGraph Int
graph1 = fromComponents [1, 2, 3, 3, 4] [(1, 2), (1, 3), (1, 2)]

graph2 :: StandardGraph Int
graph2 = fromComponents [4, 3, 3, 2, 1] [(1, 3), (1, 3), (1, 2)]

graph3 :: StandardGraph Int
graph3 = fromComponents [1, 2, 3, 4] [(1, 2), (1, 4), (4, 1), (2, 3), (1, 3)]

graph4 :: StandardGraph Int
graph4 = fromComponents [1, 2, 3, 4] [(1, 2), (1, 4), (4, 1), (2, 4), (1, 3)]

tree :: StandardGraph Int
tree = fromComponents
    [1 .. 15]
    [ (1, 2), (1, 3), (1, 4), (1, 5), (1, 6)
    , (2, 7), (2, 8)
    , (3, 9), (3, 10)
    , (4, 11), (4, 12)
    , (5, 13), (5, 14)
    , (7, 15)
    ]

shouldBeTrue :: Bool
shouldBeTrue = graph1 == graph2

{-
Builds a graph based on the lists of nodes and edges.
-}
fromComponents :: Ord a
               => [a]              -- list of nodes
               -> [(a, a)]         -- list of edges
               -> StandardGraph a  -- constructed graph
fromComponents nodes edges = (Set.fromList nodes, Set.fromList edges)

{-
Returns the set of nodes of the graph.
-}
nodes :: StandardGraph a -> Set a
nodes = fst

{-
Returns the set of edges of the graph.
-}
edges :: StandardGraph a -> Set (a, a)
edges = snd

{-
Returns the set of nodes towards which edges leave from a source node.
-}
outNeighbors :: Ord a => a -> StandardGraph a -> Set a
outNeighbors from graph = Set.map snd $ Set.filter ((== from) . fst) $ edges graph

{-
Returns the set of nodes from which edges leave towards a destination node.
-}
inNeighbors :: Ord a => a -> StandardGraph a -> Set a
inNeighbors to graph = Set.map fst $ Set.filter ((== to) . snd) $ edges graph

{-
Returns the graph resulting from the removal 
of a node and the edges in which it is involved. If the node does not exist, 
return the same graph.
-}
removeNode :: Ord a => a -> StandardGraph a -> StandardGraph a
removeNode node graph = (newNodes, newEdges)
  where
    newNodes = Set.delete node $ nodes graph
    newEdges = Set.filter (\(u, v) -> u /= node && v /= node) $ edges graph

{-
Divides a node into multiple nodes,
with the removal of the initial node. The edges in which the old node was involved must 
become valid for the new nodes
-}
splitNode :: Ord a
          => a                -- the divided node
          -> Set a            -- the nodes it is replaced with
          -> StandardGraph a  -- the existing graph
          -> StandardGraph a  -- the obtained graph
splitNode old news graph = (newNodes, newEdges)
  where
    newNodes = Set.union news $ Set.delete old $ nodes graph
    newEdges = Set.foldr (Set.union . redirectEdge) Set.empty $ edges graph
    redirectEdge (u, v)
      -- The loop becomes the Cartesian product of the set of new nodes with itself
      | u == old && v == old = Set.cartesianProduct news news
      -- We redirect all incoming or outgoing edges
      | u == old = Set.map (\newU -> (newU, v)) news
      | v == old = Set.map (\newV -> (u, newV)) news
      -- The edge is not affected by the change
      | otherwise = Set.singleton (u, v)

{-
Merges multiple nodes into a single one, 
based on a property fulfilled by the merged nodes, with their removal. 
The edges in which the old nodes were involved will refer to the new node.
-}
mergeNodes :: Ord a
           => (a -> Bool)      -- the property fulfilled by the merged nodes
           -> a                -- the new node
           -> StandardGraph a  -- the existing graph
           -> StandardGraph a  -- the obtained graph
mergeNodes prop node graph = if Set.null removedNodes then graph else (newNodes, newEdges)
  where
    newNodes = Set.insert node $ Set.filter (not . prop) $ nodes graph
    removedNodes = Set.filter prop $ nodes graph
    newEdges = Set.map redirectEdge $ edges graph
    redirectEdge (u, v) = (newU, newV)
      where
        newU = if Set.member u removedNodes then node else u
        newV = if Set.member v removedNodes then node else v
