module AlgebraicGraph where

import Data.Set (Set)
import qualified Data.Set as Set
import Data.Foldable

data AlgebraicGraph a
    = Empty
    | Node { label :: a }
    | Overlay { left :: AlgebraicGraph a, right :: AlgebraicGraph a }
    | Connect { left :: AlgebraicGraph a, right :: AlgebraicGraph a }
    deriving (Eq)

-- (1, 2), (1, 3)
-- 1 * (2 + 3)
angle :: AlgebraicGraph Int
angle = Connect (Node 1) (Overlay (Node 2) (Node 3))

-- (1, 2), (1, 3), (2, 3)
-- 1 * (2 * 3)
triangle :: AlgebraicGraph Int
triangle = Connect (Node 1) (Connect (Node 2) (Node 3))

{-
Instantiation of the Foldable class with the AlgebraicGraph type constructor.
-}
instance Foldable AlgebraicGraph where
  foldr :: (a -> b -> b) -> b -> AlgebraicGraph a -> b
  foldr f acc graph = case graph of
    Empty -> acc
    Node n -> f n acc
    Overlay g1 g2 -> foldr f (foldr f acc g2) g1
    Connect g1 g2 -> foldr f (foldr f acc g2) g1

{-
Reimplementation the nodes function using foldr.
-}
nodesWithFoldr :: Ord a => AlgebraicGraph a -> Set a
nodesWithFoldr = foldr Set.insert Set.empty

{-
We will use tupling and equational reasoning to transform it into a compositional variant, 
called nodesEdges. Specifically, we impose the property

nodesEdges graph = (nodes graph, edges graph)

DERIVATION:
For Empty:
  nodes Empty = Set.empty
  edges Empty = Set.empty
  nodesEdges Empty = (nodes Empty, edges Empty) = (Set.empty, Set.empty)

For Node:
  nodes (Node n) = Set.singleton n
  edges (Node _) = Set.empty
  nodesEdges (Node n) = (nodes (Node n), edges (Node n)) 
                      = (Set.singleton n, Set.empty)

For Overlay:
  nodes (Overlay g1 g2) = Set.union (nodes g1) (nodes g2)
  edges (Overlay g1 g2) = Set.union (edges g1) (edges g2)
  nodesEdges g1 = (n1, e1)
  nodesEdges g2 = (n2, e2)
  nodesEdges (Overlay g1 g2)  = (nodes (Overlay g1 g2), edges (Overlay g1 g2))
                              = (Set.union (nodes g1) (nodes g2), Set.union (edges g1) (edges g2))
                              = (Set.union n1 n2, Set.union e1 e2)

For Connect:
  edges (Connect g1 g2) = (edges g1) `Set.union` (edges g2) `Set.union` Set.cartesianProduct (nodes g1) (nodes g2)
  nodesEdges (Connect g1 g2)  = (nodes (Connect g1 g2), edges (Connect g1 g2))
                              = (Set.union (nodes g1) (nodes g2), (edges g1) `Set.union` (edges g2) `Set.union` Set.cartesianProduct (nodes g1) (nodes g2))
                              = (Set.union n1 n2, e1 `Set.union` e2 `Set.union` Set.cartesianProduct n1 n2)
-}
nodesEdges :: Ord a => AlgebraicGraph a -> (Set a, Set (a, a))
nodesEdges Empty = (Set.empty, Set.empty)
nodesEdges (Node n) = (Set.singleton n, Set.empty)
nodesEdges (Overlay g1 g2) = (Set.union n1 n2, Set.union e1 e2)
  where
    (n1, e1) = nodesEdges g1
    (n2, e2) = nodesEdges g2
nodesEdges (Connect g1 g2) = (Set.union n1 n2, e1 `Set.union` e2 `Set.union` Set.cartesianProduct n1 n2)
  where
    (n1, e1) = nodesEdges g1
    (n2, e2) = nodesEdges g2

{-
Unfortunately, although nodesEdges is compositional, it cannot be implemented
with foldr, as the latter exposes a linear view of the graph,
hiding its hierarchical structure, with subgraphs combined through Overlay
and Connect.

Furthermore, although nodesEdges is more efficient than edges, it seems the price paid 
for the increased efficiency is the loss of modularity and reuse, 
since the nodes function had to be reimplemented in the definition of nodesEdges.

In order to benefit from both efficiency and modularity/reuse,
the solution is to define a more expressive mechanism for reducing (folding) the 
graph, which exposes its hierarchical structure.

The AlgebraicGraphFolder data type represents a collection of functions that
allow reducing the various forms the graph can take, assuming
that the subgraphs have already been recursively reduced.

The meaning of the type variables:

* a = the type of the nodes in the graph (same as in AlgebraicGraph a)
* b = the type of the result of reducing the subgraphs
* c = the type of the result of reducing the current graph
-}
data AlgebraicGraphFolder a b c = AlgebraicGraphFolder
    { foldEmpty   :: c
    , foldNode    :: a -> c
    , foldOverlay :: b -> b -> c
    , foldConnect :: b -> b -> c
    }

