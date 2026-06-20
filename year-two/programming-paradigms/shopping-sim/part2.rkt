#lang racket
(require racket/match)

(provide (all-defined-out))

(define ITEMS 5)

;; Actualizăm structura counter cu informația et:
;; Exit time (et) al unei case reprezintă timpul
;; până la ieșirea primului client de la casa respectivă,
;; adică numărul de produse de procesat pentru acest client
;; + întârzierile suferite de casă (dacă există).
;; Ex:
;; la C3 s-au așezat Ana cu 3 produse, apoi Geo cu 7 produse,
;; și C3 a fost întârziată cu 5 minute =>
;; et pentru C3 este 3 + 5 = 8 (timpul până când va ieși Ana).


; Redefinim structura counter.
(define-struct counter (index tt et queue) #:transparent)


; TODO 1 (5p)
; Actualizați implementarea empty-counter astfel încât să conțină și câmpul et.
(define (empty-counter index)
  (make-counter index 0 0 '()))


; TODO 2 (15p)
; Implementați o funcție care aplică o transformare f
; casei cu un anumit index.
; f = funcție unară cu un parametru de tip casă,
; counters = listă de case,
; index = indexul casei care trebuie transformată
; Veți întoarce lista actualizată de case.
; Dacă nu există în counters o casă cu acest index,
; întoarceți lista nemodificată.

(define (update f counters index)
  (cond
    ((null? counters) '())
    ((= index (counter-index (car counters)))
     (cons (f (car counters)) (cdr counters))) ; se aplica f la gasirea casei si se adauga la loc in lista
    (else ; continua recursiv cautarea
     (cons (car counters) (update f (cdr counters) index)))))


; TODO 3 (7.5p)
; Memento: tt+ crește tt-ul unei case cu un număr de minute.
; Obs: tt+ afectează doar câmpul tt, nu și câmpul et.
; Actualizați implementarea tt+ pentru:
; - a ține cont de noua reprezentare a unei case
; - a permite ca operații de tip tt+ să fie pasate ca argument
;   funcției update în cel mai facil mod
; Obs: Facil înseamnă că o aplicație parțială a funcției tt+ 
; va produce o funcție unară cu parametru de tip casă, fără
; să fie nevoie de funcții anonime sau funcții auxiliare.
; Scheletul nu menționează parametrii funcției tt+, întrucât
; trebuie să determinați voi înșivă cum este cel mai bine
; ca tt+ să își primească parametrii.
;
; Apoi implementați funcția checker-tt+, care apelează funcția
; tt+ pe o casă și un număr de minute.
; Funcția checker-tt își precizează clar parametrii și
; poate fi testată, acesta este singurul său rol.
; RESTRICȚII (5p)
;  - Implementați tt+ conform cerinței anterioare.
(define (tt+ minutes)
  (λ (C)
    (struct-copy counter C [tt (+ (counter-tt C) minutes)])))

(define (checker-tt+ C minutes)
  ((tt+ minutes) C))


; TODO 4 (7.5p)
; Implementați o funcție care crește et-ul unei case
; cu un număr dat de minute.
; Obs: et+ afectează doar câmpul et, nu și câmpul tt.
; Păstrați formatul folosit pentru tt+.
; Apoi implementați funcția checker-et+ care apelează
; et+, pentru testare.
; RESTRICȚII (5p)
;  - Implementați et+ conform cerinței anterioare.
(define (et+ minutes)
  (λ (C)
    (struct-copy counter C [et (+ (counter-et C) minutes)])))

(define (checker-et+ C minutes)
  ((et+ minutes) C))


; TODO 5 (10p)
; Memento: add-to-counter adaugă o persoană
; (reprezentată prin nume și număr de produse) la o casă. 
; Actualizați implementarea add-to-counter din aceleași
; rațiuni pentru care ați actualizat funcția tt+.
; Atenție la cum se modifică tt și et!
; Apoi implementați funcția checker-add-to-counter
; care apelează add-to-counter, pentru testare.
; RESTRICȚII (5p)
;  - Implementați add-to-counter conform cerinței anterioare.

(define (my-append queue pair) ; adauga o pereche la finalul listei de perechi
  (append queue (list pair)))

(define (add-to-counter name n-items)
  (λ (C)
    (if (null? (counter-queue C)) ; verific daca persoana va fi prima la casa daca e adaugata
        (struct-copy counter C
                     [et (+ n-items (counter-et C))]
                     [tt (+ n-items (counter-tt C))]
                     [queue (my-append (counter-queue C) (cons name n-items))])
        (struct-copy counter C
                     [tt (+ n-items (counter-tt C))]
                     [queue (my-append (counter-queue C) (cons name n-items))]))))

(define (checker-add-to-counter C name n-items)
  ((add-to-counter name n-items) C))


; TODO 6 (15p)
; Întrucât vom folosi atât min-tt (implementat în etapa 1)
; cât și min-et (funcție nouă), definiți o funcție mai abstractă
; din care să derive ușor atât min-tt cât și min-et.
; Prin analogie cu min-tt, definim min-et astfel:
; min-et = funcție care primește o listă nevidă de case și
; întoarce o pereche dintre:
; - indexul casei (din listă) care are cel mai mic et
; - et-ul acesteia
; (la același et, este preferată casa cu indexul cel mai mic)
; Obs: în etapele 2-4, listele de case sunt sortate după index.
; RESTRICȚII (10p - 2*5p)
;  - min-tt și min-et vor fi aplicații parțiale ale funcției abstracte.

(define ((min-field field) counters)
  (foldl (λ (C pair) (if (<= (cdr pair) (field C))
                              pair
                              (cons (counter-index C) (field C))))
         (cons (counter-index (car counters)) (field (car counters)))
         (cdr counters)))
      

(define min-tt (min-field counter-tt)) ; folosind funcția de mai sus
(define min-et (min-field counter-et)) ; folosind funcția de mai sus


; TODO 7 (10p)
; Implementați o funcție care scoate prima persoană
; din coada unei case.
; Funcția presupune, fără să verifice, că există
; minim o persoană la coada casei C.
; Veți întoarce o nouă structură obținută prin
; modificarea cozii de așteptare.
; Atenție la cum se modifică tt și et!
; Dacă o casă tocmai a fost părăsită de cineva,
; înseamnă că ea nu mai are întârzieri.

(define (get-next-n-items queue) ; intoarce n-items pentru a doua persoana din lista (sau 0 daca nu exista)
  (if (null? (cdr queue))
      0
      (cdr (car (cdr queue)))))

(define (remove-first-from-counter C)
  (struct-copy counter C
               [tt (- (counter-tt C) (counter-et C))]
               [et (get-next-n-items (counter-queue C))]
               [queue (cdr (counter-queue C))]))
    

; TODO 8 (50p)
; Implementați funcția care simulează fluxul clienților pe la case.
; ATENȚIE: Față de etapa 1, funcția operează cu următoarele modificări:
; - nu mai avem doar 4 case, ci:
;   - fast-counters (o listă de case pentru maxim ITEMS produse)
;   - slow-counters (o listă de case fără restricții)
;   (Sugestie: folosiți funcția update pentru a procesa liste de case)
; - requests conține 4 tipuri de cereri (două în plus față de etapa 1):
;   - (<name> <n-items>) - așază persoana <name> la coadă la o casă
;   - (delay <index> <minutes>) - întârzie casa <index> cu <minutes> minute
;   - (remove-first) - cea mai avansată persoană părăsește casa la care este
;   - (ensure <average>) - cât timp tt-ul mediu al tuturor caselor depășește 
;                          <average>, adaugă case fără restricții (case slow)
; Sistemul procesează cererile în ordine, astfel:
; - așază persoana la casa cu tt minim la care are voie
;   (ca înainte, dar folosind fast-counters și slow-counters)
; - când o casă suferă o întârziere, tt-ul și et-ul ei cresc
;   (chiar dacă nu are clienți)
; - persoana cea mai avansată este prima persoană la casa cu et-ul minim
;   (dintre casele care au clienți)
;   (dacă nicio casă nu are clienți, ignoră cererea)
; - dacă tt-ul mediu pentru toate casele > <average>,
;   adaugă case slow până când media <= <average>
;   (puteți determina matematic de câte case noi este nevoie sau
;   să adăugați recursiv una câte una cât timp este necesar)
; Considerați casele indexate de la 1 și mereu sortate după index.
; Ex:
; fast-counters conține casele 1-2, slow-counters conține casele 3-15
; => la nevoie adăugați întâi casa 16, apoi casa 17, etc.
; RESTRICȚII (25p - 5*5p)
;  - Folosiți minim două funcționale predefinite în Racket. (2*5p)
;  - Nu apelați checker-tt+, checker-et+, checker-add-to-counter,
;    ci doar tt+, et+, add-to-counter. (3*5p) 

(define (et-tt+ minutes) (compose (tt+ minutes) (et+ minutes))) ; combina efectul functiilor tt+ si et+ pentru utilizare facila

(define (serve requests fast-counters slow-counters)

  (define all-counters (append fast-counters slow-counters)) ; intoarce o lista cu toate casele existente la momentul curent

  (define (get-allowed-counters n-items) ; intoarce o lista cu toate casele permise persoanei cu n-items
    (if (<= n-items ITEMS)
        all-counters
        slow-counters))

  (define get-active-counters ; intoarce o lista cu toate casele care au minim o persoana
    (filter
     (λ (C) (not (null? (counter-queue C))))
     all-counters))

  (define get-average ; intoarce tt-ul mediu al caselor
    (/ (foldl
        (λ (C acc) (+ acc (counter-tt C)))
        0
        all-counters)
       (length all-counters)))
    
  (if (null? requests)
      (append fast-counters slow-counters) ; caz de baza
      (match (car requests)
        [(list 'delay index minutes)
         (serve (cdr requests)
                (update (et-tt+ minutes) ; update va schimba doar casa cu indexul cerut
                        fast-counters
                        index)
                (update (et-tt+ minutes)
                        slow-counters
                        index))]
        [(list 'remove-first)
         (if (null? get-active-counters) ; ignora cererea daca toate casele sunt libere
             (serve (cdr requests)
                    fast-counters
                    slow-counters)
             (serve (cdr requests)
                    (update remove-first-from-counter
                            fast-counters
                            (car (min-et get-active-counters)))
                    (update remove-first-from-counter
                            slow-counters
                            (car (min-et get-active-counters)))))]
        [(list 'ensure average)
         (if (<= get-average average) ; media e deja in target
             (serve (cdr requests)
                    fast-counters
                    slow-counters)
             (serve requests ; nu se trece la urmatorul request pana nu s-au adaugat case suficiente pentru a scadea media
                    fast-counters
                    (append slow-counters (list (empty-counter (add1 (length all-counters)))))))]
        [(list name n-items)
         (serve (cdr requests)
                (update (add-to-counter name n-items)
                        fast-counters
                        (car (min-tt (get-allowed-counters n-items))))
                (update (add-to-counter name n-items)
                        slow-counters
                        (car (min-tt (get-allowed-counters n-items)))))])))
