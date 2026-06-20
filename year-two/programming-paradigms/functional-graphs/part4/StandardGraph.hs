{-# LANGUAGE TupleSections #-}
module StandardGraph where

import Data.Set (Set)
import qualified Data.Set as Set

{-
Graf ORIENTAT cu noduri de tipul a, reprezentat prin mulțimile (set) de noduri 
și de arce.

Mulțimile sunt utile pentru că ignoră duplicatele și permit testarea egalității 
a două grafuri independent de ordinea nodurilor și a arcelor.

type introduce un sinonim de tip, similar cu typedef din C.
-}
type StandardGraph a = (Set a, Set (a, a))

{-
Exemple de grafuri, construite pe baza funcției fromComponents de mai jos.
Observați nodurile și arcele duplicate.
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
Din etapa 1.
-}
fromComponents :: Ord a
               => [a]              -- lista nodurilor
               -> [(a, a)]         -- lista arcelor
               -> StandardGraph a  -- graful construit
fromComponents nodes edges =  (Set.fromList nodes, Set.fromList edges)

{-
Din etapa 1.
-}
nodes :: StandardGraph a -> Set a
nodes = fst

{-
Din etapa 1.
-}
edges :: StandardGraph a -> Set (a, a)
edges = snd

{-
Din etapa 1.
-}
outNeighbors :: Ord a => a -> StandardGraph a -> Set a
outNeighbors from graph = Set.map snd $ Set.filter ((== from) . fst) $ edges graph