{-
As long as the types of the subgraph reductions and the current graph
coincide (b), we can reduce the entire graph to the same type b. Notice the parameter
with the type (AlgebraicGraphFolder a b b).
-}
foldAlgebraicGraph :: AlgebraicGraphFolder a b b -> AlgebraicGraph a -> b
foldAlgebraicGraph folder = go
  where
    go Empty = foldEmpty folder
    go (Node node) = foldNode folder node
    go (Overlay g1 g2) = foldOverlay folder (go g1) (go g2)
    go (Connect g1 g2) = foldConnect folder (go g1) (go g2)

{-
Reimplementation using the AlgebraicGraphFolder.
-}
nodes :: Ord a => AlgebraicGraph a -> Set a
nodes = foldAlgebraicGraph nodesFolder

nodesFolder :: Ord a => AlgebraicGraphFolder a (Set a) (Set a)
nodesFolder = AlgebraicGraphFolder
    { foldEmpty   = Set.empty       -- c            =  Set a
    , foldNode    = Set.singleton   -- a -> c       =  a -> Set a
    , foldOverlay = Set.union       -- b -> b -> c  =  Set a -> Set a -> Set a
    , foldConnect = Set.union       -- b -> b -> c  =  Set a -> Set a -> Set a
    }

{-
Implementation the isNode function (for checking if a node actually
belongs to a graph) and the AlgebraicGraphFolder.
-}
isNode :: Eq a => a -> AlgebraicGraph a -> Bool
isNode = foldAlgebraicGraph . isNodeFolder

isNodeFolder :: Eq a => a -> AlgebraicGraphFolder a Bool Bool
isNodeFolder node = AlgebraicGraphFolder
    { foldEmpty   = False       -- c            =  Bool
    , foldNode    = (== node)   -- a -> c       =  a -> Bool
    , foldOverlay = (||)        -- b -> b -> c  =  Bool -> Bool -> Bool
    , foldConnect = (||)        -- b -> b -> c  =  Bool -> Bool -> Bool
    }

{-
The (<+>) operator combines two INDEPENDENT folders, which reduce the graph to different 
types (b and c), into a folder that reduces the graph to a pair of types
(b, c).

infixl (l = left) ensures the left associativity of the operator
-}
infixl 5 <+>
(<+>) :: AlgebraicGraphFolder a b b
      -> AlgebraicGraphFolder a c c
      -> AlgebraicGraphFolder a (b, c) (b, c)
folder1 <+> folder2 = AlgebraicGraphFolder
    { foldEmpty = (foldEmpty folder1, foldEmpty folder2)
    , foldNode = \node -> (foldNode folder1 node, foldNode folder2 node)
    , foldOverlay = \(b1, c1) (b2, c2) ->
        (foldOverlay folder1 b1 b2, foldOverlay folder2 c1 c2)
    , foldConnect = \(b1, c1) (b2, c2) ->
        (foldConnect folder1 b1 b2, foldConnect folder2 c1 c2)
    }

{-
The (>.>) operator combines two SEMI-DEPENDENT folders, which reduce the graph to 
different types (b and c), into a folder that reduces the graph to a pair of 
types (b, c).

The angle brackets indicate the direction of the dependency, from left to right.
The first folder is independent, reducing the graph to type b, while the 
second folder is dependent on the first one, and reduces the graph to type c, starting
from the information calculated by BOTH folders, (b, c).

infixl (l = left) ensures the left associativity of the operator.
-}
infixl 5 >.>
(>.>) :: AlgebraicGraphFolder a  b     b
      -> AlgebraicGraphFolder a (b, c) c
      -> AlgebraicGraphFolder a (b, c) (b, c)
folder1 >.> folder2 = AlgebraicGraphFolder
    { foldEmpty = (foldEmpty folder1, foldEmpty folder2)
    , foldNode = \node -> (foldNode folder1 node, foldNode folder2 node)
    , foldOverlay = \(b1, c1) (b2, c2) ->
        (foldOverlay folder1 b1 b2, foldOverlay folder2 (b1, c1) (b2, c2))
    , foldConnect = \(b1, c1) (b2, c2) ->
        (foldConnect folder1 b1 b2, foldConnect folder2 (b1, c1) (b2, c2))
    }

{-
Implementation of the AlgebraicGraphFolder.

This time, the set of edges produced by the folder, Set (a, a), depends
not only on the edge sets calculated for the subgraphs, Set (a, a), but also 
on the node sets calculated for the same subgraphs, Set a. For this 
reason, the functions in the folder take as parameters pairs between a set of nodes 
and one of edges, (Set a, Set (a, a)).
-}
edges :: Ord a => AlgebraicGraph a -> Set (a, a)
edges = snd . foldAlgebraicGraph (nodesFolder >.> edgesFolder)

edgesFolder :: Ord a => AlgebraicGraphFolder a (Set a, Set (a, a)) (Set (a, a))
edgesFolder = AlgebraicGraphFolder
      -- Set (a, a)
    { foldEmpty = Set.empty

      -- a -> Set (a, a)
    , foldNode = \n -> Set.empty

      -- (Set a, Set (a, a)) -> (Set a, Set (a, a)) -> Set (a, a)
    , foldOverlay = \(_, edges1) (_, edges2) -> Set.union edges1 edges2

      -- (Set a, Set (a, a)) -> (Set a, Set (a, a)) -> Set (a, a)
    , foldConnect = \(nodes1, edges1) (nodes2, edges2) -> edges1 `Set.union` edges2 `Set.union` Set.cartesianProduct nodes1 nodes2
    }
