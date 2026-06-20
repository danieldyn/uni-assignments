#lang racket
(require racket/match)
(require "queue.rkt")

(provide (all-defined-out))

(define ITEMS 5)

;; ATENȚIE: Este necesar să implementați întâi
;;          TDA-ul queue în fișierul queue.rkt.
;; Reveniți la acest fișier după ce ați implementat tipul 
;; queue și ați verificat implementarea folosind checker-ul.


; Structura counter nu se modifică.
; Se modifică însă implementarea câmpului queue:
; - în loc de listă, acesta va fi o structură de tip queue
; - modificarea nu este vizibilă în definiția structurii,
;   ci în implementarea operațiilor tipului counter
(define-struct counter (index tt et queue) #:transparent)


; TODO 6 (20p)
; Actualizați funcțiile de mai jos conform cu 
; noua reprezentare a cozii de persoane.
; Elementele cozii rămân perechi (nume . nr_produse).
; RESTRICȚII (5p per abatere)
;  - Respectați "bariera de abstractizare", adică 
;    operați cu coada folosind exclusiv interfața:
;    - empty-queue
;    - queue-empty?
;    - enqueue
;    - dequeue
;    - top
; Obs: Doar câteva funcții necesită actualizări.
(define (empty-counter index)           ; testată de checker
  (make-counter index 0 0 empty-queue))

(define (update f counters index) ; nu opereaza asupra cozii, ramane ca la etapa 2
  (cond
    ((null? counters) '())
    ((= index (counter-index (car counters)))
     (cons (f (car counters)) (cdr counters)))
    (else
     (cons (car counters) (update f (cdr counters) index)))))

(define ((tt+ minutes) C) ; analog cu update
  (struct-copy counter C [tt (+ (counter-tt C) minutes)]))

(define ((et+ minutes) C) ; analog cu tt+
  (struct-copy counter C [et (+ (counter-et C) minutes)]))

(define ((add-to-counter name items) C) ; testată de checker, nu modificați signatura! 
  (if (queue-empty? (counter-queue C))
      (struct-copy counter C
                   [et (+ items (counter-et C))] ; persoana va fi prima la coada
                   [tt (+ items (counter-tt C))]
                   [queue (enqueue (cons name items) (counter-queue C))])
      (struct-copy counter C
                   [tt (+ items (counter-tt C))]
                   [queue (enqueue (cons name items) (counter-queue C))])))

(define ((min-field field) counters) ; tot nu actioneaza asupra cozii, ramane ca la etapa 2

  (define (min-field-helper counters index acc) ; helper cu recursivitate pe coada
    (cond
      ((null? counters) (cons index acc))
      ((<= acc (field (car counters))) (min-field-helper (cdr counters) index acc))
      (else (min-field-helper (cdr counters) (counter-index (car counters)) (field (car counters))))))

  ; apelarea helper-ului
  (min-field-helper (cdr counters) (counter-index (car counters)) (field (car counters))))
      

(define min-tt (min-field counter-tt)) ; folosind funcția de mai sus
(define min-et (min-field counter-et)) ; folosind funcția de mai sus

(define (remove-first-from-counter C)   ; testată de checker
  ((λ (c) ; functie care asteapta sa se faca dequeue ca apoi sa decida ce se intampla cu campul et
     (if (queue-empty? (counter-queue c))
         (struct-copy counter c [et 0])
         (struct-copy counter c [et (cdr (top (counter-queue c)))])))
   (struct-copy counter C ; partea care face dequeue si intra ca al doilea termen al aplicatiei
                [tt (- (counter-tt C) (counter-et C))]
                [queue (dequeue (counter-queue C))])))


; TODO 7 (10p)
; Implementați o funcție care calculează starea
; unei case după un număr dat de minute.
; Funcția presupune, fără să verifice, că în acest timp
; nu iese nimeni din coadă, deci se modifică
; doar câmpurile tt și et.
; Este responsabilitatea utilizatorului să nu apeleze
; funcția cu minutes > et și coadă nevidă.
; La casele fără clienți, este responsabilitatea
; voastră să nu produceți timpi negativi.
(define ((pass-time-through-counter minutes) C)
  (if (< minutes (counter-et C))
      (struct-copy counter C
                   [et (- (counter-et C) minutes)]
                   [tt (- (counter-tt C) minutes)])
      (struct-copy counter C
                   [et 0]
                   [tt (- (counter-tt C) (counter-et C))])))

; TODO 8 (60p)
; Implementați funcția care simulează fluxul clienților pe la case.
; ATENȚIE: Față de etapa 2, apar modificări în:
; - formatul listei de cereri (requests)
; - formatul rezultatului funcției (explicat mai jos)
; requests conține 4 tipuri de cereri:
;   3 moștenite din etapa 2:
;   - (<name> <n-items>) - așază persoana <name> la coadă la o casă
;   - (delay <index> <minutes>) - întârzie casa <index> cu <minutes> minute
;   - (ensure <average>) - cât timp tt-ul mediu al tuturor caselor depășește 
;                          <average>, adaugă case fără restricții (case slow)
;   plus noutatea:
;   - <x> - actualizează starea caselor conform cu trecerea a <x> minute
;           de la ultima cerere (afectează câmpurile tt, et, queue)
; Obs: Cererile (remove-first) din etapa 2 sunt înlocuite de un mecanism  
; mai sofisticat de a scoate clienții din coadă (pe măsură ce trece timpul).
; Sistemul procesează cererile în ordine, astfel:
; - nicio modificare pentru cererile moștenite din etapa 2
; - când timpul prin sistem avansează cu <x> minute, starea caselor
;   se actualizează pentru a reflecta trecerea timpului;
;   ieșirile clienților din coadă se rețin în ordine cronologică.
; Funcția serve întoarce o pereche cu punct între:
; - lista clienților care au părăsit magazinul, sortată cronologic
;   - elementele listei au forma (index_casă . nume)
;   - când mai mulți clienți ies simultan, sortați după indexul casei
; - lista caselor în starea finală (ca rezultatul din etapele 1 și 2)
; Sugestii:
; - gestionați cronologia folosind în mod repetat funcția min-et 
; - pentru a menține lista clienților plecați, definiți o funcție ajutătoare
; (cu un parametru în plus față de serve), pe care serve doar o apelează.
; RESTRICȚII (5p per abatere)
;  - Folosiți minim un let și un let* (care nu ar putea fi let). (2*5p)
;  - Respectați "bariera de abstractizare" oricând operați cu tipul queue.

(define (et-tt+ minutes) (compose (tt+ minutes) (et+ minutes))) ; combina efectul functiilor tt+ si et+ pentru utilizare facila

(define (serve requests fast-counters slow-counters)
  
  (define (serve-helper done-clients requests fast-counters slow-counters) ; helper care accepta si lista de clienti care au terminat
    
    (define all-counters (append fast-counters slow-counters)) ; intoarce o lista cu toate casele existente la momentul curent 
    
    (define (get-allowed-counters n-items) ; intoarce o lista cu toate casele permise persoanei cu n-items
      (if (<= n-items ITEMS)
          all-counters
          slow-counters))

    (define get-average ; intoarce tt-ul mediu al caselor
    (/ (foldl
        (λ (C acc) (+ acc (counter-tt C)))
        0
        all-counters)
       (length all-counters)))

    (define (pass-time minutes acc fast-counters slow-counters) ; gestioneaza trecerea timpului si scoaterea clientilor de la case
      (let* ([all-counters (append fast-counters slow-counters)] ; alte variabile vor depinde de all-counters, trebuie let*
             [active-counters (filter (λ (C) (not (queue-empty? (counter-queue C)))) all-counters)])

        (define finish-sim ; finalizeaza executia pass-time cand garantat nu mai sunt persoane de scos de la case
          (serve-helper (append done-clients acc)
                        (cdr requests)
                        (map (pass-time-through-counter minutes) fast-counters)
                        (map (pass-time-through-counter minutes) slow-counters)))

        (if (null? active-counters) ; cazul simplu in care simularea se incheie
            finish-sim
            (let* ([first-client (min-et active-counters)] 
                   [index (car first-client)]
                   [first-exit (cdr first-client)])
              (if (> first-exit minutes) ; nimeni nu va iesi de la casa in timpul ramas 
                  finish-sim
                  (let* ([min-counter (car (filter (λ (C) (= index (counter-index C))) all-counters))]
                         [name (car (top (counter-queue min-counter)))]
                         [new-fast-counters (map (pass-time-through-counter first-exit) fast-counters)]
                         [new-slow-counters (map (pass-time-through-counter first-exit) slow-counters)])
                    (pass-time (- minutes first-exit) ; iese primul client si continua simularea
                               (append acc (list (cons index name)))
                               (update remove-first-from-counter new-fast-counters index)
                               (update remove-first-from-counter new-slow-counters index))))))))

    ; corpul helper-ului
    (if (null? requests)
        (cons done-clients all-counters) ; caz de baza
        (match (car requests)

          [(list 'delay index minutes)
           (serve-helper done-clients
                         (cdr requests)
                         (update (et-tt+ minutes)
                                 fast-counters
                                 index)
                         (update (et-tt+ minutes)
                                 slow-counters
                                 index))]

          [(list 'ensure average)
           (if (<= get-average average) ; media e deja in target
               (serve-helper done-clients
                             (cdr requests)
                             fast-counters
                             slow-counters)
               (serve-helper done-clients
                             requests ; nu se trece la urmatorul request pana nu s-au adaugat case suficiente pentru a scadea media
                             fast-counters
                             (append slow-counters (list (empty-counter (add1 (length all-counters)))))))]

          [(list name n-items)
           (let ([min-index (car (min-tt (get-allowed-counters n-items)))])
             (serve-helper done-clients
                           (cdr requests)
                           (update (add-to-counter name n-items)
                                   fast-counters
                                   min-index)
                           (update (add-to-counter name n-items)
                                   slow-counters
                                   min-index)))]

          [x
           (pass-time x '() fast-counters slow-counters)])))

  ; apelul helper-ului
  (serve-helper '() requests fast-counters slow-counters))
