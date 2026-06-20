module AlgebraicGraph where

import Data.Set (Set)
import qualified Data.Set as Set

data AlgebraicGraph a
    = Empty
    | Node { label :: a }
    | Overlay { left :: AlgebraicGraph a, right :: AlgebraicGraph a }
    | Connect { left :: AlgebraicGraph a, right :: AlgebraicGraph a }
    deriving (Eq, Ord, Show)

-- (1, 2), (1, 3)
angle :: AlgebraicGraph Int
angle = Connect (Node 1) (Overlay (Node 2) (Node 3))

-- (1, 2), (1, 3), (2, 3)
triangle :: AlgebraicGraph Int
triangle = Connect (Node 1) (Connect (Node 2) (Node 3))

{-
Implement the nodes function, which returns the set of nodes of the graph.
-}
nodes :: Ord a => AlgebraicGraph a -> Set a
nodes graph = case graph of
  Empty -> Set.empty
  Node n -> Set.singleton n
  Overlay g1 g2 -> Set.union (nodes g1) (nodes g2)
  Connect g1 g2 -> Set.union (nodes g1) (nodes g2)

{-
Implement the edges function, which returns the set of edges of the graph.
-}
edges :: Ord a => AlgebraicGraph a -> Set (a, a)
edges graph = case graph of
  Overlay g1 g2 -> Set.union (edges g1) (edges g2)
  Connect g1 g2 -> edges g1 `Set.union` edges g2 `Set.union` Set.cartesianProduct (nodes g1) (nodes g2)
  _ ->  Set.empty -- Covers the Empty and Node constructors, which do not contribute to the result

{-
Returns the set of nodes towards which edges leave from a source node.
-}
outNeighbors :: Ord a => a -> AlgebraicGraph a -> Set a
outNeighbors node graph = explore graph
  where
    explore (Overlay g1 g2) = Set.union (explore g1) (explore g2)
    explore (Connect g1 g2) = explore g1 `Set.union` explore g2 `Set.union` (if hasNode g1 then nodes g2 else Set.empty)
    explore _ = Set.empty -- Same reasoning as for edges
    hasNode g = case g of
      Empty -> False
      Node n -> node == n
      Overlay s1 s2 -> (hasNode s1) || (hasNode s2)
      Connect s1 s2 -> (hasNode s1) || (hasNode s2)

{-
Returns the set of nodes from which edges leave towards a destination node.
-}
inNeighbors :: Ord a => a -> AlgebraicGraph a -> Set a
inNeighbors node graph = explore graph
  where
    explore (Overlay g1 g2) = Set.union (explore g1) (explore g2)
    explore (Connect g1 g2) = explore g1 `Set.union` explore g2 `Set.union` (if hasNode g2 then nodes g1 else Set.empty)
    explore _ = Set.empty
    hasNode g = case g of
      Empty -> False
      Node n -> n == node
      Overlay s1 s2 -> (hasNode s1) || (hasNode s2)
      Connect s1 s2 -> (hasNode s1) || (hasNode s2)

{-
Returns the graph resulting from the removal 
of a node and the edges in which it is involved. If the node does not exist, 
return the same graph.
-}
removeNode :: Eq a => a -> AlgebraicGraph a -> AlgebraicGraph a
removeNode node graph = explore graph
  where
    explore Empty = Empty
    explore (Node n) = if n == node then Empty else Node n
    explore (Overlay g1 g2) = combine (explore g1) (explore g2)
      where
        combine Empty right = right
        combine left Empty = left
        combine left right = Overlay left right
    explore (Connect g1 g2) = combine (explore g1) (explore g2)
      where
        combine Empty right = right
        combine left Empty = left
        combine left right = Connect left right

{-
Divides a node into multiple nodes,
with the removal of the initial node. The edges in which the old node was involved must 
become valid for the new nodes.
-}
splitNode :: Ord a
          => a                 -- the divided node
          -> Set a             -- the nodes it is replaced with
          -> AlgebraicGraph a  -- the existing graph
          -> AlgebraicGraph a  -- the obtained graph
splitNode node targets graph = explore graph
  where
    explore Empty = Empty
    explore (Node n) = if n == node then replaceNode else Node n
    explore (Overlay g1 g2) = Overlay (explore g1) (explore g2)
    explore (Connect g1 g2) = Connect (explore g1) (explore g2)
    replaceNode = foldr (\n acc -> Overlay (Node n) acc) Empty targets

{-
Merges multiple nodes into a single one, 
based on a property fulfilled by the merged nodes, with their removal. 
The edges in which the old nodes were involved will refer to the new node.
-}
mergeNodes :: (a -> Bool)       -- the property fulfilled by the merged nodes
           -> a                 -- the new node
           -> AlgebraicGraph a  -- the existing graph
           -> AlgebraicGraph a  -- the obtained graph
mergeNodes prop node graph = explore graph
  where
    explore Empty = Empty
    explore (Node n) = if prop n then Node node else Node n
    explore (Overlay g1 g2) = Overlay (explore g1) (explore g2)
    explore (Connect g1 g2) = Connect (explore g1) (explore g2)
