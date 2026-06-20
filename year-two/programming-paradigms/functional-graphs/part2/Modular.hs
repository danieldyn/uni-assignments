module Modular where

import Data.Set (Set)
import qualified Data.Set as Set

{-
Applies a function to each element of a list, but only to one at a time,
keeping the others unchanged. Therefore, for each element in the initial list,
a list results in the final list, corresponding to the modification of only that element.
-}
mapSingle :: (a -> a) -> [a] -> [[a]]
mapSingle f xs = case xs of
  [] -> []
  y:ys -> (f y : ys) : map (y :) (mapSingle f ys)

{-
Determines the list of all partitions of a list. Although above the type (Partition a)
is defined using sets, here we use lists, for simplicity.

The 3 levels of the list type constructor from the type returned by the function
have the following meaning:

* The inner level represents a subset of the original list
* The intermediate level represents a partition, which is a set of subsets
* The outer level represents the set of all partitions.
-}
partitions :: [a] -> [[[a]]]
partitions xs = case xs of
  [] -> [[]]
  y:ys -> [ partition | p <- partitions ys, partition <- ([y] : p) : mapSingle (y :) p ]
