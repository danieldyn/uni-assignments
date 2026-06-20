#lang racket
(require racket/match)

(provide (all-defined-out))

(define ITEMS 5)

;; C1, C2, C3, C4 sunt case într-un magazin.
;; C1 acceptă doar clienți care au cumpărat maxim ITEMS produse
;; (ITEMS este definit mai sus).
;; C2 - C4 nu au restricții.
;; Considerăm că procesarea fiecărui produs la casă durează un minut.
;; Casele pot suferi întârzieri (delay).
;; La un moment dat, la fiecare casă există
;; 0 sau mai mulți clienți care stau la coadă.
;; Timpul total (tt) al unei case reprezintă
;; timpul de procesare al celor aflați la coadă,
;; adică numărul de produse cumpărate de ei +
;; întârzierile suferite de casa respectivă (dacă există).
;; Ex:
;; la C3 sunt Ana cu 3 produse și Geo cu 7 produse,
;; și C3 nu are întârzieri => tt pentru C3 este 10.


; Definim o structură care descrie o casă prin:
; - index (de la 1 la 4)
; - tt (timpul total descris mai sus)
; - queue (coada cu persoanele care așteaptă)
(define-struct counter (index tt queue) #:transparent)


; TODO 1 (10p)
; Implementați o funcție care întoarce o structură counter goală.
; tt este 0 si coada este vidă.
; Obs: la definirea structurii counter se creează automat
; o funcție make-counter pentru a construi date de acest tip
(define (empty-counter index)
  (make-counter index 0 '()))


; TODO 2 (10p)
; Implementați o funcție care crește tt-ul unei case
; cu un număr dat de minute.
(define (tt+ C minutes)
  (struct-copy counter C [tt (+ (counter-tt C) minutes)]))


; TODO 3 (20p)
; Implementați o funcție care primește o listă nevidă 
; de case și întoarce o pereche dintre:
; - indexul casei (din listă) care are cel mai mic tt
; - tt-ul acesteia
; Obs: când mai multe case au același tt,
; este preferată casa cu indexul cel mai mic
; RESTRICȚII (20p):
;  - Folosiți recursivitate pe coadă.
(define (get-current-tt counters) (counter-tt (car counters))) ; extrage tt-ul primei case din lista

(define (get-current-index counters) (counter-index (car counters))) ; extrage indexul primei case din lista

(define (min-tt counters)
  (min-tt-helper (cdr counters) (get-current-index counters) (get-current-tt counters)))

(define (min-tt-helper counters index tt)
  (cond
    ((null? counters) (cons index tt))
    ((< (get-current-tt counters) tt) ; tt mai bun decat acumulatorul
     (min-tt-helper (cdr counters) (get-current-index counters) (get-current-tt counters)))
    ((and (= (get-current-tt counters) tt) (< (get-current-index counters) index)) ; tt egal dar index mai mic decat acumulatorul
     (min-tt-helper (cdr counters) (get-current-index counters) (get-current-tt counters)))
    (else ; acumulatorul este raspunsul mai bun
     (min-tt-helper (cdr counters) index tt))))


; TODO 4 (20p)
; Implementați aceeași funcționalitate de mai sus,
; cu recursivitate pe stivă.
; RESTRICȚII (20p):
;  - Folosiți recursivitate pe stivă.
(define (get-remaining-tt counters) (cdr (min-tt-stack (cdr counters)))) ; extrage tt-ul raspunsului venit din recursivitate

(define (get-remaining-index counters) (car (min-tt-stack (cdr counters)))) ; extrage indexul raspunsului venit din recursivitate

(define (min-tt-stack counters)
  (cond
    ((null? (cdr counters)) (cons (get-current-index counters) (get-current-tt counters)))
    ((< (get-current-tt counters) (get-remaining-tt counters))
     (cons (get-current-index counters) (get-current-tt counters))) ; tt curent mai mic decat in recursivitate
    ((and (= (get-current-tt counters) (get-remaining-tt counters)) (< (get-current-index counters) (get-remaining-index counters)))
     (cons (get-current-index counters) (get-current-tt counters))) ; index curent mai mic decat in recursivitate si tt egal
    (else (min-tt-stack (cdr counters))))) ; raspunsul din recursivitate e mai bun
     
; TODO 5 (10p)
; Implementați o funcție care adaugă o persoană la o casă.
; C = casa, name = numele persoanei,
; n-items = numărul de produse cumpărate
; Veți întoarce o nouă structură obținută prin așezarea perechii
; (name . n-items) la sfârșitul cozii de așteptare.
(define (my-append queue pair)
  (append queue (list pair)))

(define (add-to-counter C name n-items)
  (struct-copy counter C
               [tt (+ n-items (counter-tt C))]
               [queue (my-append (counter-queue C) (cons name n-items))]))


; TODO 6 (50p)
; Implementați funcția care simulează fluxul clienților pe la case.
; requests = listă de cereri care pot fi de 2 tipuri:
; - (<name> <n-items>) - așază persoana <name> la coadă la o casă
; - (delay <index> <minutes>) - întârzie casa <index> cu <minutes> minute
; C1, C2, C3, C4 = structuri corespunzătoare celor 4 case
; Sistemul procesează cererile în ordine, astfel:
; - așază persoana la casa cu tt minim la care are voie
;   (conform logicii implementate de min-tt)
; - când o casă suferă o întârziere, tt-ul ei crește
(define (serve requests C1 C2 C3 C4)
  
  ; Puteți să vă definiți aici funcții ajutătoare (define în define)
  ; - avantaj: aveți acces la variabilele
  ;   requests, C1, C2, C3, C4 fără a le retrimite ca parametri
  ; Puteți să vă definiți funcții ajutătoare în exteriorul lui "serve"
  ; - avantaj: puteți testa fiecare funcție imediat ce ați implementat-o
  ; Nu este obligatoriu să definiți funcții ajutătoare.

  (define (get-counter index) ; intoarce casa care are indexul dat ca parametru
    (cond
      ((= index 1) C1)
      ((= index 2) C2)
      ((= index 3) C3)
      (else C4)))

  (define (serve-next index modified-counter) ; lanseaza apelul recursiv pentru noua stare a caselor si urmatorul request
    (cond
      ((= index 1) (serve (cdr requests) modified-counter C2 C3 C4))
      ((= index 2) (serve (cdr requests) C1 modified-counter C3 C4))
      ((= index 3) (serve (cdr requests) C1 C2 modified-counter C4))
      (else (serve (cdr requests) C1 C2 C3 modified-counter))))

  (define (get-min-tt-counter n-items) ; intoarce casa respecta cerinta
    (if (> n-items ITEMS)
        (get-counter (car (min-tt (list C2 C3 C4))))
        (get-counter (car (min-tt (list C1 C2 C3 C4))))))

  (define (get-min-tt-index n-items) (counter-index (get-min-tt-counter n-items))) ; intoarce indexul casei care respecta cerinta  

  (if (null? requests)
      (list C1 C2 C3 C4)
      (match (car requests)
        [(list 'delay index minutes)
         (serve-next index (tt+ (get-counter index) minutes))]
        [(list name n-items)
         (serve-next (get-min-tt-index n-items) (add-to-counter (get-min-tt-counter n-items) name n-items))]))) 
