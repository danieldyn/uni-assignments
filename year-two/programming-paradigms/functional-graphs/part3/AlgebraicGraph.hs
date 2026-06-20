module AlgebraicGraph where

import Data.Set (Set)
import qualified Data.Set as Set

data AlgebraicGraph a
    = Empty
    | Node { label :: a }
    | Overlay { left :: AlgebraicGraph a, right :: AlgebraicGraph a }
    | Connect { left :: AlgebraicGraph a, right :: AlgebraicGraph a }
    deriving (Ord)

-- (1, 2), (1, 3)
-- 1 * (2 + 3)
angle :: AlgebraicGraph Int
angle = Connect (Node 1) (Overlay (Node 2) (Node 3))

-- (1, 2), (1, 3), (2, 3)
-- 1 * (2 * 3)
triangle :: AlgebraicGraph Int
triangle = Connect (Node 1) (Connect (Node 2) (Node 3))

{-
The nodes function from stage 2.
-}
nodes :: Ord a => AlgebraicGraph a -> Set a
nodes graph = case graph of
  Empty -> Set.empty
  Node n -> Set.singleton n
  Overlay g1 g2 -> Set.union (nodes g1) (nodes g2)
  Connect g1 g2 -> Set.union (nodes g1) (nodes g2)

{-
The edges function from stage 2.
-}
edges :: Ord a => AlgebraicGraph a -> Set (a, a)
edges graph = case graph of
  Overlay g1 g2 -> Set.union (edges g1) (edges g2)
  Connect g1 g2 -> edges g1 `Set.union` edges g2 `Set.union` Set.cartesianProduct (nodes g1) (nodes g2)
  _ ->  Set.empty -- Covers the Empty and Node constructors, which do not contribute to the result

{-
The outNeighbors function from stage 2.
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
The inNeighbors function from stage 2.
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
Instantiation the Num class with the type (AlgebraicGraph a), so that:

* an integer literal is interpreted as a single node with the label equal
    to that literal
* the addition operation is interpreted as Overlay
* the multiplication operation is interpreted as Connect.
-}
instance Num a => Num (AlgebraicGraph a) where
  fromInteger n = Node (fromInteger n)
  (+) = Overlay
  (*) = Connect

{-
Instantiation the Show class with the type (AlgebraicGraph a), so that the string 
representation of a graph reflects the arithmetic expressions defined above.
-}
instance Show a => Show (AlgebraicGraph a) where
  show graph = case graph of
    Empty -> ""
    Node n -> show n
    Overlay g1 g2 -> "(" ++ show g1 ++ "+" ++ show g2 ++ ")"
    Connect g1 g2 -> "(" ++ show g1 ++ "*" ++ show g2 ++ ")"

{-
Instantiation the Eq class with the type (AlgebraicGraph a), so that
you actually compare the sets of nodes and edges.
-}
instance Ord a => Eq (AlgebraicGraph a) where
  g1 == g2 = nodes g1 == nodes g2 && edges g1 == edges g2

{-
Extends an existing graph, attaching new arbitrary subgraphs in place of individual nodes.
The function received as the first parameter determines this correspondence between nodes and subgraphs.
-}
extend :: (a -> AlgebraicGraph b) -> AlgebraicGraph a -> AlgebraicGraph b
extend f graph = explore graph
  where
    explore Empty = Empty
    explore (Node n) = f n
    explore (Overlay g1 g2) = Overlay (explore g1) (explore g2)
    explore (Connect g1 g2) = Connect (explore g1) (explore g2)

{-
Divides a node into multiple nodes, with the removal of the initial node.
The edges in which the old node was involved must become valid for the new nodes.
-}
splitNode :: Ord a
          => a                 -- the divided node
          -> Set a             -- the nodes it is replaced with
          -> AlgebraicGraph a  -- the existing graph
          -> AlgebraicGraph a  -- the obtained graph
splitNode node targets graph = extend (\n -> if n == node then replaceNode else Node n) graph
  where
    replaceNode = foldr (\n acc -> Overlay (Node n) acc) Empty targets

{-
Instantiation of the Functor class with the AlgebraicGraph type constructor, so that 
you can apply a function to all the labels of a graph. fmap represents 
the generalisation of map for other structures.
-}
instance Functor AlgebraicGraph where
    -- fmap :: (a -> b) -> AlgebraicGraph a -> AlgebraicGraph b
    fmap f = extend (\n -> Node (f n))

{-
Merges multiple nodes into a single one, 
based on a property fulfilled by the merged nodes, with their removal. 
The edges in which the old nodes were involved will refer to the new node.
-}
mergeNodes :: (a -> Bool)       -- the property fulfilled by the merged nodes
           -> a                 -- the new node
           -> AlgebraicGraph a  -- the existing graph
           -> AlgebraicGraph a  -- the obtained graph
mergeNodes prop node = fmap (\n -> if prop n then node else n)

{-
Filters a graph, keeping only the nodes that satisfy the given property.
-}
filterGraph :: (a -> Bool) -> AlgebraicGraph a -> AlgebraicGraph a
filterGraph prop = extend (\n -> if prop n then Node n else Empty)

{-
Returns the graph resulting from the removal of a node and the edges in which it
is involved. If the node does not exist, returns the same graph.
-}
removeNode :: Eq a => a -> AlgebraicGraph a -> AlgebraicGraph a
removeNode node = filterGraph (/= node)
