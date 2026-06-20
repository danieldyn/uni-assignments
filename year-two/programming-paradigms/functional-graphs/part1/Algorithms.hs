module Algorithms where

import Data.Set (Set)
import qualified Data.Set as Set
import StandardGraph
import Debug.Trace

{-
În etapa 1, prin graf înțelegem un graf cu reprezentare standard. În etapele 
următoare, vom experimenta și cu altă reprezentare.

type introduce un sinonim de tip, similar cu typedef din C.
-}
type Graph a = StandardGraph a

{-
*** TODO 9 (15p) ***

Implementați funcția bfs, care întoarce o listă de noduri rezultată
din parcurgerea în lățime a unui graf, pornind de la un nod.

În această etapă, presupunem pentru simplitate că graful nu conține mai multe 
căi între două noduri și nici cicluri, pentru a nu fi necesară gestiunea unei 
mulțimi de noduri deja vizitate.

Observați că utilizăm liste pentru rezultat, în locul mulțimilor, întrucât
ordinea elementelor este acum relevantă.

CONSTRÂNGERI:

* Implementarea trebuie să antreneze fiecare nod în operații de concatenare
  de cel mult două ori.
* Evitați trimiterea către apelurile recursive a parametrilor care nu se 
  modifică. De exemplu, nodurile descoperite dar încă neexpandate se modifică 
  în timpul parcurgerii, în timp ce graful, nu. Pentru aceasta, definiți o 
  funcție recursivă locală (de exemplu, în where), care să primească drept 
  parametri doar entitățile variabile de la un apel recursiv la altul. 

Pentru a vă asigura de respectarea primei constrângeri, înlocuiți temporar în 
implementarea voastră funcțiile predefinite (++) și concatMap cu variantele lor 
din schelet, appendDebug și concatMapDebug, de la finalul fișierului. Ar trebui 
să observați că fiecare element x din cadrul unui mesaj de forma "DEBUG: x" 
apare de cel mult două ori.

La prezentarea temei, demonstrați asistentului că prima constrângere este 
respectată.

Hint: O implementare bazată pe o listă utilizată în regim de coadă, cu adăugarea
vecinilor la sfârșit, ar respecta constrângerea? Utilizați funcția 
preimplementată bfsQueue de mai jos pentru a vă convinge.

În tipul funcției, (Show a) este necesar pentru construcția mesajelor DEBUG.

Exemple:

>>> bfs 1 tree
[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]

>>> bfs 4 tree
[4,11,12]
-}
bfs :: (Ord a, Show a) => a -> Graph a -> [a]
bfs node graph = explore [node] [] $ Set.singleton node
    where
        explore [] [] _ = []
        explore [] right visited = explore (reverse right) [] visited
        explore (current:rest) right visited = current : explore rest newRight marked
            where
                allNeighs = Set.toList $ outNeighbors current graph
                unexploredNeighs = filter (`Set.notMember` visited) allNeighs
                marked = foldr Set.insert visited unexploredNeighs
                newRight = reverse unexploredNeighs ++ right

-- Utilizați bfsQueue pentru experimente
bfsQueue :: (Ord a, Show a) => a -> Graph a -> [a]
bfsQueue node graph = go [node]
    where
        go [] = []
        go (node : nodes) =
            node
            : go (if null neighbors then nodes else nodes ++ neighbors)
            where
                neighbors = Set.toList $ outNeighbors node graph

{-
*** TODO 10 (15p) ***

Implementați funcția dfs, care întoarce o listă de noduri rezultată
din parcurgerea în adâncime a unui graf, pornind de la un nod.

În această etapă, presupunem pentru simplitate că graful nu conține mai multe 
căi între două noduri și nici cicluri, pentru a nu fi necesară gestiunea unei 
mulțimi de noduri deja vizitate.

Observați că utilizăm liste pentru rezultat, în locul mulțimilor, întrucât
ordinea elementelor este acum relevantă.

CONSTRÂNGERI:

* NU folosiți o stivă sau alți parametri suplimentari cu rol de acumulator.
* Evitați trimiterea către apelurile recursive a parametrilor care nu se 
  modifică (vedeți bfs).

Spre deosebire de bfs, aici nu se impun constrângeri legate de eficiența 
implementării, întrucât o vom rafina în etapa 4.

ÎNTREBARE: Se utilizează repetat elemente în vederea concatenărilor?

RĂSPUNS: Da, fiecare nod solicita de la vecinii sai lista completa a descendentilor
lor, care se realizeaza prin concatenari, pentru ca apoi el sa le unifice intr-o lista
mare tot prin concatenare.

Exemple:

>>> dfs 1 tree
[1,2,7,15,8,3,9,10,4,11,12,5,13,14,6]

>>> dfs 4 tree
[4,11,12]
-}
dfs :: (Ord a, Show a) => a -> Graph a -> [a]
dfs node graph = explore node
    where
        explore current = current : concatMap explore allNeighs
            where
                allNeighs = Set.toList $ outNeighbors current graph

{-
*** TODO 11 (15p) ***

Implementați funcția countIntermediate, care numără câte noduri intermediare 
vizitează strategiile BFS, respectiv DFS, în încercarea de găsire a unei căi 
între un nod sursă și unul destinație, ținând cont de posibilitatea absenței 
acesteia din graf. Numărul EXCLUDE nodurile sursă și destinație.

Modalitatea uzuală în Haskell de a preciza că o funcție poate să nu fie 
definită pentru anumite valori ale parametrului este constructorul de tip
Maybe. Astfel, dacă o cale există, funcția întoarce Just (numărBFS, numărDFS), 
iar altfel, Nothing.

Hint: funcția span.

Exemple:

>>> countIntermediate 1 11 tree
Just (9,8)

Aici, bfs din nodul 1 ar întoarce [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],
deci se vizitează 9 noduri intermediare, 2-10.

dfs ar întoarce [1,2,7,15,8,3,9,10,4,11,12,5,13,14,6], deci se vizitează
8 noduri intermediare: 2,7,15,8,3,9,10,4.

>>> countIntermediate 11 1 tree
Nothing

Aici nu există cale între 11 și 1.

ÎNTREBARE: În cadrul funcției countIntermediate, funcțiile bfs și dfs enumeră
toate nodurile grafului accesibile din nodul de plecare?

RĂSPUNS: ...
-}
countIntermediate :: (Ord a, Show a)
                  => a                 -- nodul sursă
                  -> a                 -- nodul destinație
                  -> Graph a           -- graful
                  -> Maybe (Int, Int)  -- numărul de noduri expandate de BFS/DFS
countIntermediate from to graph = if null bfsRest then Nothing else Just (length bfsPrefix - 1, length dfsPrefix - 1)
    where
        bfsList = bfs from graph
        dfsList = dfs from graph
        (bfsPrefix, bfsRest) = span (/= to) bfsList
        (dfsPrefix, dfsRest) = span (/= to) dfsList

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
