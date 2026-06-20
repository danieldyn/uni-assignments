module Algorithms where

import StandardGraph
import Data.Set (Set)
import qualified Data.Set as Set
import Debug.Trace

type Graph a = StandardGraph a

{-
*** TODO 7 (30p) ***

Utilizând equational reasoning, rafinați implementarea dfs din etapa 1
pentru a obține implementarea eficientă bazată pe o stivă.

Pentru aceasta, generalizați funcția internă folosită în etapa 1 (să o numim 
search), astfel încât să ia ca parametru nu doar nodul curent din care începe 
parcurgerea, ci o listă de noduri (să numim noua funcție searchList). Mai 
precis, impuneți proprietatea:

searchList :: Ord a => [a] -> [a]
searchList nodes = concatMap search nodes,

de unde rezultă că

search node = searchList [node].

De aici, derivați o nouă definiție mai eficientă pentru searchList, abordând 
cazul de bază și cazul general.

DERIVARE:
  searchList nodes = concatMap search nodes
  search node = searchList [node]
  concatMap f (A ++ B) = concatMap f A ++ concatMap f B
  searchList (A ++ B) = concatMap search A ++ concatMap search B = searchList A ++ searchList B

Pentru []:
  searchList [] = concatMap search [] = []

Pentru (current:rest):
  searchList (current:rest) = searchList ([current] ++ rest) = searchList [current] ++ searchList rest
  searchList [current] = current : searchList (neighs current)
Deci:
  searchList (current:rest) = (current : searchList (neighs current)) ++ searchList rest
                            = current : (searchList (neighs current) ++ searchList rest)
                            = current : searchList (neighs current ++ rest)

Avand in vedere si lista visited:
  searchList (current:rest) visited = searchList rest visited, pentru noduri current deja vizitate
  searchList (current:rest) visited = current : searchList (neighs current ++ rest) visited', pentru noduri nevizitate (visited' = insert current visited)

Exemple

>>> dfsStack 1 tree
[1,2,7,15,8,3,9,10,4,11,12,5,13,14,6]

>>> dfsStack 4 tree
[4,11,12]

In prima etapa:
dfs :: (Ord a, Show a) => a -> Graph a -> [a]
dfs node graph = explore node
  where
    explore current = current : concatMap explore allNeighs
      where
        allNeighs = Set.toList $ outNeighbors current graph
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

Funcții pentru debugging, care afișează un mesaj DEBUG de fiecare dată când
un element este implicat într-o operație de concatenare.

La fel ca (++), appendDebug este asociativă la dreapta în expresii de forma:

xs `appendDebug` ys `appendDebug` zs.

De exemplu, expresiile echivalente asociate la dreapta

[1,2] `appendDebug` ([3] `appendDebug` [4,5,6])
[1,2] `appendDebug`  [3] `appendDebug` [4,5,6]   (implicit la dreapta)

afișează utilizări unice ale elementelor:

[
DEBUG: 1
1,
DEBUG: 2
2,
DEBUG: 3
3,4,5,6],

în timp ce asocierea la stânga

([1,2] `appendDebug` [3]) `appendDebug` [4,5,6]

necesită utilizări repetate ale elementelor:

[
DEBUG: 1

DEBUG: 1
1,
DEBUG: 2

DEBUG: 2
2,
DEBUG: 3
3,4,5,6]
-}
infixr 5 `appendDebug`
appendDebug :: Show a => [a] -> [a] -> [a]
appendDebug xs ys = foldr (\x -> (trace ("\nDEBUG: " ++ show x) x :)) ys xs

concatMapDebug :: Show b => (a -> [b]) -> [a] -> [b]
concatMapDebug f = foldr (appendDebug . f) []
