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
From stage 1.
-}
fromComponents :: Ord a
               => [a]              -- list of nodes
               -> [(a, a)]         -- list of edges
               -> StandardGraph a  -- constructed graph
fromComponents nodes edges =  (Set.fromList nodes, Set.fromList edges)

{-
From stage 1.
-}
nodes :: StandardGraph a -> Set a
nodes = fst

{-
From stage 1.
-}
edges :: StandardGraph a -> Set (a, a)
edges = snd

{-
From stage 1.
-}
outNeighbors :: Ord a => a -> StandardGraph a -> Set a
outNeighbors from graph = Set.map snd $ Set.filter ((== from) . fst) $ edges graph
