module Algorithms where

import StandardGraph
import Data.Set (Set)
import qualified Data.Set as Set
import Debug.Trace

type Graph a = StandardGraph a

{-
Using equational reasoning, we generalise the internal function used in stage 1,
so that it takes as a parameter not just the current node from which the 
traversal begins, but a list of nodes (let's call the new function searchList). More 
specifically, we impose the property:

searchList :: Ord a => [a] -> [a]
searchList nodes = concatMap search nodes,

from which it follows that

search node = searchList [node].

DERIVATION:
  searchList nodes = concatMap search nodes
  search node = searchList [node]
  concatMap f (A ++ B) = concatMap f A ++ concatMap f B
  searchList (A ++ B) = concatMap search A ++ concatMap search B = searchList A ++ searchList B

For []:
  searchList [] = concatMap search [] = []

For (current:rest):
  searchList (current:rest) = searchList ([current] ++ rest) = searchList [current] ++ searchList rest
  searchList [current] = current : searchList (neighs current)
So:
  searchList (current:rest) = (current : searchList (neighs current)) ++ searchList rest
                            = current : (searchList (neighs current) ++ searchList rest)
                            = current : searchList (neighs current ++ rest)

Considering the visited list as well:
  searchList (current:rest) visited = searchList rest visited, for already visited current nodes
  searchList (current:rest) visited = current : searchList (neighs current ++ rest) visited', for unvisited nodes (visited' = insert current visited)
-}
dfsStack :: Ord a => a -> Graph a -> [a]
dfsStack node graph = searchList [node] Set.empty
  where
    searchList [] _ = []
    searchList (current:rest) visited
      | Set.member current visited = searchList rest visited
      | otherwise = current : searchList (allNeighs ++ rest) marked
        where
          allNeighs = Set.toList $ outNeighbors current graph
          marked = Set.insert current visited

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
