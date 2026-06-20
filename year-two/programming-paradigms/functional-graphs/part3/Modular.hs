module Modular where

import Data.Set (Set)
import qualified Data.Set as Set
import AlgebraicGraph
import Data.Foldable ( minimumBy )
import Data.Ord ( comparing )

type Graph a = AlgebraicGraph a

-- The graph described in the diagram from the assignment text
diagram :: AlgebraicGraph Int
diagram = ((1*2) * (3+4)) * 5

{-
A partition is a set of disjoint subsets of another set
(without common elements) and which together contain all the original elements.

For example, for the set [1,2,3], a possible partition is [[1], [2,3]].
-}
type Partition a = Set (Set a)

{-
The mapSingle function from stage 2.
-}
mapSingle :: (a -> a) -> [a] -> [[a]]
mapSingle f xs = case xs of
  [] -> []
  y:ys -> (f y : ys) : map (y :) (mapSingle f ys)

{-
The partitions function from stage 2.
-}
partitions :: [a] -> [[[a]]]
partitions xs = case xs of
  [] -> [[]]
  y:ys -> [ partition | p <- partitions ys, partition <- ([y] : p) : mapSingle (y :) p ]

{-
Checks if a set is a module, i.e. if all nodes in the set have the same set
of out-neighbors and the same set of in-neighbors, outside the starting set.
In other words, we exclude from the check the neighbors inside the starting set.
-}
isModule :: Ord a
         => Set a
         -> Graph a
         -> Bool
isModule set graph = Set.size allNeighs <= 1
  where
    neighs n = (currentOut n, currentIn n)
    currentOut n = Set.difference (outNeighbors n graph) set
    currentIn n = Set.difference (inNeighbors n graph) set
    allNeighs = Set.map neighs set


{-
Checks if a partition of the set of nodes constitutes a modular decomposition.
The partition is represented as a set of sets.
-}
isModularPartition :: Ord a
                   => Partition a
                   -> Graph a
                   -> Bool
isModularPartition partition graph = all (\set -> isModule set graph) partition

{-
Determines the maximal partition from a set of partitions.
The maximal partition contains the most covering subsets of the node set. 
In other words, the maximal partition contains 
the smallest number of subsets strictly greater than 1, to exclude 
the trivial partition that contains only the entire set of nodes.
-}
maximalModularPartition :: Ord a
                        => Set (Partition a)
                        -> Graph a
                        -> Partition a
maximalModularPartition partitions graph = minimumBy (comparing Set.size) modularPartitions
  where
    modularPartitions = Set.filter (\p -> isModularPartition p graph && Set.size p > 1) partitions


{-
Gets the modular decomposition of a graph. You can use it to
manually experiment with maximalModularPartition.
-}
modularlyDecompose :: Ord a
                   => Graph a
                   -> Partition a
modularlyDecompose graph = maximalModularPartition partitionSet graph
  where
    parts = partitions $ Set.toList $ nodes graph
    partitionSet = Set.fromList $ map toPartition parts

toPartition :: Ord a => [[a]] -> Partition a
toPartition = Set.fromList . map Set.fromList
