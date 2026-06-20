module Modular where

import Data.Set (Set)
import qualified Data.Set as Set

{-
*** TODO 8 (10p) ***

Aplică o funcție pe fiecare element al unei liste, însă doar pe unul singur
la un moment dat, păstrându-le pe celalte nemodificate. Prin urmare, pentru
fiecare element din lista inițială rezultă câte o listă în lista finală,
aferentă modificării doar a acelui element.

Exemplu:

>>> mapSingle (+10) [1,2,3]
[[11,2,3],[1,12,3],[1,2,13]]
-}
mapSingle :: (a -> a) -> [a] -> [[a]]
mapSingle f xs = case xs of
  [] -> []
  y:ys -> (f y : ys) : map (y :) (mapSingle f ys)

{-
*** TODO 9 (10p) ***

Determină lista tuturor partițiilor unei liste. Deși mai sus tipul (Partition a)
este definit utilizând mulțimi, aici utilizăm liste, pentru simplitate.

Cele 3 niveluri ale constructorului de tip listă din tipul întors de funcție
au următoarea semnificație.

* Nivelul interior reprezintă o submulțime a listei originale
* Nivelul intermediar reprezintă o partiție, care este o mulțime de submulțimi
* Nivelul exterior reprezintă mulțimea tuturor partițiilor.

Hints:

* Folosiți list comprehensions pentru a răspunde la întrebarea: dacă am obținut 
  o partiție a restului listei, cum obținem o partiție a întregii liste,
  care include capul?
* Folosiți mapSingle

Exemple:

>>> partitions [2,3]
[[[2],[3]],[[2,3]]]

>>> partitions [1,2,3]
[[[1],[2],[3]],[[1,2],[3]],[[2],[1,3]],[[1],[2,3]],[[1,2,3]]]
-}
partitions :: [a] -> [[[a]]]
partitions xs = case xs of
  [] -> [[]]
  y:ys -> [ partition | p <- partitions ys, partition <- ([y] : p) : mapSingle (y :) p ]
