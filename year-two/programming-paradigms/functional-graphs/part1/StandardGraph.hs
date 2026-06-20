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
*** TODO 1 (3p) ***

Implementați funcția fromComponents, care construiește un graf pe baza listelor 
de noduri și de arce.

Constrângerea (Ord a) afirmă că valorile tipului a trebuie să fie ordonabile, 
lucru necesar pentru reprezentarea internă a mulțimilor. Este doar un detaliu, 
cu care nu veți opera explicit în această etapă. Veți întâlni această 
constrângere și în tipurile funcțiilor de mai jos.

Hint: Set.fromList.

Exemple:

>>> graph1
(fromList [1,2,3,4],fromList [(1,2),(1,3)])
-}
fromComponents :: Ord a
               => [a]              -- lista nodurilor
               -> [(a, a)]         -- lista arcelor
               -> StandardGraph a  -- graful construit
fromComponents nodes edges = (Set.fromList nodes, Set.fromList edges)

{-
*** TODO 2 (1p) ***

Implementați funcția nodes, care întoarce mulțimea nodurilor grafului.

Exemple:

>>> nodes graph1
fromList [1,2,3,4]
-}
nodes :: StandardGraph a -> Set a
nodes = fst

{-
*** TODO 3 (1p) ***

Implementați funcția edges, care întoarce mulțimea arcelor grafului.

>>> edges graph1
fromList [(1,2),(1,3)]
-}
edges :: StandardGraph a -> Set (a, a)
edges = snd

{-
*** TODO 4 (10p) ***

Implementați funcția outNeighbors, care întoarce mulțimea nodurilor înspre care 
pleacă arce dinspre un nod sursă.

Exemple:

>>> outNeighbors 1 graph3
fromList [2,3,4]
-}
outNeighbors :: Ord a => a -> StandardGraph a -> Set a
outNeighbors from graph = Set.map snd $ Set.filter ((== from) . fst) $ edges graph

{-
*** TODO 5 (10p) ***

Implementați funcția inNeighbors, care întoarce mulțimea nodurilor dinspre care 
pleacă arce înspre un nod destinație.

Exemple:

>>> inNeighbors 1 graph3 
fromList [4]
-}
inNeighbors :: Ord a => a -> StandardGraph a -> Set a
inNeighbors to graph = Set.map fst $ Set.filter ((== to) . snd) $ edges graph

{-
*** TODO 6 (15p) ***

Implementați funcția removeNode, care întoarce graful rezultat prin eliminarea 
unui nod și a arcelor în care acesta este implicat. Dacă nodul nu există, 
întoarce același graf.

Exemple:

>>> removeNode 1 graph3
(fromList [2,3,4],fromList [(2,3)])
-}
removeNode :: Ord a => a -> StandardGraph a -> StandardGraph a
removeNode node graph = (newNodes, newEdges)
    where
        newNodes = Set.delete node $ nodes graph
        newEdges = Set.filter (\(u, v) -> u /= node && v /= node) $ edges graph

{-
*** TODO 7 (20p) ***

Implementați funcția splitNode, care divizează un nod în mai multe noduri,
cu eliminarea nodului inițial. Arcele în care era implicat vechiul nod trebuie 
să devină valabile pentru noile noduri.

Exemplu:

>>> splitNode 2 (Set.fromList [5,6]) graph3
(fromList [1,3,4,5,6],fromList [(1,3),(1,4),(1,5),(1,6),(4,1),(5,3),(6,3)])
-}
splitNode :: Ord a
          => a                -- nodul divizat
          -> Set a            -- nodurile cu care este înlocuit
          -> StandardGraph a  -- graful existent
          -> StandardGraph a  -- graful obținut
splitNode old news graph = (newNodes, newEdges)
    where
        newNodes = Set.union news $ Set.delete old $ nodes graph
        newEdges = Set.foldr (Set.union . redirectEdge) Set.empty $ edges graph
        redirectEdge (u, v)
            -- Bucla devine produs cartezian al multimii de noduri noi cu sine
            | u == old && v == old = Set.cartesianProduct news news
            -- Redirectionam toate arcele care intrau sau ieseau
            | u == old = Set.map (\newU -> (newU, v)) news
            | v == old = Set.map (\newV -> (u, newV)) news
            -- Arcul nu este afectat de schimbare
            | otherwise = Set.singleton (u, v)

{-
*** TODO 8 (15p) ***

Implementați funcția mergeNodes, care îmbină mai multe noduri într-unul singur, 
pe baza unei proprietăți respectate de nodurile îmbinate, cu eliminarea 
acestora. Arcele în care erau implicate vechile noduri vor referi nodul nou.

Exemple:

>>> mergeNodes even 5 graph3
(fromList [1,3,5],fromList [(1,3),(1,5),(5,1),(5,3)])
-}
mergeNodes :: Ord a
           => (a -> Bool)      -- proprietatea îndeplinită de nodurile îmbinate
           -> a                -- noul nod
           -> StandardGraph a  -- graful existent
           -> StandardGraph a  -- graful obținut
mergeNodes prop node graph = if Set.null removedNodes then graph else (newNodes, newEdges)
    where
        newNodes = Set.insert node $ Set.filter (not . prop) $ nodes graph
        removedNodes = Set.filter prop $ nodes graph
        newEdges = Set.map redirectEdge $ edges graph
        redirectEdge (u, v) = (newU, newV)
            where
                newU = if Set.member u removedNodes then node else u
                newV = if Set.member v removedNodes then node else v
